import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models/order_model.dart';
import 'screens/OTP verification/otp_verification_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/delivery/active_delivery_screen.dart';
import 'screens/delivery/delivery_verification_screen.dart';
import 'screens/documents/document_center_screen.dart';
import 'screens/earnings/earnings_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/kyc/kyc_screen.dart';
import 'screens/main_screen.dart';
import 'screens/menu/menu_info_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/orders/order_details_screen.dart';
import 'screens/orders/order_request_screen.dart';
import 'screens/profile/personal_information_screen.dart';
import 'screens/profile/vehicle_details_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/wallet/invoice_viewer_screen.dart';
import 'screens/wallet/payment_methods_screen.dart';
import 'screens/wallet/payout_request_screen.dart';
import 'screens/wallet/peer_transfer_screen.dart';
import 'screens/wallet/transaction_detail_screen.dart';
import 'screens/wallet/transaction_list_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/wallet/wallet_view_model.dart';
import 'screens/wallet/withdraw_to_bank_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/dashboard': (context) => const MainScreen(),
  '/login': (context) => const LoginScreen(),
  '/otp-verification': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! String || args.trim().isEmpty) {
      return _routeErrorScreen(
        context,
        message: 'Phone number missing. Please go back and try login again.',
      );
    }
    final phoneNumber = args.trim();
    return OtpVerificationScreen(phoneNumber: phoneNumber);
  },
  '/kyc-registration': (context) => const KycScreen(),

  // Delivery routes
  '/order-request': (context) => OrderRequestScreen(
    onAccept: (order) {
      Navigator.pushNamed(context, '/active-delivery', arguments: order);
    },
    onReject: () {
      Navigator.pop(context);
    },
  ),
  '/active-delivery': (context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    return ActiveDeliveryScreen(order: order);
  },
  '/delivery-verification': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? orderId;

    if (args is String) {
      orderId = args;
    } else if (args is Order) {
      orderId = args.id;
    } else if (args is Map<String, dynamic>) {
      orderId = args['orderId']?.toString();
    }

    return DeliveryVerificationScreen(orderId: orderId);
  },
  '/order-details': (context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order;
    return OrderDetailsScreen(order: order);
  },

  // Tabs and account surfaces
  '/earnings': (context) => const EarningsScreen(),
  '/help-support': (context) => const HelpSupportScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/notifications': (context) => const NotificationsScreen(),
  '/document-center': (context) => const DocumentCenterScreen(),
  '/profile/personal-info': (context) => const PersonalInformationScreen(),
  '/profile/vehicle-details': (context) => const VehicleDetailsScreen(),
  '/menu-info': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    return MenuInfoScreen(
      title: args['title'] ?? 'Info',
      description: args['description'] ?? '',
    );
  },

  // Wallet routes
  '/wallet': (context) => const WalletScreen(),
  '/withdraw-to-bank': (context) => const WithdrawToBankScreen(),
  '/payment-methods': (context) => const PaymentMethodsScreen(),
  '/payout-request': (context) => const PayoutRequestScreen(),
  '/invoice-viewer': (context) {
    if (kIsWeb) {
      return _routeErrorScreen(
        context,
        message:
            'Receipt viewer is not supported in web preview. Use download instead.',
      );
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Map<String, dynamic>) {
      return _routeErrorScreen(
        context,
        message: 'Invoice payload is missing. Please retry from transaction.',
      );
    }
    final file = args['file'];
    final title = args['title']?.toString() ?? 'Invoice';
    if (file is! File) {
      return _routeErrorScreen(
        context,
        message: 'Invoice file is unavailable. Please download again.',
      );
    }
    return InvoiceViewerScreen(pdfFile: file, invoiceTitle: title);
  },
  '/peer-transfer': (context) => const PeerTransferScreen(),
  '/transaction-detail': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! WalletTransaction) {
      return _routeErrorScreen(
        context,
        message: 'Transaction details are unavailable. Please open it again.',
      );
    }
    final txn = args;
    return TransactionDetailScreen(transaction: txn);
  },
  '/transaction-list': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final filter = args is TransactionFilter ? args : TransactionFilter.all;
    return TransactionListScreen(filter: filter);
  },
};

Widget _routeErrorScreen(BuildContext context, {required String message}) {
  final theme = Theme.of(context);
  return Scaffold(
    appBar: AppBar(title: const Text('Route Error')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    ),
  );
}
