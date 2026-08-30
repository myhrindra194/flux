import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(id: user.id, email: user.email ?? '');
  }
}
