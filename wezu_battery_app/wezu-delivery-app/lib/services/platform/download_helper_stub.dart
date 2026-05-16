// Native (non-web) stub — these functions are never called on native platforms
// because InvoiceService checks kIsWeb before calling them.
import 'dart:typed_data';

void downloadBytesOnWeb(Uint8List bytes, String filename) {
  throw UnsupportedError('Web download is only available on the web platform.');
}

Future<void> shareBytesOnWeb(
  Uint8List bytes,
  String filename,
  String title,
) async {
  throw UnsupportedError('Web share is only available on the web platform.');
}
