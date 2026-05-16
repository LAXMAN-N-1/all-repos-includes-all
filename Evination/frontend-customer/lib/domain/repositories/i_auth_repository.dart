import '../../data/models/auth/token_model.dart';
import '../../data/models/user/user_model.dart';

abstract class IAuthRepository {
  Future<TokenModel> login(String username, String password);
  Future<TokenModel> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  });
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserModel?> getUser();
}
