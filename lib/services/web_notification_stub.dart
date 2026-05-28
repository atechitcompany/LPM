// Stub for non-web platforms (Android, iOS, desktop)
// These functions do nothing on non-web platforms.

Future<bool> requestWebNotificationPermission() async {
  return false;
}

void showWebNotification(String title, String body) {
  // No-op on non-web platforms
}

bool isWebNotificationSupported() {
  return false;
}
