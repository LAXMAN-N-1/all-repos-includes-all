import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/battery.dart';
import 'rental_confirmation_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';
import '../../../core/network/dio_provider.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  final Battery expectedBattery;

  const QRScannerScreen({super.key, required this.expectedBattery});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isVerifying = false;
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isVerifying || _isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _verifyBattery(code);
      }
    }
  }

  Future<void> _verifyBattery(String code) async {
    if (_isProcessing) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _isProcessing = true;
    });

    try {
      // 5-second maximum verification time as per FR-MOB-RENT-006
      await Future.any([
        _performVerification(code),
        Future.delayed(const Duration(seconds: 5)).then(
            (_) => throw Exception("Verification timed out after 5 seconds.")),
      ]);

      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = e.toString().contains("timed out")
              ? "Timeout Error: Please scan again in better lighting."
              : "Scan Error: Scanned item does not match selected battery.";
          _isProcessing = false;
        });
      }
    }
  }

  Future<bool> _performVerification(String code) async {
    try {
      final dio = ref.read(authenticatedDioProvider);

      final response = await dio.post('/batteries/qr/verify', data: {
        'qr_data': code,
      });

      if (response.statusCode == 200 &&
          response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        final scannedBatteryId = (data['battery_id'] as num?)?.toInt();
        final scannedSerial = data['serial_number']?.toString();
        final isMatch = (scannedBatteryId != null &&
                scannedBatteryId == widget.expectedBattery.id) ||
            (scannedSerial != null &&
                scannedSerial == widget.expectedBattery.serialNumber);
        if (isMatch) {
          return true;
        }
      }
      throw Exception("Mismatch");
    } catch (e) {
      if (code == widget.expectedBattery.qrCodeData ||
          code == widget.expectedBattery.serialNumber) {
        return true;
      }
      throw Exception("Verification failed: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 48),
            SizedBox(height: 16),
            Text('Battery Verified',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Serial: ${widget.expectedBattery.serialNumber}\nModel: ${widget.expectedBattery.modelNumber}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Pop dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RentalConfirmationScreen(battery: widget.expectedBattery),
                ),
              );
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('PROCEED TO PAYMENT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildScannerView(context),
          _buildOverlay(),
          _buildTopBar(context),
          if (_isVerifying) _buildVerifyingOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerView(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: _onDetect,
      errorBuilder: (context, error) {
        return const Center(
          child: Text(
            'Check camera permissions',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Column(
        children: [
          const Text(
            'Scan QR code on the battery',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Expected Serial: ${widget.expectedBattery.serialNumber}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () => controller.toggleTorch(),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: () => controller.switchCamera(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryBlue),
            SizedBox(height: 24),
            Text(
              'Verifying Battery...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
