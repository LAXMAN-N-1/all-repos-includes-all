import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../data/datasources/remote/auth_remote_datasource.dart';
import '../../../data/datasources/remote/event_remote_datasource.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/repositories/event_repository_impl.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_event_repository.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/signup_usecase.dart';
import '../../../domain/usecases/event/get_categories_usecase.dart';

// Core
final apiClientProvider = Provider((ref) => ApiClient());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Initialized in main.dart
});

final localStorageProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorage(prefs);
});

// Data Sources
final authRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(client.dio);
});

final eventRemoteDataSourceProvider = Provider((ref) {
  final client = ref.watch(apiClientProvider);
  return EventRemoteDataSource(client.dio);
});

// Repositories
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remote = ref.watch(authRemoteDataSourceProvider);
  final local = ref.watch(localStorageProvider);
  return AuthRepositoryImpl(remote, local);
});

final eventRepositoryProvider = Provider<IEventRepository>((ref) {
  final remote = ref.watch(eventRemoteDataSourceProvider);
  return EventRepositoryImpl(remote);
});

// Use Cases
final loginUseCaseProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

final getCategoriesUseCaseProvider = Provider((ref) {
  final repo = ref.watch(eventRepositoryProvider);
  return GetCategoriesUseCase(repo);
});

final signupUseCaseProvider = Provider((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return SignupUseCase(repo);
});
