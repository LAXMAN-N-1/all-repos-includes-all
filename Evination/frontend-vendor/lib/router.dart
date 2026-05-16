import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/registration_screen.dart'; // Added
import 'ui/layout/main_layout.dart';
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/screens/notifications/notifications_screen.dart';
import 'ui/screens/settings/settings_screen.dart';
import 'ui/screens/kyc/kyc_verification_screen.dart';
import 'ui/screens/payments/payments_management_screen.dart';
import 'ui/screens/bidding/vendor_bidding_screen.dart';

// Onboarding
import 'ui/screens/onboarding/onboarding_layout.dart';
import 'ui/screens/onboarding/submission_success_screen.dart';

// Organizations
import 'ui/screens/organization/branch_management_screen.dart'; // List
import 'ui/screens/organization/branch_create_screen.dart';
import 'ui/screens/role_management_screen.dart';
import 'ui/screens/user_management_screen.dart'; // UserList

// Events
import 'ui/screens/event_categories_screen.dart';
import 'ui/screens/event_types_screen.dart';
import 'ui/screens/event_list_screen.dart';
import 'ui/screens/event_managers_screen.dart';

// Vendors
import 'ui/screens/vendors/vendor_categories_screen.dart';
import 'ui/screens/vendors/vendor_list_screen.dart';
import 'ui/screens/vendors/vendor_management_screen.dart';
import 'ui/screens/vendors/verified_vendors_screen.dart';
import 'ui/screens/vendors/vendor_onboarding_screen.dart';

// Bidding

import 'ui/screens/bid_comparison_screen.dart';
import 'ui/screens/admin_bidding_screen.dart'; // AdminBiddingManagement
import 'ui/screens/event_bidding_details_screen.dart';
import 'ui/screens/vendor_bids_list_screen.dart';
import 'ui/screens/bidding/vendor_event_details_screen.dart'; // New
import 'ui/screens/bidding/service_bid_screen.dart'; // New
import 'ui/screens/assigned_vendor_screen.dart';
import 'ui/screens/customer_bidding_screen.dart'; // CustomerBiddingView
import 'ui/screens/customer_top_vendors_view.dart'; // New
import 'ui/screens/leads/leads_list_screen.dart';
import 'ui/screens/leads/bid_submission_screen.dart';
import 'data/models/bidding/lead_model.dart';
import 'data/models/bidding_event_model.dart'; // Added for BiddingServiceRequest

// Orders
import 'ui/screens/order_dashboard_screen.dart';
import 'ui/screens/quote_details_screen.dart';
import 'ui/screens/quote_comparison_screen.dart';

// Reports
import 'ui/screens/mis_dashboard_screen.dart';
import 'ui/screens/performance_report_screen.dart';
import 'ui/screens/financial_analysis_screen.dart';
import 'ui/screens/transaction_report_screen.dart';
import 'ui/screens/collection_report_screen.dart';

// Access
import 'ui/screens/role_management_screen.dart'; // RolesPermissions reused

