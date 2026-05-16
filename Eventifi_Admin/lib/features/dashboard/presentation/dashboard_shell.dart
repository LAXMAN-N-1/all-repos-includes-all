import 'package:flutter/material.dart';
import 'package:eventifi_admin/features/dashboard/presentation/sidebar.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
           // Fixed Sidebar for Web
          const Sidebar(),
          // Main Content
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
