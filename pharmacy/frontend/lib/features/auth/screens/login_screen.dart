import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:frontend/core/common/aura_logo.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/admin/screens/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _showIntro = true; // State to control the 3s intro
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Play Intro Animation for 3 seconds, then show Login Form
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showIntro = false);
      }
    });
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.login(_emailController.text, _passwordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Welcome back to AuraMed!"),
            backgroundColor: AuraColors.primary,
          ),
        );
        
        // Navigate to Admin Dashboard via Shell
        Navigator.of(context).pushReplacementNamed('/admin/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Premium Dark Background
    return Scaffold(
      backgroundColor: AuraColors.background,
      body: Stack(
        children: [
          // 1. Ambient Background (Abstract Orbs)
          Positioned.fill(
             child: Container(
               color: AuraColors.background,
               child: Stack(
                 children: [
                    Positioned(
                      top: -150,
                      right: -100,
                      child: _buildOrb(AuraColors.primary),
                    ),
                    Positioned(
                      bottom: -150,
                      left: -100,
                      child: _buildOrb(AuraColors.secondary),
                    ),
                 ],
               ),
             ),
          ),

          // 2. Main Content
          Center(
            child: _showIntro 
              ? _buildIntroView() 
              : _buildLoginFormView(),
          ),
        ],
      ),
    );
  }

  // --- Intro View (Logo Only) ---
  Widget _buildIntroView() {
    return Center(
      child: Animate(
        effects: [
          FadeEffect(duration: 800.ms),
          ScaleEffect(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 2.seconds, curve: Curves.easeOutCubic),
          ShimmerEffect(duration: 1.seconds, delay: 2.seconds),
        ],
        child: AuraLogo(size: 150, animate: true),
      ),
    );
  }

  // --- Login Form View (Netflix Style Centered Card) ---
  Widget _buildLoginFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Center vertically
        children: [
          // Logo moves up slightly
          Animate(
             effects: [
               FadeEffect(duration: 600.ms),
               MoveEffect(begin: const Offset(0, -20), end: const Offset(0, 0), curve: Curves.easeOut),
             ],
             child: AuraLogo(size: 80, animate: false),
          ),

          const SizedBox(height: 40),

          // Glassmorphic Card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                // Max width for "Mobile Login at Center" feel on large screens
                constraints: const BoxConstraints(maxWidth: 400), 
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.7), // Slightly darker glass
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AuraColors.glassBorder.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Sign In",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Email or Phone",
                        prefixIcon: Icon(Icons.email_outlined),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.primary,
                        shadowColor: AuraColors.primary.withOpacity(0.5),
                        elevation: 10,
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Sign In"),
                    ),

                    const SizedBox(height: 20),
                    
                    // Footer Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {}, 
                          child: const Text("Need help?", style: TextStyle(color: Colors.white70, fontSize: 13))
                        ),
                        TextButton(
                          onPressed: () {}, 
                          child: const Text("New to AuraMed?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ).animate()
           .fadeIn(duration: 800.ms, delay: 200.ms) // Wait for logo to settle
           .moveY(begin: 50, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildOrb(Color color) {
    return Container(
      width: 450,
      height: 450,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 120,
            spreadRadius: 60,
          )
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 5.seconds);
  }
}
