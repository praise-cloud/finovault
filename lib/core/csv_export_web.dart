// This file is only ever imported on the web (see csv_export.dart), so using
// `dart:html` here is intentional. The deprecation/info lints are suppressed
// for this web-only translation unit.
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
