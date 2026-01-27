import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/utils/app_logger.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password);
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      AppLogger.info('LOGIN REQUEST → email: $email');

      final res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        AppLogger.error('LOGIN FAILED → user null');
        throw Exception('Login failed');
      }

      AppLogger.success('LOGIN SUCCESS → userId: ${res.user!.id}');
      return UserModel.fromSupabase(res.user!);
    } catch (e) {
      AppLogger.error('LOGIN EXCEPTION', e);
      rethrow;
    }
  }

  @override
  Future<UserModel> register(String email, String password) async {
    try {
      AppLogger.info('REGISTER REQUEST → email: $email');

      final res = await client.auth.signUp(email: email, password: password);

      if (res.user == null) {
        AppLogger.error('REGISTER FAILED → user null');
        throw Exception('Registration failed');
      }

      AppLogger.success('REGISTER SUCCESS → userId: ${res.user!.id}');
      return UserModel.fromSupabase(res.user!);
    } catch (e) {
      if (e is AuthException) {
        AppLogger.error('REGISTER ERROR: ${e.message}');
        throw Exception(e.message); // cleaner message to UI
      }

      AppLogger.error('REGISTER EXCEPTION', e);
      rethrow;
    }

  }

  @override
  UserModel? getCurrentUser() {
    final user = client.auth.currentUser;

    if (user == null) {
      AppLogger.info('NO ACTIVE SESSION');
      return null;
    }

    AppLogger.success('SESSION FOUND → userId: ${user.id}');
    return UserModel.fromSupabase(user);
  }
}