import 'logic/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Use a ValueNotifier to notify GoRouter of updates without rebuilding the router itself
  final authStateListenable = ValueNotifier<void>(null);

  // Listen to auth state changes and notify the router
  ref.listen(authStateProvider, (_, __) {
    authStateListenable.notifyListeners();
  });
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authStateListenable,
    redirect: (context, state) {
      if (state.matchedLocation == '/') return null;
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.asData?.value != null;
      final loc = state.matchedLocation;
      
      // Public routes that don't require login
      final isPublic = loc == '/login' || loc == '/register' || loc.startsWith('/onboarding');
      
      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && (loc == '/login' || loc == '/register' || loc == '/')) return '/vendor';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegistrationScreen()), // Added
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingLayout()),
      GoRoute(path: '/onboarding/success', builder: (context, state) => const SubmissionSuccessScreen()),
      
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(path: '/vendor', builder: (context, state) => const DashboardScreen()),
          
          // Notifications & Settings
          GoRoute(path: '/vendor/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/vendor/settings', builder: (context, state) => const SettingsScreen()),
          GoRoute(path: '/vendor/kyc', builder: (context, state) => const KYCVerificationScreen()),
          GoRoute(path: '/vendor/payments', builder: (context, state) => const PaymentsManagementScreen()),
          
          // Organization
          GoRoute(path: '/vendor/organization/branches', builder: (context, state) => const BranchManagementScreen()),
          GoRoute(path: '/vendor/organization/branches/create', builder: (context, state) => const BranchCreateScreen()),
          GoRoute(path: '/vendor/organization/roles', builder: (context, state) => const RoleManagementScreen()),
          GoRoute(path: '/vendor/organization/users', builder: (context, state) => const UserManagementScreen()),
          
          // Events
          GoRoute(path: '/vendor/events/categories', builder: (context, state) => const EventCategoriesScreen()),
          GoRoute(path: '/vendor/events/types', builder: (context, state) => const EventTypesScreen()),
          GoRoute(path: '/vendor/events/list', builder: (context, state) => const EventListScreen()),
          GoRoute(path: '/vendor/events/managers', builder: (context, state) => const EventManagersScreen()),
          
          // Vendors
          GoRoute(path: '/vendor/vendors/categories', builder: (context, state) => const VendorCategoriesScreen()),
          GoRoute(path: '/vendor/vendors/list', builder: (context, state) => const VendorListScreen()),
          GoRoute(path: '/vendor/vendors/management', builder: (context, state) => const VendorManagementScreen()),
          GoRoute(path: '/vendor/vendors/verified', builder: (context, state) => const VerifiedVendorsScreen()),
          GoRoute(path: '/vendor/vendors/onboarding', builder: (context, state) => const VendorOnboardingScreen()),
          
          // Bidding
          GoRoute(path: '/vendor/bidding/dashboard', builder: (context, state) => const VendorBiddingScreen()),
          GoRoute(path: '/vendor/bidding/active', builder: (context, state) => const VendorBiddingScreen()),
          GoRoute(path: '/vendor/bidding/history', builder: (context, state) => const VendorBiddingScreen()),
          GoRoute(path: '/vendor/bidding/comparison/:eventId', builder: (context, state) => BidComparisonScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          GoRoute(path: '/vendor/bidding/management', builder: (context, state) => const AdminBiddingScreen()),
          GoRoute(path: '/vendor/bidding/event-details/:eventId', builder: (context, state) => EventBiddingDetailsScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          GoRoute(path: '/vendor/bidding/vendor-bids/:eventId', builder: (context, state) => VendorBidsListScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          
          // NOTE: App.js uses :eventId, we use :bidId here as existing screen expects it. 
          // If strictly matching App.js, we would need to fetch bid by eventId inside screen.
          // Keeping consistent with existing logic for now.
          GoRoute(path: '/vendor/bidding/assigned-vendor/:bidId', builder: (context, state) => AssignedVendorScreen(bidId: int.parse(state.pathParameters['bidId']!))),
          
          GoRoute(path: '/vendor/bidding/customer-view/:eventId', builder: (context, state) => CustomerBiddingScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          GoRoute(path: '/vendor/bidding/top-vendors/:eventId', builder: (context, state) => CustomerTopVendorsView(eventId: int.parse(state.pathParameters['eventId']!))),
          
          // New Bidding Flow Routes
          GoRoute(path: '/vendor/bidding/bid-event-details/:eventId', builder: (context, state) => VendorEventDetailsScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          GoRoute(
            path: '/vendor/bidding/bid-service/:eventId', 
            builder: (context, state) {
              final eventId = int.parse(state.pathParameters['eventId']!);
              final service = state.extra as BiddingServiceRequest;
              return ServiceBidScreen(eventId: eventId, service: service);
            }
          ),

          GoRoute(path: '/leads', builder: (context, state) => const LeadsListScreen()),
          GoRoute(
            path: '/leads/bid/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? 0;
              final lead = state.extra as LeadModel?;
              return BidSubmissionScreen(bookingId: id, lead: lead);
            },
          ),
          
          // Orders
          GoRoute(path: '/vendor/orders/dashboard', builder: (context, state) => const OrderDashboardScreen()),
          GoRoute(path: '/vendor/orders/my-orders', builder: (context, state) => const OrderDashboardScreen()),
          GoRoute(path: '/vendor/orders/quote/:id', builder: (context, state) => QuoteDetailsScreen(bidId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/vendor/orders/quote-comparison/:orderId', builder: (context, state) => QuoteComparisonScreen(eventId: int.parse(state.pathParameters['orderId']!))),
          
          // Payments
          GoRoute(path: '/vendor/payments/overview', builder: (context, state) => const PaymentsManagementScreen()),
          GoRoute(path: '/vendor/payments/list', builder: (context, state) => const PaymentsManagementScreen()),

          // Business
          GoRoute(path: '/vendor/business/profile', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/vendor/business/categories', builder: (context, state) => const VendorCategoriesScreen()),

          // Analytics
          GoRoute(path: '/vendor/analytics/performance', builder: (context, state) => const PerformanceReportScreen()),
          GoRoute(path: '/vendor/analytics/revenue', builder: (context, state) => const FinancialAnalysisScreen()),

          // History
          GoRoute(path: '/vendor/activity/history', builder: (context, state) => const NotificationsScreen()),

          // Reports
          GoRoute(path: '/vendor/reports/mis', builder: (context, state) => const MISDashboardScreen()),
          GoRoute(path: '/vendor/reports/performance', builder: (context, state) => const PerformanceReportScreen()),
          GoRoute(path: '/vendor/reports/financial-analysis', builder: (context, state) => const FinancialAnalysisScreen()),
          GoRoute(path: '/vendor/reports/transactions', builder: (context, state) => const TransactionReportScreen()),
          GoRoute(path: '/vendor/reports/collections', builder: (context, state) => const CollectionReportScreen()),
          
          // Access
          GoRoute(path: '/vendor/access/roles-permissions', builder: (context, state) => const RoleManagementScreen()),
        ],
      ),
    ],
  );
});


