// Web-only CSV download shim. dart:html is the correct API for browser downloads;
// package:web is the long-term replacement but requires js_interop plumbing here.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Triggers a browser download of the CSV (web target).
Future<void> downloadCsv(String filename, String content) async {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
