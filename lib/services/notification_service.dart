import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  }

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
  }
}
