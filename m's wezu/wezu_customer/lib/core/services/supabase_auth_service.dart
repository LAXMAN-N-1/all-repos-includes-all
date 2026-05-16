import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Singleton Supabase client — initialized once in main.dart.
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

/// Production-ready Supabase auth service.
final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService(ref.watch(supabaseClientProvider));
});

// ─── Service ──────────────────────────────────────────────────────────────────

/// Production-ready Supabase Authentication Service.
///
/// Responsibilities:
///  • Email OTP (passwordless magic-link / OTP sign-in)
///  • Phone OTP sign-in
///  • Email + password sign-up / sign-in
///  • Google OAuth (native iOS/Android, web redirect)
///  • Apple Sign-In (iOS/macOS native; falls back gracefully on Android)
///  • Secure password reset
///  • Session refresh with expiry-aware token retrieval
///  • Full sign-out (local + server)
///
/// After a successful Supabase auth, pass the session access token to your
/// backend's canonical identity endpoint (`GET /api/v1/auth/me`) for profile
/// introspection and app-level authorization.
class SupabaseAuthService {
  final SupabaseClient _supabase;

  SupabaseAuthService(this._supabase);

  // ─── Accessors ──────────────────────────────────────────────────────────

  SupabaseClient get client => _supabase;
  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentSession != null;

  /// Emits every auth-state change (signed in, signed out, token refreshed…).
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ─── Email OTP (passwordless) ────────────────────────────────────────────

  /// Send a one-time-password to [email].
  ///
  /// Set [shouldCreateUser] to `false` to disallow unknown email sign-ups.
  Future<void> sendEmailOtp(
    String email, {
    bool shouldCreateUser = true,
  }) async {
    _validate(email.trim().isNotEmpty, 'Email must not be empty.');
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: shouldCreateUser,
        emailRedirectTo: kIsWeb ? null : SupabaseConfig.authRedirectUri,
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  /// Verify the OTP sent to [email] and return the resulting auth response.
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    _validate(email.trim().isNotEmpty, 'Email must not be empty.');
    _validate(otp.trim().isNotEmpty, 'OTP must not be empty.');
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email.trim(),
        token: otp.trim(),
      );
      _requireSession(response, 'Email OTP verification');
      return response;
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  // ─── Phone OTP ───────────────────────────────────────────────────────────

