import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide UserResponse;
import '../api/api_client.dart';
import '../api/api_response.dart';
import '../models/dealer_user.dart';
import '../services/users_service.dart';

// Auth state
class AuthState {
  final DealerUser? user;
  final bool isLoading;
  final bool isAuthenticated;
  final bool mustChangePassword;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.mustChangePassword = false,
    this.error,
  });

  AuthState copyWith({
    DealerUser? user,
    bool? isLoading,
    bool? isAuthenticated,
    bool? mustChangePassword,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;

  AuthNotifier(this._dio) : super(const AuthState());

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    if (!ApiConstants.hasSupabaseConfig) {
      state = const AuthState(
        error: 'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env',
      );
      return false;
    }

    try {
      final AuthResponse response;
      if (_looksLikeEmail(identifier)) {
        response = await _supabase.auth.signInWithPassword(
          email: identifier.trim(),
          password: password,
        );
      } else {
        response = await _supabase.auth.signInWithPassword(
          phone: identifier.trim(),
          password: password,
        );
      }

      if (response.session == null) {
        state = const AuthState(
          error: 'Invalid Supabase login response: missing session',
        );
        return false;
      }

      // Log in with JWT immediately — user reaches portal without delay.
      // Backend profile loads in the background.
      _hydrateFromJwtFallback();
      _hydrateUserFromBackend(); // fire-and-forget
      return true;
    } on AuthException catch (e) {
      state = AuthState(error: _friendlyAuthError(e));
      return false;
    } catch (e) {
      state = const AuthState(error: 'Connection error');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String phoneNumber,
    required String fullName,
    required String password,
    required String businessName,
    required String contactPerson,
    required String addressLine1,
    required String city,
    required String state_,
    required String pincode,
    String? gstNumber,
    String? panNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    if (!ApiConstants.hasSupabaseConfig) {
      state = const AuthState(
        error: 'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env',
      );
      return false;
    }

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'business_name': businessName,
          'contact_person': contactPerson,
          'address_line1': addressLine1,
          'city': city,
          'state': state_,
          'pincode': pincode,
          if (gstNumber != null && gstNumber.isNotEmpty)
            'gst_number': gstNumber,
          if (panNumber != null && panNumber.isNotEmpty)
            'pan_number': panNumber,
        },
      );

      if (response.session == null) {
        state = const AuthState(
          error:
              'Signup created. Verify your email in Supabase, then login from this app.',
        );
        return false;
      }

      final hydrated = await _hydrateUserFromBackend();
      if (!hydrated) {
        await _supabase.auth.signOut();
        state = const AuthState(
          error:
              'Account created in Supabase, but backend dealer access is not provisioned yet. Ask admin to invite/provision this account.',
        );
        return false;
      }
      return true;
    } on AuthException catch (e) {
      state = AuthState(error: _friendlyAuthError(e));
      return false;
    } catch (e) {
      state = const AuthState(error: 'Connection error');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Always clear local state even if remote signOut fails
    }
    state = const AuthState();
  }

  Future<void> checkAuth() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      state = const AuthState();
      return;
    }
    // Log in immediately with JWT so the user reaches the portal at once.
    // Then refresh profile data from backend in the background.
    _hydrateFromJwtFallback();
    _hydrateUserFromBackend(); // fire-and-forget, updates state when ready
  }

  Future<void> refreshUser() async {
    // Don't block UI — if JWT fallback succeeds user is already in
    if (state.user == null) _hydrateFromJwtFallback();
    await _hydrateUserFromBackend();
    // Only clear auth if Supabase session is also gone
    if (!state.isAuthenticated && _supabase.auth.currentSession == null) {
      state = const AuthState();
    }
  }

  Future<bool> _hydrateUserFromBackend() async {
    try {
      // Run all 3 backend calls in parallel — no sequential waiting
      final results = await Future.wait([
        _dio.get(ApiConstants.authMe).catchError((_) => null),
        _dio.get(ApiConstants.dealerProfile).catchError((_) => null),
        _dio.get(ApiConstants.registrationStatus).catchError((_) => null),
      ]);

      final authMeRes = results[0];
      if (authMeRes == null) {
        // All 3 failed (network down) — keep existing JWT-based session
        return state.isAuthenticated;
      }

      final authRoot =
          ApiResponse.asMap(authMeRes.data, keys: const ['data']);
      final authUser = ApiResponse.asMap(authRoot['user']);
      if (authUser.isEmpty) return state.isAuthenticated;

      final roles = _toStringList(authRoot['roles']);
      final permissionSlugs = _toStringList(authRoot['permissions']);
      final permissionMap = _groupPermissions(permissionSlugs);

      final dealerProfile = results[1] != null
          ? ApiResponse.asMap(results[1]!.data, keys: const ['data'])
          : const <String, dynamic>{};

      final registration = results[2] != null
          ? ApiResponse.asMap(results[2]!.data, keys: const ['data'])
          : const <String, dynamic>{};

      final role = _selectPrimaryRole(roles, authUser['user_type']?.toString());

      final user = DealerUser.fromJson({
        ...authUser,
        'name': dealerProfile['full_name'] ?? authUser['full_name'],
        'email': authUser['email'] ?? dealerProfile['email'],
        'phone_number': authUser['phone_number'] ?? dealerProfile['phone'],
        'role': role,
        'role_name': role,
        'permissions': permissionMap,
        'dealer_id': dealerProfile['id'],
        'business_name':
            dealerProfile['business_name'] ?? registration['business_name'],
        'is_approved': dealerProfile['is_active'] ?? false,
        'application_stage': registration['current_stage'],
        'profile_picture':
            dealerProfile['profile_picture'] ?? authUser['profile_picture'],
      });

      state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } on DioException catch (e) {
      final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.response == null;
      if (isNetworkError) return state.isAuthenticated;
      // 401/403 → actual auth failure
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        state = AuthState(
          error: _extractApiErrorMessage(e,
              fallback: 'Failed to validate backend dealer access'),
        );
        return false;
      }
      return state.isAuthenticated;
    } catch (_) {
      return state.isAuthenticated;
    }
  }

  /// Build a minimal DealerUser from the Supabase JWT when the backend
  /// is unreachable. This keeps the user logged in so they can still
  /// navigate the portal; data will load once the backend responds.
  bool _hydrateFromJwtFallback() {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return false;
      final meta = session.user.userMetadata ?? {};
      final email = session.user.email ?? '';
      final fullName = meta['full_name']?.toString() ?? 'Dealer';
      final roleName = meta['role_name']?.toString() ?? 'dealer';
      final user = DealerUser.fromJson({
        'id': session.user.id,
        'email': email,
        'full_name': fullName,
        'name': fullName,
        'role': roleName,
        'role_name': roleName,
        'permissions': <String, List<String>>{},
        'is_approved': true,
      });
      state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _looksLikeEmail(String value) => value.contains('@');

  List<String> _toStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _selectPrimaryRole(List<String> roles, String? userType) {
    const dealerRolePriority = <String>[
      'dealer_owner',
      'dealer_manager',
      'dealer_inventory_staff',
      'dealer_finance_staff',
      'dealer_support_staff',
      'dealer',
    ];
    for (final role in dealerRolePriority) {
      if (roles.contains(role)) return role;
    }
    if (roles.isNotEmpty) return roles.first;
    final normalizedType = (userType ?? '').trim();
    return normalizedType.isEmpty ? 'dealer' : normalizedType;
  }

  Map<String, List<String>> _groupPermissions(List<String> permissionSlugs) {
    final grouped = <String, Set<String>>{};
    for (final slug in permissionSlugs) {
      final normalized = slug.replaceAll(':', '.');
      final parts =
          normalized.split('.').where((part) => part.isNotEmpty).toList();
      if (parts.length >= 2) {
        final module = parts[parts.length - 2];
        final action = parts.last;
        grouped.putIfAbsent(module, () => <String>{}).add(action);
      } else if (parts.length == 1) {
        grouped.putIfAbsent('general', () => <String>{}).add(parts.first);
      }
    }

    final result = <String, List<String>>{};
    for (final entry in grouped.entries) {
      final values = entry.value.toList()..sort();
      result[entry.key] = values;
    }
    return result;
  }

  String _friendlyAuthError(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    return e.message.isNotEmpty ? e.message : 'Authentication failed';
  }

  String _extractApiErrorMessage(
    DioException error, {
    required String fallback,
  }) {
    final details = ApiResponse.asMap(
      error.response?.data,
      keys: const ['error'],
    );
    final errorDescription = details['error_description']?.toString().trim();
    if (errorDescription != null && errorDescription.isNotEmpty) {
      return errorDescription;
    }
    final detail = details['detail']?.toString();
    switch ((detail ?? '').trim()) {
      case 'identity_unmapped':
        return 'Account exists in Supabase but is not linked in backend yet. Ask admin to provision dealer access.';
      case 'token_missing':
      case 'token_invalid':
      case 'token_expired':
        return 'Your login session is invalid or expired. Please sign in again.';
      case 'insufficient_permissions':
        return 'This account is authenticated but does not have dealer portal permissions.';
      default:
        return ApiResponse.errorMessage(error, fallback: fallback);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthNotifier(dio);
});

final authBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).checkAuth();
});

/// Activate an invited account using the invite token
final activateAccountProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>((
  ref,
  params,
) async {
  final service = ref.watch(usersServiceProvider);
  return service.activateAccount(params['token']!, params['password']!);
});
