// Web implementation — uses dart:html to trigger a browser file download.
// This file is only compiled on the web platform.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

/// Triggers a browser download of [bytes] as a PDF with the given [filename].
void downloadBytesOnWeb(Uint8List bytes, String filename) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  html.document.body!.children.add(anchor);
  anchor.click();
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

/// On web, "sharing" a file means triggering a browser download.
/// Web Share API support for File blobs is inconsistent across browsers.
Future<void> shareBytesOnWeb(
  Uint8List bytes,
  String filename,
  String title,
) async {
  downloadBytesOnWeb(bytes, filename);
}
