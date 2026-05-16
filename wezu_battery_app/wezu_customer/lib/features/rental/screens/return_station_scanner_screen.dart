import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

class ReturnStationScannerScreen extends ConsumerStatefulWidget {
  final int? rentalId;

  const ReturnStationScannerScreen({super.key, this.rentalId});

  @override
  ConsumerState<ReturnStationScannerScreen> createState() =>
      _ReturnStationScannerScreenState();
}

class _ReturnStationScannerScreenState
    extends ConsumerState<ReturnStationScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final code = capture.barcodes.first.rawValue;
    if (code != null) {
      _processReturn(code);
    }
  }

  Future<void> _processReturn(String code) async {
    setState(() => _isProcessing = true);
    try {
      final dio = ref.read(authenticatedDioProvider);

      final stationId = _extractStationId(code);
      if (stationId == null) {
        throw Exception('Invalid station QR code.');
      }

      // Validate station exists and is reachable.
      final stationResponse = await dio.get('/stations/$stationId');
      if (stationResponse.statusCode != 200) {
        throw Exception('Station validation failed.');
      }

      // If rental id is known, complete return against backend.
      if (widget.rentalId != null) {
        final response = await dio.post(
          '/rentals/${widget.rentalId}/return',
          queryParameters: {'station_id': stationId},
        );
        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Unable to complete return at this station.');
        }
      }

      if (mounted) _showSuccessSheet();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
      }
    }
  }

  int? _extractStationId(String rawCode) {
    final code = rawCode.trim();
    final directId = int.tryParse(code);
    if (directId != null) return directId;

    final uri = Uri.tryParse(code);
    if (uri != null &&
        uri.scheme.toLowerCase() == 'wezu' &&
        uri.host.toLowerCase() == 'station') {
      final seg = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      return int.tryParse(seg);
    }

    final match =
        RegExp(r'station[/:-](\d+)', caseSensitive: false).firstMatch(code);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReturnSuccessSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          _buildScannerOverlay(),
          _buildTopBar(),
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: const ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppTheme.primaryBlue,
          borderRadius: 30,
          borderLength: 40,
          borderWidth: 12,
          cutOutSize: 280,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Scan Station QR",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Locate the QR code on the battery station",
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryBlue),
            const SizedBox(height: 24),
            Text(
              "Validating Station...",
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnSuccessSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: const Icon(LucideIcons.checkCircle,
                color: Colors.green, size: 64),
          ),
          const SizedBox(height: 32),
          Text("Return Handover Initiated",
              style: GoogleFonts.outfit(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            "Please insert the battery into Slot 04 at the station. Once locked, your deposit will be refunded.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: Text("Finish",
                style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.overlayColor = const Color(0x66000000),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final backgroundPath = Path()..addRect(rect);
    final cutOutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: rect.center, width: cutOutSize, height: cutOutSize),
        Radius.circular(borderRadius),
      ));

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutOutPath),
      Paint()..color = overlayColor,
    );

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final halfWidth = cutOutSize / 2;
    final halfHeight = cutOutSize / 2;
    final center = rect.center;

    // Top left
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - halfWidth, center.dy - halfHeight + borderLength)
        ..lineTo(center.dx - halfWidth, center.dy - halfHeight)
        ..lineTo(center.dx - halfWidth + borderLength, center.dy - halfHeight),
      paint,
    );

    // Top right
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + halfWidth - borderLength, center.dy - halfHeight)
        ..lineTo(center.dx + halfWidth, center.dy - halfHeight)
        ..lineTo(center.dx + halfWidth, center.dy - halfHeight + borderLength),
      paint,
    );

    // Bottom left
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - halfWidth, center.dy + halfHeight - borderLength)
        ..lineTo(center.dx - halfWidth, center.dy + halfHeight)
        ..lineTo(center.dx - halfWidth + borderLength, center.dy + halfHeight),
      paint,
    );

    // Bottom right
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + halfWidth - borderLength, center.dy + halfHeight)
        ..lineTo(center.dx + halfWidth, center.dy + halfHeight)
        ..lineTo(center.dx + halfWidth, center.dy + halfHeight - borderLength),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) => const QrScannerOverlayShape();
}
