import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:customer_app/core/services/auth_service.dart';
import 'package:customer_app/features/auth/screens/login_screen.dart';
import 'package:customer_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:customer_app/core/services/cart_service.dart';
import 'package:customer_app/core/services/ai_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProxyProvider<CartService, AIService>(
          create: (context) => AIService(cart: Provider.of<CartService>(context, listen: false)),
          update: (context, cart, previous) => AIService(cart: cart),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraMed Pharmacy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6200EE),
            primary: const Color(0xFF6200EE),
            secondary: const Color(0xFF03DAC6)
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
            return const DashboardScreen();
        } else {
            return const LoginScreen();
        }
      },
    );
  }
}
