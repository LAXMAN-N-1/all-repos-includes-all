import 'package:evination_customer_app/domain/repositories/i_auth_repository.dart';
import 'package:evination_customer_app/data/models/auth/token_model.dart';
import 'package:evination_customer_app/data/models/user/user_model.dart';

class SignupUseCase {
  final IAuthRepository _repository;

  SignupUseCase(this._repository);

  Future<TokenModel> execute({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _repository.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      password: password,
    );
  }
}
