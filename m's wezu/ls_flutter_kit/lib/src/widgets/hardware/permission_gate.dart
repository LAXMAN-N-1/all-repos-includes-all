import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Ensures required permissions are granted before rendering its child.
/// Shows a rationale screen if permissions are denied or permanently denied.
class PermissionGate extends StatefulWidget {
  final List<Permission> requiredPermissions;
  final Widget child;
  final String rationaleTitle;
  final String rationaleMessage;
  final Widget? rationaleIcon;

  const PermissionGate({
    super.key,
    required this.requiredPermissions,
    required this.child,
    this.rationaleTitle = 'Permission Required',
    this.rationaleMessage = 'To provide you with the best experience, this app needs access to your device capabilities.',
    this.rationaleIcon,
  });

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> with WidgetsBindingObserver {
  bool _isChecking = true;
  bool _isGranted = false;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPermanentlyDenied) {
      _checkPermissions(); // Re-check if user comes back from settings
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isChecking = true);
    
    bool allGranted = true;
    bool anyPermanentlyDenied = false;

    for (final perm in widget.requiredPermissions) {
      final status = await perm.status;
      if (!status.isGranted) {
        allGranted = false;
      }
      if (status.isPermanentlyDenied) {
        anyPermanentlyDenied = true;
      }
    }

    if (mounted) {
      setState(() {
        _isGranted = allGranted;
        _isPermanentlyDenied = anyPermanentlyDenied;
        _isChecking = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (_isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    final statuses = await widget.requiredPermissions.request();
    bool allGranted = statuses.values.every((status) => status.isGranted);
    bool anyPermanentlyDenied = statuses.values.any((status) => status.isPermanentlyDenied);

    if (mounted) {
      setState(() {
        _isGranted = allGranted;
        _isPermanentlyDenied = anyPermanentlyDenied;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isGranted) {
      return widget.child;
    }

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.rationaleIcon != null) ...[
                widget.rationaleIcon!,
                const SizedBox(height: 32),
              ] else ...[
                Icon(Icons.security, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 32),
              ],
              Text(
                widget.rationaleTitle,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.rationaleMessage,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: _requestPermissions,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(
                  _isPermanentlyDenied ? 'Open Settings' : 'Grant Permissions',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
