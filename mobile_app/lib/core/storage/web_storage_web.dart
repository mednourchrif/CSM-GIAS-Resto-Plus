// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Map<String, String>? getWebLocalStorage() {
  try {
    return html.window.localStorage;
  } catch (_) {
    return null;
  }
}
