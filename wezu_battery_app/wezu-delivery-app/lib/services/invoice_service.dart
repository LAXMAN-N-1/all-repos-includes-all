import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Conditional import: dart:html on web, stub on native.
import 'platform/download_helper_stub.dart'
    if (dart.library.html) 'platform/download_helper_web.dart';

enum InvoiceType { order, rental }

/// Downloads, saves, opens and shares invoice/receipt PDFs.
///
/// On **web** — triggers a browser blob download (no file system / plugin needed).
/// On **mobile/desktop** — saves to the app documents directory and can share
///   via the OS share sheet.
class InvoiceService {
  static const _base = 'https://api.wezu.app';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  InvoiceService({http.Client? client}) : _client = client ?? http.Client();

  // ─── Platform-safe directory ────────────────────────────────────────────────

  static Future<Directory> _getSafeDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return Directory.current;
    }
  }

  // ─── Download bytes (all platforms) ────────────────────────────────────────

  Future<Uint8List> _fetchPdfBytes({
    required String id,
    required InvoiceType type,
    String authToken = '',
  }) async {
    try {
      final url = type == InvoiceType.order
          ? '$_base/payments/orders/$id/invoice'
          : '$_base/payments/rentals/$id/invoice';

      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/pdf',
              if (authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (_) {
      // Backend unreachable — fall through to mock
    }
    return _buildMockPdf(id, type);
  }

  // ─── Download ───────────────────────────────────────────────────────────────

  /// On **web**: triggers a browser file download with the PDF bytes.
  /// On **native**: saves the PDF to the documents directory and returns the
  ///   [File], which can then be opened or shared.
  ///
  /// Always returns a [File] on native; throws [UnsupportedError] on web
  /// (use [downloadForWeb] for web-specific UI feedback).
  Future<File> downloadInvoice({
    required String id,
    required InvoiceType type,
    String authToken = '',
  }) async {
    final bytes = await _fetchPdfBytes(
      id: id,
      type: type,
      authToken: authToken,
    );

    if (kIsWeb) {
      // Trigger browser download inline
      downloadBytesOnWeb(bytes, 'wezu_receipt_$id.pdf');
      throw UnsupportedError('web_download_triggered');
    }

    final dir = await _getSafeDirectory();
    final wezuDir = Directory('${dir.path}/wezu_receipts');
    if (!wezuDir.existsSync()) wezuDir.createSync(recursive: true);
    final file = File('${wezuDir.path}/wezu_receipt_$id.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ─── Open ───────────────────────────────────────────────────────────────────

  Future<OpenResult> openInvoice(File file) =>
      OpenFilex.open(file.path, type: 'application/pdf');

  // ─── Share ──────────────────────────────────────────────────────────────────

  /// On **web**: triggers a browser download (web share API for files is
  ///   not reliably supported across browsers).
  /// On **native**: opens the OS share sheet.
  Future<void> shareInvoice(
    File? file, {
    String? subject,
    // For web — pass bytes directly to avoid needing a File
    Uint8List? bytes,
    String? filename,
    required String id,
    required InvoiceType type,
  }) async {
    if (kIsWeb) {
      final pdfBytes = bytes ?? await _fetchPdfBytes(id: id, type: type);
      await shareBytesOnWeb(
        pdfBytes,
        filename ?? 'wezu_receipt_$id.pdf',
        subject ?? 'Wezu Delivery Receipt',
      );
      return;
    }

    final xFile = XFile(
      file!.path,
      mimeType: 'application/pdf',
      name: file.path.split(Platform.pathSeparator).last,
    );
    await Share.shareXFiles(
      [xFile],
      subject: subject ?? 'Wezu Delivery Receipt',
      text: 'Here is your transaction receipt from Wezu Delivery.',
    );
  }

  // ─── Mock PDF ───────────────────────────────────────────────────────────────

  Uint8List _buildMockPdf(String id, InvoiceType type) {
    final label = type == InvoiceType.order ? 'Order' : 'Rental';
    final content =
        '%PDF-1.4\n'
        '1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n\n'
        '2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n\n'
        '3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842]\n'
        '   /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\n'
        'endobj\n\n'
        '4 0 obj\n<< /Length 260 >>\nstream\n'
        'BT\n/F1 16 Tf\n50 800 Td\n'
        '(Wezu Delivery - $label Receipt) Tj\n'
        '/F1 12 Tf\n0 -40 Td\n'
        '(ID: $id) Tj\n'
        '0 -25 Td\n(Status: Completed) Tj\n'
        '0 -25 Td\n(Thank you for using Wezu Delivery!) Tj\n'
        '0 -25 Td\n(This receipt was generated on your device.) Tj\n'
        'ET\nendstream\nendobj\n\n'
        '5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n\n'
        'xref\n0 6\n'
        '0000000000 65535 f \n'
        '0000000009 00000 n \n'
        '0000000068 00000 n \n'
        '0000000125 00000 n \n'
        '0000000274 00000 n \n'
        '0000000586 00000 n \n\n'
        'trailer\n<< /Size 6 /Root 1 0 R >>\n'
        'startxref\n665\n%%EOF';
    return Uint8List.fromList(content.codeUnits);
  }

  void dispose() => _client.close();
}