  /// Send an SMS OTP to [phone] (must be E.164 format, e.g. +919876543210).
  ///
  /// Set [shouldCreateUser] to `false` to disallow unknown number sign-ups.
  Future<void> sendPhoneOtp(
    String phone, {
    bool shouldCreateUser = true,
  }) async {
    _validate(phone.trim().isNotEmpty, 'Phone number must not be empty.');
    try {
      await _supabase.auth.signInWithOtp(
        phone: phone.trim(),
        shouldCreateUser: shouldCreateUser,
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  /// Verify the OTP sent to [phone] and return the resulting auth response.
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    _validate(phone.trim().isNotEmpty, 'Phone number must not be empty.');
    _validate(otp.trim().isNotEmpty, 'OTP must not be empty.');
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone.trim(),
        token: otp.trim(),
      );
      _requireSession(response, 'Phone OTP verification');
      return response;
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  // ─── Email + Password ────────────────────────────────────────────────────

  /// Create a new account with [email] and [password].
  ///
  /// Pass optional [metadata] (e.g. `{'full_name': 'Laxman'}`) to store
  /// extra user data in Supabase's `auth.users.raw_user_meta_data` column.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    _validate(email.trim().isNotEmpty, 'Email must not be empty.');
    _validate(password.length >= 8, 'Password must be at least 8 characters.');
    try {
      return await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
        emailRedirectTo: kIsWeb ? null : SupabaseConfig.authRedirectUri,
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  /// Sign in with [email] and [password].
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _validate(email.trim().isNotEmpty, 'Email must not be empty.');
    _validate(password.isNotEmpty, 'Password must not be empty.');
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _requireSession(response, 'Email/password sign-in');
      return response;
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  /// Sign in with either email/password or phone/password.
  ///
  /// [credential] may be an email address or an E.164 phone number.
  Future<AuthResponse> signInWithCredentialPassword({
    required String credential,
    required String password,
  }) async {
    final value = credential.trim();
    _validate(value.isNotEmpty, 'Credential must not be empty.');
    _validate(password.isNotEmpty, 'Password must not be empty.');

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: value.contains('@') ? value : null,
        phone: value.contains('@') ? null : value,
        password: password,
      );
      _requireSession(response, 'Credential/password sign-in');
      return response;
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  // ─── Google Sign-In ──────────────────────────────────────────────────────

  /// Sign in with Google.
  ///
  /// On iOS/Android: uses the native Google Sign-In SDK → exchanges id_token
  /// with Supabase for a session.
  ///
  /// On web: initiates an OAuth redirect to Google (no token returned
  /// synchronously — listen on [authStateChanges] instead).
  ///
  /// Returns [AuthResponse] on mobile; throws on web (redirect is async).
  ///
  /// **Required configuration:**
  ///   • Add your `serverClientId` / `clientId` below (from Google Cloud Console).
  ///   • Register your Supabase project's callback URL in Google Cloud Console.
  Future<AuthResponse> signInWithGoogle({
    /// OAuth 2.0 server/web client ID from Google Cloud Console.
    /// (Your web client ID — required for Android native sign-in.)
    String? serverClientId,

    /// iOS OAuth client ID (leave null to use serverClientId on iOS too).
    String? iosClientId,
  }) async {
    if (kIsWeb) {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: Uri.base.origin,
        queryParams: {'prompt': 'select_account'},
      );
      // Web redirect is async — caller should listen on authStateChanges.
      throw SupabaseAuthException(
        'Google OAuth redirect initiated. '
        'Listen on authStateChanges for the session.',
        code: 'web_redirect',
      );
    }

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
        clientId: iosClientId,
        scopes: const ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw SupabaseAuthException(
          'Google sign-in was cancelled by the user.',
          code: 'cancelled',
        );
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw SupabaseAuthException(
          'Google authentication returned no ID token.',
          code: 'no_id_token',
        );
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );
      _requireSession(response, 'Google sign-in');
      return response;
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    } on SupabaseAuthException {
      rethrow;
    } catch (e) {
      throw SupabaseAuthException('Google sign-in failed: $e');
    }
  }

  // ─── Apple Sign-In ───────────────────────────────────────────────────────

