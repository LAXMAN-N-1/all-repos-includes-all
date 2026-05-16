import 'package:go_router/go_router.dart';
import '../presentation/screens/splash/new_splash_screen.dart';
import '../presentation/screens/home/new_home_screen.dart';
import '../presentation/screens/auth/login/advanced_user_login_screen.dart';
import '../presentation/screens/auth/signup/user_signup_screen.dart';
import '../presentation/screens/common/placeholder_screen.dart';
import '../presentation/widgets/layout/main_layout_wrapper.dart';
import '../presentation/screens/vendors/vendor_list/vendors_screen.dart';
import '../presentation/screens/booking/my_bookings/my_bookings_screen.dart';
import '../presentation/screens/profile/profile_hub/profile_screen.dart';
import '../presentation/screens/events/previous_events/previous_events_screen.dart';
import '../presentation/screens/vendors/verified_vendors_screen.dart';
import '../presentation/screens/vendors/vendor_profile/vendor_profile_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/booking/confirmation/booking_confirmation_screen.dart';
import '../presentation/screens/booking/finalize_booking/booking_details_screen.dart';
import '../presentation/screens/bidding/bid_selection_screen.dart';
import '../presentation/screens/bidding/create_request_screen.dart';
import '../presentation/screens/bidding/request_list_screen.dart';
import '../presentation/screens/bidding/request_detail_screen.dart';
import '../data/models/booking/booking_model.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String events = '/events';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String bookings = '/bookings';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const NewSplashScreen(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const AdvancedUserLoginScreen(),
      ),
      GoRoute(
        path: signup,
        builder: (context, state) => const UserSignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayoutWrapper(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const NewHomeScreen(),
          ),
          GoRoute(
            path: events,
            builder: (context, state) => const PreviousEventsScreen(),
          ),
          GoRoute(
             path: '/verified_vendors',
             builder: (context, state) => const VerifiedVendorsScreen(),
          ),
          GoRoute(
             path: '/vendor_profile',
             builder: (context, state) {
               // In a real app we'd pass an ID, but for this mock we pass the map via extra, or use null/default
               final vendorData = state.extra as Map<String, dynamic>? ?? {};
               return VendorProfileScreen(vendorData: vendorData);
             },
          ),
          GoRoute(
            path: notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
           GoRoute(
            path: settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: bookings,
            builder: (context, state) => const MyBookingsScreen(),
          ),
          GoRoute(
            path: '/book/:categoryId',
            builder: (context, state) {
              final categoryId = state.pathParameters['categoryId'] ?? 'General';
              return BookingDetailsScreen(categoryId: categoryId);
            },
          ),
          GoRoute(
            path: '/bids/:bookingId',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              return BidSelectionScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: '/confirm_booking/:bookingId',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              return BookingConfirmationScreen(bookingId: bookingId);
            },
          ),
          // Bidding Routes
          GoRoute(
            path: '/create-request',
            builder: (context, state) => const CreateRequestScreen(),
          ),
          GoRoute(
            path: '/request-list',
            builder: (context, state) => const RequestListScreen(),
          ),
          GoRoute(
            path: '/request-details/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? 0;
              final extra = state.extra as BookingModel?;
              return RequestDetailScreen(requestId: id, requestObj: extra);
            },
          ),
        ],
      ),
    ],
  );
}
