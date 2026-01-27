import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.register(email, password);
  }
}
