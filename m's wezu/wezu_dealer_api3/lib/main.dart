import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/swap_realtime_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase SDK (values baked in at build time via --dart-define)
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      debugPrint("✅ Supabase initialized");
    } catch (e) {
      debugPrint("⚠️ Supabase initialization failed: $e");
    }
  } else {
    debugPrint("⚠️ SUPABASE_URL or SUPABASE_ANON_KEY not set (pass via --dart-define)");
  }

  // Optimize Refresh Rate (120Hz on supported Android devices)
  try {
    if (ThemeData().platform == TargetPlatform.android) {
      await FlutterDisplayMode.setHighRefreshRate();
    }
  } catch (e) {
    debugPrint('Failed to set high refresh rate: $e');
  }

  // System UI Configuration: Transparent Status Bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: WezuDealerApp()));
}

class WezuDealerApp extends ConsumerWidget {
  const WezuDealerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authBootstrap = ref.watch(authBootstrapProvider);
    if (authBootstrap.isLoading) {
      return MaterialApp(
        title: 'WEZU Dealer Portal API3',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Bootstrap swap + station inventory real-time updates.
    ref.watch(swapRealtimeBootstrapProvider);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'WEZU Dealer Portal API3',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode:
          ThemeMode.dark, // Defaulting to dark as per typical luxury branding
      routerConfig: router,
    );
  }
}
