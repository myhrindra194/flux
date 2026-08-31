import 'package:api/core/errors/exceptions.dart';
import 'package:api/core/errors/failures.dart';
import 'package:api/core/errors/result.dart';
import 'package:api/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:api/features/auth/data/models/user_model.dart';

import '../entities/user_entity.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserEntity>> register({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
      );

      return Success(UserModel.fromSupabaseUser(user));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } on UnknownException catch (e) {
      return Error(UnknownFailure(e.message));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      return Success(UserModel.fromSupabaseUser(user));
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } on UnknownException catch (e) {
      return Error(UnknownFailure(e.message));
    } catch (_) {
      return const Error(UnknownFailure());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();

      return const Success(null);
    } on NetworkException catch (e) {
      return Error(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Error(CacheFailure(e.message));
    } on UnknownException catch (e) {
      return Error(UnknownFailure(e.message));
    } catch (_) {
      return const Error(UnknownFailure());
    }
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
