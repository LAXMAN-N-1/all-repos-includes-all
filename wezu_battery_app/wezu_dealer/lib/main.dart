import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optimize Refresh Rate (120Hz on supported Android devices)
  try {
    if (ThemeData().platform == TargetPlatform.android) {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  } catch (e) {
    debugPrint('Failed to set high refresh rate: $e');
  }

  // System UI Configuration: Transparent Status Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    const ProviderScope(
      child: WezuDealerApp(),
    ),
  );
}

class WezuDealerApp extends ConsumerWidget {
  const WezuDealerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authBootstrap = ref.watch(authBootstrapProvider);
    if (authBootstrap.isLoading) {
      return MaterialApp(
        title: 'WEZU Dealer Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'WEZU Dealer Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.dark, // Defaulting to dark as per typical luxury branding
      routerConfig: router,
    );
  }
}
