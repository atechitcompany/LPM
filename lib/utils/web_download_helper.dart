// lib/utils/web_download_helper.dart
import 'dart:html' as html;

void openFileInWeb(String url) {
  html.AnchorElement(href: url)
    ..target = '_blank'
    ..click();
}