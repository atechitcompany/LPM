// Web-only utilities — only compiled on web platform
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String createBlobUrl(List<int> bytes) {
  final blob = html.Blob([bytes]);
  return html.Url.createObjectUrlFromBlob(blob);
}

void downloadViaAnchor(String url, String filename) {
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
}