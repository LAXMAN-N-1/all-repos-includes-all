import 'package:flutter/material.dart';
import '../../../../widgets/app_scanner.dart';

class ScannerView extends StatelessWidget {
  final String title;

  const ScannerView({super.key, this.title = 'Scan QR Code'});

  @override
  Widget build(BuildContext context) {
    return AppScanner(
      title: title,
      autoCloseOnScan: false,
      onScan: (code) {
        // Return the scanned code to the previous screen
        Navigator.of(context).pop(code);
      },
      showManualEntry: true,
      onManualEntry: () {
        // TODO: Show manual entry dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manual entry not implemented yet')),
        );
      },
    );
  }
}
