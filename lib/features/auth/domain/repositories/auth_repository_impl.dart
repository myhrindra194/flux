import 'package:api/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:api/features/auth/data/models/user_model.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
  }) async {
    final user = await _remoteDataSource.register(
      email: email,
      password: password,
    );

    return UserModel.fromSupabaseUser(user);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final user = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    return UserModel.fromSupabaseUser(user);
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }

  @override
  UserEntity? getCurrentUser() {
    final user = _remoteDataSource.getCurrentUser();

    if (user == null) {
      return null;
    }

    return UserModel.fromSupabaseUser(user);
  }
}
