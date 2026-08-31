import '../../../../core/errors/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  UserEntity? getCurrentUser();
}
