class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: "http://localhost:8000/api",
  );

  // Auth
  static const String signup = "/customer/auth/signup";
  static const String login = "/customer/auth/login";
  static const String logout = "/auth/logout"; // Likely shared or needs admin-auth logout? keeping generic for now or removing if not used

  // Events & Categories (Admin Managed)
  static const String categories = "/categories/";

  // Bookings
  static const String bookings = "/bookings/";
  static const String myBookings = "/bookings/"; // Unified list endpoint

  // Vendors
  static const String vendors = "/vendors/";
  static const String vendorProfile = "/vendors/me/profile";

  // Bids
  static const String bids = "/bids/";
  static String customerBidding(int eventId) => "/customer/bidding/$eventId";
  static String customerAcceptBid(int bidId) => "/customer/bidding/$bidId/accept";

  // Analytics
  static const String stats = "/analytics/stats";

  // Notifications
  static const String notifications = "/notifications/";
}
