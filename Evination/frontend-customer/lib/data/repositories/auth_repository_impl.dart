import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth/token_model.dart';
import '../models/user/user_model.dart';
import '../../core/storage/local_storage.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._localStorage);

  @override
  Future<TokenModel> login(String username, String password) async {
    final token = await _remoteDataSource.login(username, password);
    await _localStorage.saveToken(token.accessToken);
    return token;
  }

  @override
  Future<TokenModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final token = await _remoteDataSource.signup({
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "password": password,
    });
    await _localStorage.saveToken(token.accessToken);
    return token;
  }

  @override
  Future<void> logout() async {
    await _localStorage.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _localStorage.getToken();
    return token != null;
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      return await _remoteDataSource.getUser();
    } catch (e) {
      return null;
    }
  }
}
