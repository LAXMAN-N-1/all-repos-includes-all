import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/splash_view_model.dart';
import 'screens/dashboard/dashboard_view_model.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/security_service.dart';
import 'services/storage_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/earnings_repository.dart';
import 'repositories/notification_repository.dart';
import 'repositories/wallet_repository.dart';
import 'repositories/payment_method_repository.dart';
import 'screens/wallet/wallet_view_model.dart';
import 'screens/auth/login_view_model.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WezuDeliveryApp());
}

class WezuDeliveryApp extends StatelessWidget {
  const WezuDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Core services ─────────────────────────────────────────────────────

        /// Single ApiService instance shared by all repositories.
        Provider<ApiService>(create: (_) => ApiService()),

        Provider<StorageService>(create: (_) => StorageService()),

        Provider<SecurityService>(create: (_) => SecurityService()),

        /// AuthService receives the shared ApiService.
        ProxyProvider<ApiService, AuthService>(
          create: (ctx) => AuthService(api: ctx.read<ApiService>()),
          update: (ctx, api, _) => AuthService(api: api),
        ),

        // ── Auth repository ───────────────────────────────────────────────────
        ChangeNotifierProxyProvider2<
          AuthService,
          StorageService,
          AuthRepository
        >(
          create: (ctx) => AuthRepository(
            authService: ctx.read<AuthService>(),
            storageService: ctx.read<StorageService>(),
          ),
          update: (ctx, auth, storage, repo) =>
              repo ??
              AuthRepository(authService: auth, storageService: storage),
        ),

        // ── Data repositories (all receive shared ApiService) ─────────────────
        ChangeNotifierProxyProvider<ApiService, OrderRepository>(
          create: (ctx) => OrderRepository(api: ctx.read<ApiService>()),
          update: (ctx, api, repo) => repo ?? OrderRepository(api: api),
        ),

        ChangeNotifierProxyProvider<ApiService, EarningsRepository>(
          create: (ctx) => EarningsRepository(api: ctx.read<ApiService>()),
          update: (ctx, api, repo) => repo ?? EarningsRepository(api: api),
        ),

        ChangeNotifierProxyProvider<ApiService, NotificationRepository>(
          create: (ctx) => NotificationRepository(api: ctx.read<ApiService>()),
          update: (ctx, api, repo) => repo ?? NotificationRepository(api: api),
        ),

        ChangeNotifierProvider(create: (_) => PaymentMethodRepository()),

        // ── Wallet repository (sync auth token) ───────────────────────────────
        ChangeNotifierProxyProvider<AuthRepository, WalletRepository>(
          create: (_) => WalletRepository(),
          update: (ctx, authRepo, walletRepo) {
            final repo = walletRepo ?? WalletRepository();
            // Sync the real JWT token from ApiService
            final token = ctx.read<ApiService>().authToken;
            repo.setAuthToken(authRepo.isAuthenticated ? token : '');
            return repo;
          },
        ),

        ChangeNotifierProxyProvider<WalletRepository, WalletViewModel>(
          create: (ctx) => WalletViewModel(),
          update: (ctx, walletRepo, vm) => vm ?? WalletViewModel(),
        ),

        // ── ViewModels ────────────────────────────────────────────────────────
        ChangeNotifierProxyProvider3<
          AuthRepository,
          StorageService,
          SecurityService,
          SplashViewModel
        >(
          create: (ctx) => SplashViewModel(
            authRepository: ctx.read<AuthRepository>(),
            storageService: ctx.read<StorageService>(),
            securityService: ctx.read<SecurityService>(),
          ),
          update: (ctx, authRepo, storage, security, vm) =>
              vm ??
              SplashViewModel(
                authRepository: authRepo,
                storageService: storage,
                securityService: security,
              ),
        ),

        ChangeNotifierProxyProvider<AuthRepository, LoginViewModel>(
          create: (ctx) =>
              LoginViewModel(authRepository: ctx.read<AuthRepository>()),
          update: (ctx, authRepo, vm) =>
              vm ?? LoginViewModel(authRepository: authRepo),
        ),

        ChangeNotifierProxyProvider4<
          OrderRepository,
          EarningsRepository,
          ApiService,
          StorageService,
          DashboardViewModel
        >(
          create: (ctx) => DashboardViewModel(
            orderRepository: ctx.read<OrderRepository>(),
            earningsRepository: ctx.read<EarningsRepository>(),
            api: ctx.read<ApiService>(),
            storage: ctx.read<StorageService>(),
          ),
          update: (ctx, orderRepo, earningsRepo, api, storage, vm) =>
              vm ??
              DashboardViewModel(
                orderRepository: orderRepo,
                earningsRepository: earningsRepo,
                api: api,
                storage: storage,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Wezu Delivery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
        routes: appRoutes,
      ),
    );
  }
}
