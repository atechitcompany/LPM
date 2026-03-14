// Stub for non-web platforms (Android, iOS, desktop)
// dart:html is never imported here

String createBlobUrl(List<int> bytes) {
  // Not used on non-web platforms
  return '';
}

void downloadViaAnchor(String url, String filename) {
  // Not used on non-web platforms
}