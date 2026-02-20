// lib/utils/web_file_helper.dart
import 'dart:html' as html;

String createBlobUrl(List<int> bytes) {
  final blob = html.Blob([bytes]);
  return html.Url.createObjectUrlFromBlob(blob);
}