import 'package:flutter/services.dart';

/// Falls back to copying the CSV to the clipboard on mobile (no file system
/// access without a platform channel). The UI shows a confirmation snackbar.
Future<void> downloadCsv(String filename, String content) async {
  await Clipboard.setData(ClipboardData(text: content));
}
