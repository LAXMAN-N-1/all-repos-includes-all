import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens
import 'ui/screens/splash_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/layout/main_layout.dart';
import 'ui/screens/dashboard/dashboard_screen.dart';
import 'ui/screens/notifications/notifications_screen.dart';
import 'ui/screens/settings/settings_screen.dart';

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
import 'ui/screens/events/requests/event_request_list_screen.dart';
import 'ui/screens/events/requests/event_request_detail_screen.dart';
import 'ui/screens/events/calendar/event_calendar_screen.dart';

// Vendors
import 'ui/screens/vendors/vendor_categories_screen.dart';
import 'ui/screens/vendors/vendor_list_screen.dart';
import 'ui/screens/vendors/add_vendor_screen.dart'; // Added
import 'ui/screens/vendors/vendor_management_screen.dart';
import 'ui/screens/vendors/verified_vendors_screen.dart';
import 'ui/screens/vendors/vendor_onboarding_screen.dart';
import 'ui/screens/vendors/vendor_approval_screen.dart';
import 'ui/screens/vendors/commission_management_screen.dart';
import 'ui/screens/vendors/payout_management_screen.dart';
import 'ui/screens/vendors/vendor_detail_screen.dart';
import 'data/models/vendor/vendor_admin_model.dart';

// Bidding
import 'ui/screens/bidding_dashboard_screen.dart'; // AdminBiddingDashboard
import 'ui/screens/bid_comparison_screen.dart';
import 'ui/screens/admin_bidding_screen.dart'; // AdminBiddingManagement
import 'ui/screens/event_bidding_details_screen.dart';
import 'ui/screens/vendor_bids_list_screen.dart';
import 'ui/screens/assigned_vendor_screen.dart';
import 'ui/screens/customer_bidding_screen.dart'; // CustomerBiddingView
import 'ui/screens/customer_top_vendors_view.dart'; // New
import 'ui/screens/bidding/bid_curation_screen.dart';

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


// Customer
import 'ui/screens/customers/customer_list_screen.dart';
import 'ui/screens/customers/customer_detail_screen.dart';
import 'ui/screens/customers/customer_analytics_screen.dart';

// Finance
import 'ui/screens/finance/financial_dashboard_screen.dart';
import 'ui/screens/finance/revenue_management_screen.dart';
import 'ui/screens/finance/payment_management_screen.dart';
import 'ui/screens/finance/refunds_disputes_screen.dart';
import 'ui/screens/finance/tax_management_screen.dart';

// Reports
import 'ui/screens/reports/analytics_dashboard_screen.dart';
import 'ui/screens/reports/custom_report_builder_screen.dart';
import 'ui/screens/reports/reports_landing_screen.dart';

// Marketing
import 'ui/screens/marketing/campaign_management_screen.dart';
import 'ui/screens/marketing/create_campaign_screen.dart';
import 'ui/screens/marketing/discount_management_screen.dart';

// Settings
import 'ui/screens/settings/general_settings_screen.dart';
import 'ui/screens/settings/platform_commission_screen.dart';
import 'ui/screens/settings/payment_gateway_settings_screen.dart';

// User Management
import 'ui/screens/users/admin_user_list_screen.dart';
import 'ui/screens/users/add_admin_user_screen.dart';
import 'ui/screens/users/role_permission_screen.dart';

// Notifications
import 'ui/screens/notifications/send_notification_screen.dart';
import 'ui/screens/notifications/alert_settings_screen.dart';

// Support
import 'ui/screens/support/support_ticket_dashboard_screen.dart';
import 'ui/screens/support/ticket_detail_screen.dart';

// Content Management
import 'ui/screens/content/categories/category_list_screen.dart';
import 'ui/screens/content/categories/add_category_screen.dart';
import 'ui/screens/content/banners/banner_list_screen.dart';
import 'ui/screens/content/banners/create_banner_screen.dart';
import 'ui/screens/content/email/email_template_list_screen.dart';

