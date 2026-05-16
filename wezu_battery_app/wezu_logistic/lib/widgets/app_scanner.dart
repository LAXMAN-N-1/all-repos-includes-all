import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/app_colors.dart';

/// A consolidated, feature-rich scanner widget.
///
/// Supports:
/// - Single or Continuous scanning
/// - Haptic feedback
/// - Async validation with visual feedback (Green/Red overlay)
/// - Manual code entry fallback
/// - Flash and Camera switching
class AppScanner extends StatefulWidget {
  const AppScanner({
    super.key,
    required this.onScan,
    this.title = 'Scan QR Code',
    this.subtitle = 'Align QR code within the frame',
    this.continuous = false,
    this.autoCloseOnScan = true,
    this.onValidate,
    this.onManualEntry,
    this.showManualEntry = false,
  });

  /// Callback when a code is successfully scanned (and validated if applicable).
  final ValueChanged<String> onScan;

  /// Title displayed at the top of the overlay.
  final String title;

  /// Subtitle displayed at the bottom of the overlay.
  final String subtitle;

  /// If true, the scanner will not close after a successful scan.
  /// Useful for batch operations.
  final bool continuous;

  /// When `continuous` is false, controls whether this widget closes itself
  /// after a successful scan.
  final bool autoCloseOnScan;

  /// Optional async validation.
  /// If provided, the scanner will pause, show a loading/validation state,
  /// and only call [onScan] if validation returns true.
  /// Returns true if valid, false otherwise.
  final Future<bool> Function(String code)? onValidate;

  /// Callback for manual entry button.
  final VoidCallback? onManualEntry;

  /// Whether to show the manual entry button.
  final bool showManualEntry;

  @override
  State<AppScanner> createState() => _AppScannerState();
}

class _AppScannerState extends State<AppScanner> with WidgetsBindingObserver {
  late MobileScannerController _controller;

  bool _isProcessing = false;
  bool? _lastValidationResult; // true = success, false = error, null = none
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
      formats: [
        BarcodeFormat.qrCode,
        BarcodeFormat.dataMatrix,
      ], // Optimize for battery codes
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Restart camera on resume to prevent freeze
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
  }

  Future<void> _handleScan(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Debounce duplicate scans of the exact same code in quick succession if validation failed
    // (Optional logic, can be adjusted)

    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
    });

    HapticFeedback.mediumImpact();

    bool isValid = true;

    // Create a minimum delay to show feedback if validation is instant
    final minDelay = Future.delayed(const Duration(milliseconds: 500));

    try {
      if (widget.onValidate != null) {
        isValid = await widget.onValidate!(code);
      }
    } catch (e) {
      isValid = false;
    }

    await minDelay; // Ensure user sees the processing state

    if (mounted) {
      setState(() {
        _lastValidationResult = isValid;
      });

      if (isValid) {
        // Success Feedback
        HapticFeedback.heavyImpact();

        // Trigger callback
        widget.onScan(code);

        if (!widget.continuous) {
          await Future.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;

          if (widget.autoCloseOnScan) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _isProcessing = false;
              _lastValidationResult = null;
              _lastScannedCode = null;
            });
          }
        } else {
          // Continuous: Reset state after success feedback
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _lastValidationResult = null;
              _lastScannedCode = null;
            });
          }
        }
      } else {
        // Error Feedback
        HapticFeedback.vibrate(); // Method might vary, usually medium again or specific pattern

        // Reset after error feedback
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _lastValidationResult = null;
            // Don't clear lastScannedCode immediately effectively "ignoring" it for a moment?
            // Or clear it to allow rescan. Let's clear it.
            _lastScannedCode = null;
          });
        }
      }
    }
  }

  Color get _borderColor {
    if (_isProcessing) {
      if (_lastValidationResult == true) return AppColors.success;
      if (_lastValidationResult == false) return AppColors.error;
      return Colors.white; // Loading
    }
    return AppColors.primary; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleScan,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Error',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    Text(
                      error.errorCode.toString(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),

          // Scanner Overlay (Darkened Background + Cutout)
          CustomPaint(
            painter: _ScannerOverlayPainter(
              borderColor: _borderColor,
              borderRadius: 16,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: 280,
            ),
            child: Container(),
          ),

          // Validation / Status Message
          if (_isProcessing && _lastScannedCode != null)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 200), // Below the cutout
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_lastValidationResult == null)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else if (_lastValidationResult == true)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        )
                      else
                        const Icon(
                          Icons.error,
                          color: AppColors.error,
                          size: 20,
                        ),

                      const SizedBox(width: 8),
                      Text(
                        _lastValidationResult == null
                            ? 'Verifying...'
                            : (_lastValidationResult == true
                                  ? 'Success'
                                  : 'Invalid Code'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top Controls (Back, Flash, Flip)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ), // Standard back
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        shape: const CircleBorder(),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Row(
                      children: [
                        // Flash
                        ValueListenableBuilder(
                          valueListenable: _controller,
                          builder: (context, state, child) {
                            return IconButton(
                              icon: Icon(
                                state.torchState == TorchState.on
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                                color: Colors.white,
                              ),
                              onPressed: () => _controller.toggleTorch(),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black26,
                                shape: const CircleBorder(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls (Subtitle & Manual Entry)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                    if (widget.showManualEntry &&
                        widget.onManualEntry != null) ...[
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: widget.onManualEntry,
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Enter Code Manually'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  _ScannerOverlayPainter({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shorterSide = size.width < size.height ? size.width : size.height;
    final scanAreaSize = cutOutSize > shorterSide
        ? shorterSide - 40
        : cutOutSize;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    final double right = left + scanAreaSize;
    final double bottom = top + scanAreaSize;

    // Background mask
    final backgroundPaint = Paint()..color = Colors.black54;
    final cutOutRect = Rect.fromLTRB(left, top, right, bottom);

    // Draw background with cutout
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
    canvas.drawRect(cutOutRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Borders
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Top left
    path.moveTo(left, top + borderLength);
    path.lineTo(left, top + borderRadius);
    path.quadraticBezierTo(left, top, left + borderRadius, top);
    path.lineTo(left + borderLength, top);

    // Top right
    path.moveTo(right - borderLength, top);
    path.lineTo(right - borderRadius, top);
    path.quadraticBezierTo(right, top, right, top + borderRadius);
    path.lineTo(right, top + borderLength);

    // Bottom right
    path.moveTo(right, bottom - borderLength);
    path.lineTo(right, bottom - borderRadius);
    path.quadraticBezierTo(right, bottom, right - borderRadius, bottom);
    path.lineTo(right - borderLength, bottom);

    // Bottom left
    path.moveTo(left + borderLength, bottom);
    path.lineTo(left + borderRadius, bottom);
    path.quadraticBezierTo(left, bottom, left, bottom - borderRadius);
    path.lineTo(left, bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.cutOutSize != cutOutSize;
  }
}
