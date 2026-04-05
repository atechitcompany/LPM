import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NotificationHelper {

  // --- 🔴 IMPORTANT: Yahan apni Firebase Server Key dalein ---
  // Firebase Console -> Project Settings -> Cloud Messaging -> Cloud Messaging API (Legacy) -> Server Key
  // Agar Legacy Enable nahi hai to waha 3-dot menu se Enable karein.
  static const String serverKey = "YOUR_SERVER_KEY_HERE_PASTE_IT";

  static Future<void> sendAdminNotification({
    required String title,
    required String message,
    required String type, // 'New Lead' or 'Payment'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('userName') ?? 'Unknown Staff';

      // 1. Save to Database (Purana kaam)
      await FirebaseFirestore.instance.collection('admin_notifications').add({
        'title': title,
        'message': message,
        'type': type,
        'byUser': userName,
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateFormat('dd MMM, hh:mm a').format(DateTime.now()),
        'isRead': false,
      });

      // 2. SEND REAL PHONE NOTIFICATION (Naya Kaam)
      await _sendPushToTopic(title, message);

    } catch (e) {
      print("Notification Error: $e");
    }
  }

  // --- FCM API CALL ---
  static Future<void> _sendPushToTopic(String title, String body) async {
    if (serverKey.contains("YOUR_SERVER_KEY")) {
      print("❌ Notification nahi jayega kyuki Server Key nahi dali hai.");
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'sound': 'default',
              'android_channel_id': 'high_importance_channel'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            // Admin ke topic par bhejo
            'to': '/topics/admin_alerts',
          },
        ),
      );
      print("✅ Push Notification Sent to Admin!");
    } catch (e) {
      print("❌ Push Failed: $e");
    }
  }
}