// Audit & Logs
import 'ui/screens/audit/activity_log_screen.dart';
import 'ui/screens/audit/login_history_screen.dart';
import 'ui/screens/audit/system_log_screen.dart';
import 'ui/screens/audit/audit_report_screen.dart';

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
      final isLoginRoute = state.matchedLocation == '/login';
      
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && (isLoginRoute || state.matchedLocation == '/')) return '/admin';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (context, state) => const DashboardScreen()),
          
          // Notifications & Settings
          GoRoute(path: '/admin/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/admin/settings', builder: (context, state) => const SettingsScreen()),
          
          // Organization
          GoRoute(path: '/admin/organization/branches', builder: (context, state) => const BranchManagementScreen()),
          GoRoute(path: '/admin/organization/branches/create', builder: (context, state) => const BranchCreateScreen()),
          GoRoute(path: '/admin/organization/roles', builder: (context, state) => const RoleManagementScreen()),
          GoRoute(path: '/admin/organization/users', builder: (context, state) => const UserManagementScreen()),
          
          // Events
          GoRoute(path: '/admin/events/categories', builder: (context, state) => const EventCategoriesScreen()),
          GoRoute(path: '/admin/events/types', builder: (context, state) => const EventTypesScreen()),
          GoRoute(path: '/admin/events/list', builder: (context, state) => const EventListScreen()),
          GoRoute(path: '/admin/events/managers', builder: (context, state) => const EventManagersScreen()),
          
          // Event Requests & Calendar
          GoRoute(path: '/admin/events/requests', builder: (context, state) => const EventRequestListScreen()),
          GoRoute(path: '/admin/events/calendar', builder: (context, state) => const EventCalendarScreen()),
          GoRoute(path: '/admin/events/:id', builder: (context, state) => EventRequestDetailScreen(requestId: state.pathParameters['id']!)),
          
          // Vendors
          GoRoute(path: '/admin/vendors/categories', builder: (context, state) => const VendorCategoriesScreen()),
          GoRoute(
            path: '/admin/vendors/list', 
            builder: (context, state) {
              final categoryId = int.tryParse(state.uri.queryParameters['category_id'] ?? '');
              return VendorListScreen(initialTab: 0, categoryId: categoryId);
            }
          ),
          GoRoute(path: '/admin/vendors/pending', builder: (context, state) => const VendorListScreen(initialTab: 1)),
          GoRoute(path: '/admin/vendors/active', builder: (context, state) => const VendorListScreen(initialTab: 2)),
          GoRoute(path: '/admin/vendors/inactive', builder: (context, state) => const VendorListScreen(initialTab: 3)),
          GoRoute(path: '/admin/vendors/add', builder: (context, state) => const AddVendorScreen()), // Added
          
          GoRoute(path: '/admin/vendors/management', builder: (context, state) => const VendorManagementScreen()),
          GoRoute(path: '/admin/vendors/verified', builder: (context, state) => const VerifiedVendorsScreen()),
          GoRoute(path: '/admin/vendors/onboarding', builder: (context, state) => const VendorOnboardingScreen()),
          GoRoute(path: '/admin/vendors/commission', builder: (context, state) => const CommissionManagementScreen()),
          GoRoute(path: '/admin/vendors/payouts', builder: (context, state) => const PayoutManagementScreen()),
          GoRoute(path: '/admin/vendors/details/:id', builder: (context, state) => VendorDetailScreen(vendorId: state.pathParameters['id']!)),
          GoRoute(
            path: '/vendors/approve/:id', 
            builder: (context, state) {
               final vendor = state.extra as AdminVendorModel?;
               final id = int.tryParse(state.pathParameters['id']!) ?? 0;
               return VendorApprovalScreen(vendorId: id, vendorCache: vendor);
            }
          ),

          
          // Bidding
          GoRoute(path: '/admin/bidding/dashboard', builder: (context, state) => const BiddingDashboardScreen()),
          GoRoute(path: '/admin/bidding/comparison/:eventId', builder: (context, state) => BidComparisonScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          GoRoute(path: '/admin/bidding/management', builder: (context, state) => const AdminBiddingScreen()),
          GoRoute(path: '/admin/bidding/event-details/:eventId', builder: (context, state) => EventBiddingDetailsScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          GoRoute(path: '/admin/bidding/vendor-bids/:eventId', builder: (context, state) => VendorBidsListScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          
          // NOTE: App.js uses :eventId, we use :bidId here as existing screen expects it. 
          // If strictly matching App.js, we would need to fetch bid by eventId inside screen.
          // Keeping consistent with existing logic for now.
          GoRoute(path: '/admin/bidding/assigned-vendor/:bidId', builder: (context, state) => AssignedVendorScreen(bidId: int.parse(state.pathParameters['bidId']!))),
          
          GoRoute(path: '/admin/bidding/customer-view/:eventId', builder: (context, state) => CustomerBiddingScreen(eventId: int.parse(state.pathParameters['eventId']!))),
          GoRoute(path: '/admin/bidding/top-vendors/:eventId', builder: (context, state) => CustomerTopVendorsView(eventId: int.parse(state.pathParameters['eventId']!))),
          
          // New Bidding Curation Route
          GoRoute(
            path: '/admin/bidding/curate/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? 0;
              return BidCurationScreen(requestId: id);
            },
          ),
          
          // Orders
          GoRoute(path: '/admin/orders/dashboard', builder: (context, state) => const OrderDashboardScreen()),
          GoRoute(path: '/admin/orders/quote/:id', builder: (context, state) => QuoteDetailsScreen(bidId: int.parse(state.pathParameters['id']!))), // Mapped id -> bidId
          GoRoute(path: '/admin/orders/quote-comparison/:orderId', builder: (context, state) => QuoteComparisonScreen(eventId: int.parse(state.pathParameters['orderId']!))), // Mapped orderId -> eventId/bidId context
          
          // Reports
          GoRoute(path: '/admin/reports/mis', builder: (context, state) => const MISDashboardScreen()),
          GoRoute(path: '/admin/reports/performance', builder: (context, state) => const PerformanceReportScreen()),
          GoRoute(path: '/admin/reports/financial-analysis', builder: (context, state) => const FinancialAnalysisScreen()),
          GoRoute(path: '/admin/reports/transactions', builder: (context, state) => const TransactionReportScreen()),
          GoRoute(path: '/admin/reports/collections', builder: (context, state) => const CollectionReportScreen()),
          
          // Access
          GoRoute(path: '/admin/access/roles-permissions', builder: (context, state) => const RoleManagementScreen()),

          // Customer Management
          GoRoute(path: '/admin/customers/list', builder: (context, state) => const CustomerListScreen()),
          GoRoute(path: '/admin/customers/analytics', builder: (context, state) => const CustomerAnalyticsScreen()),
          GoRoute(path: '/admin/customers/:id', builder: (context, state) => CustomerDetailScreen(customerId: state.pathParameters['id']!)),

          // Financial Management
          GoRoute(path: '/admin/finance/dashboard', builder: (context, state) => const FinancialDashboardScreen()),
          GoRoute(path: '/admin/finance/revenue', builder: (context, state) => const RevenueManagementScreen()),
          GoRoute(path: '/admin/finance/payments', builder: (context, state) => const PaymentManagementScreen()),
          GoRoute(path: '/admin/finance/refunds', builder: (context, state) => const RefundsDisputesScreen()),
          GoRoute(path: '/admin/finance/tax', builder: (context, state) => const TaxManagementScreen()),

          // Reports & Analytics
          GoRoute(path: '/admin/reports/dashboard', builder: (context, state) => const AnalyticsDashboardScreen()),
          GoRoute(path: '/admin/reports/builder', builder: (context, state) => const CustomReportBuilderScreen()),
          GoRoute(path: '/admin/reports/landing', builder: (context, state) => const ReportsLandingScreen()),

          // Marketing
          GoRoute(path: '/admin/marketing/campaigns', builder: (context, state) => const CampaignManagementScreen()),
          GoRoute(path: '/admin/marketing/campaigns/create', builder: (context, state) => const CreateCampaignScreen()),
          GoRoute(path: '/admin/marketing/discounts', builder: (context, state) => const DiscountManagementScreen()),

          // Settings
          GoRoute(path: '/admin/settings/general', builder: (context, state) => const GeneralSettingsScreen()),
          GoRoute(path: '/admin/settings/commission', builder: (context, state) => const PlatformCommissionScreen()),
          GoRoute(path: '/admin/settings/payments', builder: (context, state) => const PaymentGatewaySettingsScreen()),

          // User Management
          GoRoute(path: '/admin/organization/users', builder: (context, state) => const AdminUserListScreen()),
          GoRoute(path: '/admin/organization/users/add', builder: (context, state) => const AddAdminUserScreen()),
          GoRoute(path: '/admin/organization/roles', builder: (context, state) => const RolePermissionScreen()),

          // Notifications
          GoRoute(path: '/admin/notifications/send', builder: (context, state) => const SendNotificationScreen()),
          GoRoute(path: '/admin/notifications/alerts', builder: (context, state) => const AlertSettingsScreen()),

          // Support
          GoRoute(path: '/admin/support/dashboard', builder: (context, state) => const SupportTicketDashboardScreen()),
          GoRoute(path: '/admin/support/ticket/:id', builder: (context, state) => const TicketDetailScreen()),

          // Content Management
          GoRoute(path: '/admin/content/categories', builder: (context, state) => const CategoryListScreen()),
          GoRoute(path: '/admin/content/categories/add', builder: (context, state) => const AddEventCategoryScreen()),
          GoRoute(path: '/admin/content/banners', builder: (context, state) => const BannerListScreen()),
          GoRoute(path: '/admin/content/banners/create', builder: (context, state) => const CreateBannerScreen()),
          GoRoute(path: '/admin/content/email', builder: (context, state) => const EmailTemplateListScreen()),

          // Audit & Logs
          GoRoute(path: '/admin/audit/activity', builder: (context, state) => const ActivityLogScreen()),
          GoRoute(path: '/admin/audit/login', builder: (context, state) => const LoginHistoryScreen()),
          GoRoute(path: '/admin/audit/system', builder: (context, state) => const SystemLogScreen()),
          GoRoute(path: '/admin/audit/report', builder: (context, state) => const AuditReportScreen()),
        ],
      ),
    ],
  );
});


