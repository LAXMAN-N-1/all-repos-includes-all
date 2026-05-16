import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/storage/storage_service.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/services/admin_service.dart';

import 'package:frontend/features/auth/screens/login_screen.dart';
import 'package:frontend/features/admin/screens/admin_shell.dart';
import 'package:frontend/features/auth/screens/splash_screen.dart';

// ... other imports ...

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>(create: (_) => StorageService()),
        ProxyProvider<StorageService, ApiClient>(
          update: (_, storage, __) => ApiClient(storage),
        ),
        ProxyProvider2<ApiClient, StorageService, AuthService>(
          update: (_, apiClient, storage, __) => AuthService(apiClient, storage),
        ),
        ProxyProvider<ApiClient, AdminService>(
          update: (_, apiClient, __) => AdminService(apiClient),
        ),
      ],
      child: const AuraMedApp(),
    ),
  );
}

class AuraMedApp extends StatelessWidget {
  const AuraMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraMed Pharmacy ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Default to Premium Dark Mode
      home: const SplashScreen(),
      routes: {
        '/auth/login': (context) => const LoginScreen(),
        // Admin Shell Entry - This handles all /admin/* routes internally via nested navigator
        '/admin/dashboard': (context) => const AdminShell(initialRoute: '/admin/dashboard'),
      },
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/admin')) {
             return MaterialPageRoute(
               builder: (context) => AdminShell(initialRoute: settings.name!),
               settings: settings
             );
        }
        return null;
      },
    );
  }
}