  /// Sign in with Apple (iOS 13+ / macOS 10.15+).
  ///
  /// Uses a cryptographic nonce to prevent replay attacks.
  ///
  /// **Required configuration:**
  ///   • Enable "Sign in with Apple" capability in Xcode.
  ///   • Register your app's bundle ID in the Apple Developer portal.
  ///   • Add Supabase callback URL as a valid "Return URL" in the Apple portal.
  Future<AuthResponse> signInWithApple() async {
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.wezu.customer', // TODO: replace with your Apple Services ID for web
          redirectUri: Uri.parse(SupabaseConfig.authRedirectUri),
        ),
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw SupabaseAuthException(
          'Apple authentication returned no identity token.',
          code: 'no_id_token',
        );
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      _requireSession(response, 'Apple sign-in');
      return response;
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw SupabaseAuthException(
          'Apple sign-in was cancelled.',
          code: 'cancelled',
        );
      }
      throw SupabaseAuthException('Apple sign-in failed: ${e.message}');
    } on SupabaseAuthException {
      rethrow;
    } catch (e) {
      throw SupabaseAuthException('Apple sign-in failed: $e');
    }
  }

  // ─── Password Reset ──────────────────────────────────────────────────────

  /// Send a password reset email to [email].
  Future<void> sendPasswordResetEmail(String email) async {
    _validate(email.trim().isNotEmpty, 'Email must not be empty.');
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: kIsWeb ? null : SupabaseConfig.authRedirectUri,
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  /// Update the authenticated user's password to [newPassword].
  ///
  /// Requires the user to already be authenticated (e.g. after following the
  /// reset-password deep link which establishes a short-lived session).
  Future<UserResponse> updatePassword(String newPassword) async {
    _validate(newPassword.length >= 8, 'Password must be at least 8 characters.');
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  /// Verify recovery OTP for password reset and establish a recovery session.
  Future<AuthResponse> verifyPasswordRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    _validate(email.trim().isNotEmpty, 'Email must not be empty.');
    _validate(otp.trim().isNotEmpty, 'OTP must not be empty.');

    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email.trim(),
        token: otp.trim(),
      );
      _requireSession(response, 'Password recovery OTP verification');
      return response;
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  // ─── Session Management ──────────────────────────────────────────────────

  /// Returns the current access token, refreshing it automatically if it
  /// expires within the next 60 seconds.  Returns `null` if not authenticated.
  Future<String?> getAccessToken() async {
    final session = currentSession;
    if (session == null) return null;

    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      final nearExpiry = expiry.difference(DateTime.now()).inSeconds < 60;
      if (nearExpiry) {
        final refreshed = await refreshSession();
        return refreshed?.accessToken;
      }
    }
    return session.accessToken;
  }

  /// Force-refresh the Supabase session.  Returns the new [Session] or `null`
  /// if the refresh failed (session expired or revoked).
  Future<Session?> refreshSession({String? refreshToken}) async {
    try {
      final response = await _supabase.auth.refreshSession(refreshToken);
      return response.session;
    } on AuthException catch (e) {
      debugPrint('SupabaseAuthService: session refresh failed — ${e.message}');
      return null;
    } catch (e) {
      debugPrint('SupabaseAuthService: session refresh error — $e');
      return null;
    }
  }

  // ─── User Metadata ───────────────────────────────────────────────────────

  /// Merge [metadata] into the authenticated user's `raw_user_meta_data`.
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(data: metadata),
      );
    } on AuthException catch (e) {
      throw SupabaseAuthException(e.message, code: e.statusCode);
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────

  /// Sign the user out.
  ///
  /// [scope] controls what gets revoked:
  ///   • [SignOutScope.local] — clears local session only (default; fast).
  ///   • [SignOutScope.global] — revokes all sessions for this user on the server.
  ///   • [SignOutScope.others] — revokes all *other* sessions, keeping this one active.
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    try {
      await _supabase.auth.signOut(scope: scope);
    } on AuthException catch (e) {
      // Log but do not rethrow — local state is cleared regardless.
      debugPrint('SupabaseAuthService: sign-out warning — ${e.message}');
    } catch (e) {
      debugPrint('SupabaseAuthService: sign-out warning — $e');
    }
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────

  /// Throw [SupabaseAuthException] if [condition] is false.
  void _validate(bool condition, String message) {
    if (!condition) throw SupabaseAuthException(message, code: 'validation');
  }

  /// Throw [SupabaseAuthException] if the response has no session.
  void _requireSession(AuthResponse response, String context) {
    if (response.session == null) {
      throw SupabaseAuthException(
        '$context failed: no session returned from Supabase.',
        code: 'no_session',
      );
    }
  }

  /// Generate a URL-safe cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// SHA-256 hex digest of [input] (used for Apple Sign-In nonce hashing).
  String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

/// Typed exception thrown by [SupabaseAuthService].
class SupabaseAuthException implements Exception {
  final String message;

  /// Supabase HTTP status code string, or a local code such as
  /// `'cancelled'`, `'validation'`, `'no_session'`, `'web_redirect'`.
  final String? code;

  const SupabaseAuthException(this.message, {this.code});

  bool get isCancelled => code == 'cancelled';
  bool get isWebRedirect => code == 'web_redirect';
  bool get isValidation => code == 'validation';

  @override
  String toString() =>
      'SupabaseAuthException($code): $message';
}
