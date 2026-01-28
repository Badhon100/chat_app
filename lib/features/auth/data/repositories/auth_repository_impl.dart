import 'package:chat_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:chat_app/features/auth/domain/entities/app_user.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<AppUser> login(String e, String p) => remote.login(e, p);

  @override
  Future<AppUser> register(String e, String p) => remote.register(e, p);

  @override
  Future<void> logout() => remote.logout();

  @override
  AppUser? currentUser() => remote.getCurrentUser();
}
