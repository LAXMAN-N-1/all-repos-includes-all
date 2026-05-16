import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

/// Displayed after a receipt PDF is downloaded.
/// Automatically opens the system PDF viewer and provides
/// Open, Share, and Save buttons.
class InvoiceViewerScreen extends StatefulWidget {
  final File pdfFile;
  final String invoiceTitle;

  const InvoiceViewerScreen({
    super.key,
    required this.pdfFile,
    required this.invoiceTitle,
  });

  @override
  State<InvoiceViewerScreen> createState() => _InvoiceViewerScreenState();
}

class _InvoiceViewerScreenState extends State<InvoiceViewerScreen> {
  static const _accent = Color(0xFFFD802E);
  static const _dark = Color(0xFF233D4C);

  bool _isOpening = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    // Auto-open the native PDF viewer when the screen loads
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _openWithSystemViewer(),
    );
  }

  // ── Open in native PDF viewer ───────────────────────────────────────────────

  Future<void> _openWithSystemViewer() async {
    if (_isOpening) return;
    if (kIsWeb) {
      _showSnack('Cannot open PDF viewer in web preview.');
      return;
    }
    setState(() => _isOpening = true);
    try {
      await OpenFilex.open(widget.pdfFile.path, type: 'application/pdf');
    } catch (e) {
      if (mounted) {
        _showSnack(
          e.toString().contains('MissingPluginException')
              ? 'PDF viewer not available. Please restart the app.'
              : 'Could not open PDF viewer.',
        );
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  // ── Share via OS share sheet ────────────────────────────────────────────────

  Future<void> _share() async {
    if (_isSharing) return;
    if (kIsWeb) {
      _showSnack('Sharing is not supported in the web preview.');
      return;
    }
    setState(() => _isSharing = true);
    try {
      final xFile = XFile(
        widget.pdfFile.path,
        mimeType: 'application/pdf',
        name: _fileName,
      );
      await Share.shareXFiles(
        [xFile],
        subject: widget.invoiceTitle,
        text: 'Sharing my Wezu Delivery receipt.',
      );
    } catch (e) {
      if (mounted) {
        _showSnack(
          e.toString().contains('MissingPluginException')
              ? 'Plugin not ready. Please restart the app and try again.'
              : 'Could not open share sheet. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String get _fileName => widget.pdfFile.path.split('/').last;

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Colors.white,
        foregroundColor: _dark,
        elevation: 0.5,
        actions: [
          _isSharing
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _accent,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'Share Receipt',
                  onPressed: _share,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // ── PDF icon ─────────────────────────────────────────────────────
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                size: 56,
                color: _accent,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.invoiceTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              _fileName,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Saved to device storage',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),

            if (_isOpening)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(
                  color: _accent,
                  strokeWidth: 2,
                ),
              ),

            const Spacer(),

            // ── Action buttons ────────────────────────────────────────────────

            // Open PDF
            _ActionButton(
              icon: Icons.open_in_new_rounded,
              label: 'Open PDF Viewer',
              onTap: _openWithSystemViewer,
              isPrimary: true,
            ),
            const SizedBox(height: 12),

            // Share — WhatsApp / Email / Link
            _ActionButton(
              icon: Icons.share_rounded,
              label: _isSharing
                  ? 'Opening Share…'
                  : 'Share (WhatsApp / Email / Link)',
              onTap: _isSharing ? () {} : _share,
              isPrimary: false,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  static const _accent = Color(0xFFFD802E);

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _accent,
          side: const BorderSide(color: _accent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
