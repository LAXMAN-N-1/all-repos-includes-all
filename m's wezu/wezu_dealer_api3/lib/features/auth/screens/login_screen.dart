import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Animations
  late final AnimationController _scanLineController;
  late final AnimationController _formEntranceController;
  late final AnimationController _shakeController;
  late final AnimationController _pulseController;
  late final AnimationController _counterController;
  late final Animation<double> _scanLineAnimation;
  late final Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Scan line sweep (4s infinite)
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _scanLineAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.linear),
    );

    // Form entrance (staggered fade-in-up)
    _formEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Error shake
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.02, 0), end: const Offset(-0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(-0.02, 0), end: const Offset(0.015, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(0.015, 0), end: const Offset(-0.01, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(-0.01, 0), end: Offset.zero),
          weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    // Pulse for live dots
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // KPI counter animation
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scanLineController.dispose();
    _formEntranceController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both email and password'),
          backgroundColor: AppColors.redMuted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.red),
          ),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (mounted) {
      if (success) {
        final authState = ref.read(authProvider);
        if (authState.mustChangePassword) {
          context.go('/force-change-password');
        } else {
          context.go('/dashboard');
        }
      } else {
        _shakeController.forward(from: 0);
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Login failed'),
            backgroundColor: AppColors.redMuted,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppColors.red),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Row(
        children: [
          // ═══════════════════════════════════════════════════
          // LEFT BRAND PANEL
          // ═══════════════════════════════════════════════════
          if (isWide)
            Expanded(
              flex: 5,
              child: _BrandPanel(
                scanLineAnimation: _scanLineAnimation,
                pulseController: _pulseController,
                counterController: _counterController,
              ),
            ),

          // ═══════════════════════════════════════════════════
          // RIGHT AUTH PANEL
          // ═══════════════════════════════════════════════════
          Expanded(
            flex: isWide ? 4 : 1,
            child: SlideTransition(
              position: _shakeAnimation,
              child: Container(
                color: AppColors.shellBg,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildForm(authState),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _staggeredFadeIn(0,
            child: Text(
              'Welcome back',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 24),
            )),
        const SizedBox(height: 8),
        _staggeredFadeIn(1,
            child: Text(
              'Sign in to your dealer account',
              style: Theme.of(context).textTheme.bodyMedium,
            )),
        const SizedBox(height: 36),

        // Email
        _staggeredFadeIn(2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EMAIL ADDRESS',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'your@email.com',
                    prefixIcon: Icon(LucideIcons.mail,
                        color: AppColors.textTertiary, size: 18),
                  ),
                ),
              ],
            )),
        const SizedBox(height: 20),

        // Password
        _staggeredFadeIn(3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PASSWORD',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleLogin(),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(LucideIcons.lock,
                        color: AppColors.textTertiary, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(height: 16),

        // Remember me + Forgot
        _staggeredFadeIn(4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v!),
                        activeColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.textTertiary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Remember me',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            )),
        const SizedBox(height: 28),

        // Sign In Button
        _staggeredFadeIn(5,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : _handleLogin,
                child: authState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.pageBg,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Sign In',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            )),
        const SizedBox(height: 16),

        // OTP Login
        _staggeredFadeIn(6,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(LucideIcons.smartphone,
                    size: 16, color: AppColors.primary),
                label: const Text('Login with OTP',
                    style: TextStyle(color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                ),
                onPressed: () {},
              ),
            )),
        const SizedBox(height: 32),

        // Register Link
        _staggeredFadeIn(7,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Want to become a dealer? ',
                      style: Theme.of(context).textTheme.bodySmall),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('Apply Now',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _staggeredFadeIn(int index, {required Widget child}) {
    final delay = index * 0.1;
    final begin = delay;
    final end = (delay + 0.4).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _formEntranceController,
      builder: (context, _) {
        final t = Curves.easeOut.transform(
          (((_formEntranceController.value - begin) / (end - begin))
              .clamp(0.0, 1.0)),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BRAND PANEL — Left side of login
// ══════════════════════════════════════════════════════════════

class _BrandPanel extends StatelessWidget {
  final Animation<double> scanLineAnimation;
  final AnimationController pulseController;
  final AnimationController counterController;

  const _BrandPanel({
    required this.scanLineAnimation,
    required this.pulseController,
    required this.counterController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pageBg,
      child: Stack(
        children: [
          // Grid Pattern
          const _GridBackground(),
          // Radial circles
          const _RadialCircles(),
          // Scan line
          _ScanLine(animation: scanLineAnimation),
          // Floating particles
          const _FloatingParticles(),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 2),
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primaryGlow,
                    ),
                    child: const Icon(LucideIcons.batteryCharging,
                        size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 28),
                  Text('WEZU', style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 4),
                  Text(
                    'DEALER MANAGEMENT PORTAL',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Stat Pills
                  _StatPills(counterController: counterController),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid Background ─────────────────────────────────────────
class _GridBackground extends StatelessWidget {
  const _GridBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Dot intersections
    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Radial Circles ──────────────────────────────────────────
class _RadialCircles extends StatelessWidget {
  const _RadialCircles();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: const Size(500, 500),
        painter: _RadialPainter(),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 5; i++) {
      final paint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.03 * (6 - i) / 5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(center, i * 50.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Scan Line ───────────────────────────────────────────────
class _ScanLine extends AnimatedWidget {
  const _ScanLine({required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Align(
        alignment: Alignment(0, -1 + 2 * value),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0.6),
                AppColors.primary.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Floating Particles ──────────────────────────────────────
class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles();

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _particles = List.generate(12, (_) => _Particle.random());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ParticlePainter(_particles, _controller.value),
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double startY;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.startY,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory _Particle.random() {
    final rng = Random();
    return _Particle(
      x: rng.nextDouble(),
      startY: rng.nextDouble(),
      size: 1.5 + rng.nextDouble() * 2.5,
      speed: 0.3 + rng.nextDouble() * 0.7,
      opacity: 0.1 + rng.nextDouble() * 0.3,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = ((p.startY - progress * p.speed) % 1.2) * size.height;
      final paint = Paint()
        ..color = AppColors.primary.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x * size.width, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// ── Stat Pills ──────────────────────────────────────────────
class _StatPills extends StatelessWidget {
  final AnimationController counterController;
  const _StatPills({required this.counterController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: counterController,
      builder: (context, _) {
        final t = Curves.easeOut.transform(counterController.value);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pill(LucideIcons.battery, '${(1420 * t).toInt()}',
                'Active Batteries', AppColors.primary),
            const SizedBox(width: 12),
            _pill(LucideIcons.repeat, '${(890 * t).toInt()}', 'Current Rentals',
                AppColors.cyan),
            const SizedBox(width: 12),
            _pill(LucideIcons.indianRupee, '₹${(42500 * t).toInt()}',
                'Today\'s Revenue', AppColors.amber),
          ],
        );
      },
    );
  }

  Widget _pill(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 14)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
