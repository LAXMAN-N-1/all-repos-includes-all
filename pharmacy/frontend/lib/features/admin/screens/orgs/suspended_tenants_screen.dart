import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/core/theme/app_theme.dart';

class SuspendedTenantsScreen extends StatelessWidget {
  const SuspendedTenantsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Suspended Organizations",
            style: GoogleFonts.outfit(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Manage tenants with restricted access due to policy violation or non-payment.",
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.block_flipped, size: 64, color: Colors.white10),
                   SizedBox(height: 16),
                   Text("No suspended organizations found.", style: TextStyle(color: Colors.white30))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
