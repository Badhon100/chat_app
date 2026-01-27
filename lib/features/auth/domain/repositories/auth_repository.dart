import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String email, String password);
  AppUser? currentUser();
}
