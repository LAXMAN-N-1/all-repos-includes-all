/// Supabase project credentials.
///
/// These values are safe to ship in client code — they are the *public*
/// project URL and anon (publishable) key.  Row-Level Security (RLS) on
/// your Supabase tables is the real security boundary.
///
/// To override at build time:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://fxmkfxnqozvgajvjrwim.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4bWtmeG5xb3p2Z2Fqdmpyd2ltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3OTk4OTEsImV4cCI6MjA5MjM3NTg5MX0.RB3ErgYq3hy-VppTwre_QfP3QBrDwDP6XsZrhe_yiWs',
  );

  /// Auth provider toggles.
  ///
  /// Keep these aligned with Supabase Auth providers in production.
  /// Override per build with `--dart-define` if needed.
  static const bool phoneAuthEnabled = bool.fromEnvironment(
    'SUPABASE_PHONE_AUTH_ENABLED',
    defaultValue: false,
  );
  static const bool googleAuthEnabled = bool.fromEnvironment(
    'SUPABASE_GOOGLE_AUTH_ENABLED',
    defaultValue: false,
  );
  static const bool appleAuthEnabled = bool.fromEnvironment(
    'SUPABASE_APPLE_AUTH_ENABLED',
    defaultValue: false,
  );

  /// Deep-link scheme used for OAuth redirects (must match your Supabase
  /// project's "Redirect URLs" setting and your app's URL scheme).
  static const String authRedirectScheme = 'wezu';
  static const String authRedirectUri = '$authRedirectScheme://login-callback';
}
