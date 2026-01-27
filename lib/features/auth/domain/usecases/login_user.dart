import 'package:chat_app/features/auth/domain/entities/app_user.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repo;
  LoginUser(this.repo);
  Future<AppUser> call(String e, String p) => repo.login(e, p);
}
