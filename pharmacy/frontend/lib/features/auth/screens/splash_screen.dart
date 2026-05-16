import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/common/aura_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Artificial delay for branding (optional, keep it short)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final authService = context.read<AuthService>();
    final isAuthenticated = await authService.isAuthenticated();

    if (!mounted) return;

    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/admin/dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuraLogo(size: 80, animate: true),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AuraColors.primary),
          ],
        ),
      ),
    );
  }
}
