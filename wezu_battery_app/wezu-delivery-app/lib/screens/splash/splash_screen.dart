import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/auth/auth_backdrop.dart';
import 'splash_view_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashViewModel _viewModel;
  late final AnimationController _entryController;
  late final AnimationController _ambientController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _startupTimer;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<SplashViewModel>(context, listen: false);
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..forward();
    _ambientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _performStartup();
  }

  Future<void> _performStartup() async {
    _startupTimer?.cancel();
    _startupTimer = Timer(const Duration(milliseconds: 1100), () async {
      try {
        final destination = await _viewModel.resolveStartupDestination();
        if (!mounted) return;

        final route = destination == SplashDestination.dashboard
            ? '/dashboard'
            : '/login';
        Navigator.of(context).pushReplacementNamed(route);
      } catch (e) {
        if (!mounted) return;
        _showErrorAndRetry(e.toString());
      }
    });
  }

  void _showErrorAndRetry(String error) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Startup Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _performStartup();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _startupTimer?.cancel();
    _entryController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AuthBackdrop(
          animation: _ambientController,
          child: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _entryController,
                builder: (_, __) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.92),
                                  Colors.white.withValues(alpha: 0.80),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.76),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 76,
                                  height: 76,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF0D47A1),
                                        Color(0xFF00897B),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Icon(
                                    Icons.local_shipping_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'WEZU',
                                  style: TextStyle(
                                    color: Color(0xFF0F1A32),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Delivery Partner',
                                  style: TextStyle(
                                    color: Color(0xFF5D6780),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0D47A1),
                                    strokeWidth: 2.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
