import 'package:api/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String email,
    required String password,
  });

  Future<UserEntity> login({required String email, required String password});

  Future<void> logout();

  UserEntity? getCurrentUser();
}
