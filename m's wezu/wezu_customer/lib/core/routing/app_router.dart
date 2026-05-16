import 'package:flutter/material.dart';
import 'package:wezu_customer_app/features/auth/screens/forgot_password_screen.dart';
import 'package:wezu_customer_app/features/auth/screens/login_screen.dart';
import 'package:wezu_customer_app/features/auth/screens/login_two_factor_otp_screen.dart';
import 'package:wezu_customer_app/features/auth/screens/otp_screen.dart';
import 'package:wezu_customer_app/features/auth/screens/registration_screen.dart';
import 'package:wezu_customer_app/features/auth/screens/reset_password_screen.dart';
import 'package:wezu_customer_app/features/auth/screens/splash_screen.dart';
import 'package:wezu_customer_app/features/auth/screens/welcome_screen.dart';
import 'package:wezu_customer_app/features/dashboard/widgets/main_layout.dart';
import 'package:wezu_customer_app/features/payment/screens/manage_payment_methods_screen.dart';
import 'package:wezu_customer_app/features/payment/screens/send_money_screen.dart';
import 'package:wezu_customer_app/features/payment/screens/transaction_history_screen.dart';
import 'package:wezu_customer_app/features/payment/screens/wallet_screen.dart';
import 'package:wezu_customer_app/features/payment/screens/withdraw_to_bank_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/add_address_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/addresses_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/language_settings_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/legal_document_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/kyc_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/notification_preferences_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/personal_info_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/security_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/two_factor_otp_screen.dart';
import 'package:wezu_customer_app/features/purchase/screens/purchase_history_screen.dart';
import 'package:wezu_customer_app/features/rental/screens/my_rentals_screen.dart';
import 'package:wezu_customer_app/features/support/screens/support_screen.dart';
import 'package:wezu_customer_app/features/wallet/models/subscription_plan.dart';
import 'package:wezu_customer_app/features/wallet/screens/subscription_management_screen.dart';
import 'package:wezu_customer_app/features/wallet/screens/subscription_purchase_screen.dart';
import 'package:wezu_customer_app/features/wallet/screens/wezu_pass_screen.dart';
import 'package:wezu_customer_app/features/profile/screens/change_password_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String payments = '/payments';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String kyc = '/kyc';
  static const String security = '/security';
  static const String twoFactorSetupOtp = '/2fa-setup-otp';
  static const String loginTwoFactor = '/login-2fa';
  static const String personalInfo = '/personal-info';
  static const String notifications = '/notification-preferences';
  static const String language = '/language-settings';
  static const String addresses = '/addresses';
  static const String addAddress = '/add-address';
  static const String myRentals = '/my-rentals';
  static const String myPurchases = '/my-purchases';
  static const String helpCenter = '/help-center';
  static const String terms = '/terms-of-service';
  static const String privacy = '/privacy-policy';
  static const String sendMoney = '/send-money';
  static const String withdraw = '/withdraw';
  static const String paymentMethods = '/payment-methods';
  static const String transactions = '/transactions';
  static const String wezuPass = '/wezu-pass';
  static const String subscriptionPurchase = '/subscription-purchase';
  static const String subscriptionManagement = '/subscription-management';
  static const String changePassword = '/change-password';
}

class AppRouter {
  const AppRouter._();

  static const String initialRoute = AppRoutes.splash;

  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegistrationScreen(),
        AppRoutes.home: (context) => const MainLayout(),
        AppRoutes.payments: (context) => const WalletScreen(),
        AppRoutes.verifyOtp: _buildVerifyOtpScreen,
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.resetPassword: _buildResetPasswordScreen,
        AppRoutes.kyc: (context) => const KYCScreen(),
        AppRoutes.security: (context) => const SecurityScreen(),
        AppRoutes.twoFactorSetupOtp: (context) => const TwoFactorOtpScreen(),
        AppRoutes.loginTwoFactor: (context) => const LoginTwoFactorOtpScreen(),
        AppRoutes.personalInfo: (context) => const PersonalInfoScreen(),
        AppRoutes.notifications: (context) =>
            const NotificationPreferencesScreen(),
        AppRoutes.language: (context) => const LanguageSettingsScreen(),
        AppRoutes.addresses: (context) => const AddressesScreen(),
        AppRoutes.addAddress: (context) => const AddAddressScreen(),
        AppRoutes.myRentals: (context) => const MyRentalsScreen(),
        AppRoutes.myPurchases: (context) => const PurchaseHistoryScreen(),
        AppRoutes.helpCenter: (context) => const SupportScreen(),
        AppRoutes.terms: (context) => LegalDocumentScreen.terms(),
        AppRoutes.privacy: (context) => LegalDocumentScreen.privacy(),
        AppRoutes.sendMoney: (context) => const SendMoneyScreen(),
        AppRoutes.withdraw: (context) => const WithdrawToBankScreen(),
        AppRoutes.paymentMethods: (context) =>
            const ManagePaymentMethodsScreen(),
        AppRoutes.transactions: (context) => const TransactionHistoryScreen(),
        AppRoutes.wezuPass: (context) => const WezuPassScreen(),
        AppRoutes.subscriptionPurchase: _buildSubscriptionPurchaseScreen,
        AppRoutes.subscriptionManagement: (context) =>
            const SubscriptionManagementScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
      };

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => UnknownRouteScreen(routeName: settings.name),
    );
  }

  static Widget _buildVerifyOtpScreen(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map<String, dynamic> ? rawArgs : null;
    return OTPScreen(
      target: args?['target'] ?? '',
      isRegistration: args?['purpose'] == 'registration',
    );
  }

  static Widget _buildResetPasswordScreen(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final email = rawArgs is String ? rawArgs : '';
    return ResetPasswordScreen(email: email);
  }

  static Widget _buildSubscriptionPurchaseScreen(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final plan = rawArgs is SubscriptionPlan ? rawArgs : null;
    return SubscriptionPurchaseScreen(
      selectedPlan: plan ?? SubscriptionPlan.mockDaily(),
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key, this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.route_outlined, size: 40),
              const SizedBox(height: 12),
              Text('Route not found: ${routeName ?? "unknown"}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
