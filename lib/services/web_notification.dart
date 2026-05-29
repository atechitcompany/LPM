// Web-only notification utilities — only compiled on web platform
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

Future<bool> requestWebNotificationPermission() async {
  if (!isWebNotificationSupported()) return false;

  final permission = html.Notification.permission;
  if (permission == 'granted') return true;
  if (permission == 'denied') return false;

  // Request permission
  final result = await html.Notification.requestPermission();
  return result == 'granted';
}

void showWebNotification(String title, String body) {
  if (!isWebNotificationSupported()) return;
  if (html.Notification.permission != 'granted') return;

  html.Notification(title, body: body, icon: 'icons/Icon-192.png');
}

bool isWebNotificationSupported() {
  try {
    return html.Notification.supported;
  } catch (_) {
    return false;
  }
}
