import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  UserModel({required super.id, required super.email});

  factory UserModel.fromSupabase(User u) =>
      UserModel(id: u.id, email: u.email ?? '');
}
