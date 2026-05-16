import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'config/app_router.dart';
import 'config/app_constants.dart';
import 'config/app_scroll_behavior.dart';
import 'core/providers.dart';
import 'core/theme_provider.dart';
import 'features/inventory/providers/inventory_providers.dart';
import 'features/orders/providers/orders_providers.dart';
import 'services/storage_service.dart';
import 'services/offline_service.dart';
import 'widgets/theme_transition_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // maximize refresh rate on Android (skip on web)
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      const channel = MethodChannel('flutter_displaymode');
      await channel.invokeMethod('setHighRefreshRate');
    } catch (e) {
      // Fail silently if not supported
    }
  }

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize storage before app starts
  final storageService = await StorageService.init();
  await OfflineService.init();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the initialized storage instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const WezuLogisticsApp(),
    ),
  );
}

/// Root widget — uses ConsumerWidget so the router can reactively
/// rebuild on auth state changes (via routerProvider).
class WezuLogisticsApp extends ConsumerWidget {
  const WezuLogisticsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final amoledMode = ref.watch(amoledModeProvider);
    ref.watch(ordersRealtimeBootstrapProvider);
    ref.watch(inventoryRealtimeBootstrapProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ThemeTransitionWrapper(child: child!),
      theme: AppTheme.lightTheme,
      darkTheme: amoledMode ? AppTheme.amoledTheme : AppTheme.darkTheme,
      themeMode: themeMode,
      themeAnimationDuration:
          Duration.zero, // Disable global theme animation to prevent jitter
      routerConfig: router,
      scrollBehavior: AppScrollBehavior(),
    );
  }
}
