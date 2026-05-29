import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lightatech/Features/MapScreen/models/task.dart';
import 'package:lightatech/core/session/session_manager.dart';

// Conditional import for web notifications
import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static bool isMapScreenActive = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _tasksSubscription;
  bool _isInitialized = false;

  // --- Reminder / Deadline polling ---
  Timer? _reminderTimer;
  // Track which (taskId + timestamp) combos have already been notified
  // so we don't spam the same reminder every 60 seconds.
  final Set<String> _firedNotificationKeys = {};

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Request FCM permissions
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kIsWeb) {
      // On web, request browser notification permission
      await requestWebNotificationPermission();
    } else {
      // 2. Initialize local notifications for foreground alerts (native only)
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotificationsPlugin.initialize(initSettings);
    }

    // 3. Listen for foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(
          message.notification!.title ?? 'New Notification',
          message.notification!.body ?? '',
        );
      }
    });

    // 4. Start listening to Firestore task updates for user notifications
    startFirestoreTasksListener();

    // 5. Start the periodic reminder/deadline checker (every 60 seconds)
    _startReminderDeadlineChecker();
  }

  // ──────────────────────────────────────────────────────────
  //  PERIODIC REMINDER & DEADLINE CHECKER
  // ──────────────────────────────────────────────────────────

  void _startReminderDeadlineChecker() {
    _reminderTimer?.cancel();

    // Run immediately once, then every 60 seconds
    _checkRemindersAndDeadlines();
    _reminderTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _checkRemindersAndDeadlines(),
    );
  }

  Future<void> _checkRemindersAndDeadlines() async {
    try {
      final String? loginUserId = SessionManager.getEmail();
      if (loginUserId == null || loginUserId.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .get();

      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final task = Task.fromMap(doc.id, data);

        // Skip completed tasks
        if (task.isDone) continue;

        // Only check tasks relevant to this user
        final createdBy = task.createdBy ?? '';
        final assignee = task.assignee ?? '';
        final isRelevant = createdBy == loginUserId ||
            assignee.split(', ').contains(loginUserId);
        if (!isRelevant) continue;

        // ── Check REMINDERS ──
        if (task.reminder != null && task.reminder!.isNotEmpty) {
          final reminderParts = task.reminder!.split(', ');
          for (final part in reminderParts) {
            final reminderTime = DateTime.tryParse(part.trim());
            if (reminderTime == null) continue;

            final key = '${doc.id}_remind_${reminderTime.toIso8601String()}';
            if (_firedNotificationKeys.contains(key)) continue;

            // Fire if the reminder time is within the past 2 minutes
            final diff = now.difference(reminderTime).inSeconds;
            if (diff >= 0 && diff <= 120) {
              _firedNotificationKeys.add(key);
              await showLocalNotification(
                "⏰ Reminder: ${task.title}",
                "Your reminder for this task is due now!",
              );
            }
          }
        }

        // ── Check DEADLINE ──
        if (task.deadline != null && task.deadline!.isNotEmpty) {
          final deadlineTime = DateTime.tryParse(task.deadline!.trim());
          if (deadlineTime == null) continue;

          // Notify at deadline time (within past 2 minutes)
          final deadlineKey = '${doc.id}_deadline_${deadlineTime.toIso8601String()}';
          if (!_firedNotificationKeys.contains(deadlineKey)) {
            final diff = now.difference(deadlineTime).inSeconds;
            if (diff >= 0 && diff <= 120) {
              _firedNotificationKeys.add(deadlineKey);
              await showLocalNotification(
                "🚨 Deadline Reached: ${task.title}",
                "This task's deadline has arrived!",
              );
            }
          }

          // Also notify 30 minutes BEFORE the deadline
          final earlyKey = '${doc.id}_deadline_early_${deadlineTime.toIso8601String()}';
          if (!_firedNotificationKeys.contains(earlyKey)) {
            final minutesBefore = deadlineTime.difference(now).inMinutes;
            if (minutesBefore >= 0 && minutesBefore <= 30) {
              _firedNotificationKeys.add(earlyKey);
              await showLocalNotification(
                "⚠️ Deadline Approaching: ${task.title}",
                "This task is due in $minutesBefore minutes!",
              );
            }
          }
        }
      }
    } catch (e) {
      // Silently handle errors so the timer keeps running
      debugPrint('Reminder/deadline check error: $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  //  NEW TASK LISTENER (existing)
  // ──────────────────────────────────────────────────────────

  void startFirestoreTasksListener() {
    _tasksSubscription?.cancel();

    final String? loginUserId = SessionManager.getEmail();
    if (loginUserId == null || loginUserId.isEmpty) return;

    // Listen only to tasks created after now so we don't spam old notifications
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    _tasksSubscription = FirebaseFirestore.instance
        .collection('tasks')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;

          final task = Task.fromMap(change.doc.id, data);

          // Only notify for new tasks created after app/listener initialization
          final createdDateMs = _parseCreatedDateToMs(task.createdDate);
          if (createdDateMs < nowMs - 15000) {
            // Created more than 15s ago, ignore it as old
            continue;
          }

          final createdBy = task.createdBy ?? '';
          final assignee = task.assignee ?? '';

          // Match logged in user AND ensure they are NOT actively viewing the map screen
          if ((createdBy == loginUserId || assignee.split(', ').contains(loginUserId)) && !isMapScreenActive) {
            showLocalNotification(
              "New Task Assigned",
              "Task: ${task.title}",
            );
          }
        }
      }
    });
  }

  int _parseCreatedDateToMs(String str) {
    try {
      final parts = str.split(' • ');
      final dateParts = parts[0].split('/');
      final timeParts = parts[1].split(':');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      return DateTime(year, month, day, hour, minute).millisecondsSinceEpoch;
    } catch (e) {
      return 0;
    }
  }

  Future<void> showLocalNotification(String title, String body) async {
    if (kIsWeb) {
      // Use browser's native Notification API on web
      showWebNotification(title, body);
      return;
    }

    // Native platform: use flutter_local_notifications
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'lpm_tasks_channel',
      'LPM Tasks Notifications',
      channelDescription: 'Notifications for task updates',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformDetails,
    );
  }

  void stopListener() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }
}
