import '../../repositories/i_auth_repository.dart';
import '../../../data/models/auth/token_model.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<TokenModel> execute(String username, String password) async {
    return await _repository.login(username, password);
  }
}
