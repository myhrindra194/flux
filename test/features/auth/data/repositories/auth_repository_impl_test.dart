import 'package:api/core/errors/exceptions.dart';
import 'package:api/core/errors/failures.dart';
import 'package:api/core/errors/result.dart';
import 'package:api/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:api/features/auth/domain/entities/user_entity.dart';
import 'package:api/features/auth/domain/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource);
  });

  group('register', () {
    test('retourne Success lorsque l inscription réussit', () async {
      final user = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );

      when(
        () => remoteDataSource.register(
          email: 'test@test.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => user);

      final result = await repository.register(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity>>());

      final success = result as Success<UserEntity>;

      expect(success.data.id, 'user-123');
      expect(success.data.email, '');
    });

    test('retourne NetworkFailure lorsque le réseau échoue', () async {
      when(
        () => remoteDataSource.register(
          email: 'test@test.com',
          password: 'password123',
        ),
      ).thenThrow(const NetworkException('Pas de connexion.'));

      final result = await repository.register(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result, isA<Error>());

      final error = result as Error;

      expect(error.failure, isA<NetworkFailure>());
      expect(error.failure.message, 'Pas de connexion.');
    });

    test('retourne ServerFailure lorsque le serveur échoue', () async {
      when(
        () => remoteDataSource.register(
          email: 'test@test.com',
          password: 'password123',
        ),
      ).thenThrow(const ServerException('Erreur serveur.'));

      final result = await repository.register(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result, isA<Error>());

      final error = result as Error;

      expect(error.failure, isA<ServerFailure>());
      expect(error.failure.message, 'Erreur serveur.');
    });
  });

  group('login', () {
    test('retourne Success lorsque la connexion réussit', () async {
      final user = User(
        id: 'user-456',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'test@test.com',
      );

      when(
        () => remoteDataSource.login(
          email: 'test@test.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => user);

      final result = await repository.login(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity>>());

      final success = result as Success<UserEntity>;

      expect(success.data.id, 'user-456');
      expect(success.data.email, 'test@test.com');
    });

    test('retourne ServerFailure lorsque le login échoue', () async {
      when(
        () => remoteDataSource.login(
          email: 'test@test.com',
          password: 'wrong-password',
        ),
      ).thenThrow(const ServerException('Email ou mot de passe incorrect.'));

      final result = await repository.login(
        email: 'test@test.com',
        password: 'wrong-password',
      );

      expect(result, isA<Error>());

      final error = result as Error;

      expect(error.failure, isA<ServerFailure>());
      expect(error.failure.message, 'Email ou mot de passe incorrect.');
    });

    test('retourne NetworkFailure lorsque le réseau échoue', () async {
      when(
        () => remoteDataSource.login(
          email: 'test@test.com',
          password: 'password123',
        ),
      ).thenThrow(const NetworkException());

      final result = await repository.login(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result, isA<Error>());

      final error = result as Error;

      expect(error.failure, isA<NetworkFailure>());
    });
  });

  group('logout', () {
    test('retourne Success lorsque la déconnexion réussit', () async {
      when(() => remoteDataSource.logout()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, isA<Success<void>>());

      verify(() => remoteDataSource.logout()).called(1);
    });

    test('retourne NetworkFailure lorsque la déconnexion échoue', () async {
      when(
        () => remoteDataSource.logout(),
      ).thenThrow(const NetworkException('Connexion impossible.'));

      final result = await repository.logout();

      expect(result, isA<Error>());

      final error = result as Error;

      expect(error.failure, isA<NetworkFailure>());
      expect(error.failure.message, 'Connexion impossible.');
    });
  });

  group('getCurrentUser', () {
    test('retourne UserEntity lorsque l utilisateur est connecté', () {
      final user = User(
        id: 'user-789',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'current@test.com',
      );

      when(() => remoteDataSource.getCurrentUser()).thenReturn(user);

      final result = repository.getCurrentUser();

      expect(result, isNotNull);
      expect(result!.id, 'user-789');
      expect(result.email, 'current@test.com');
    });

    test('retourne null lorsqu aucun utilisateur n est connecté', () {
      when(() => remoteDataSource.getCurrentUser()).thenReturn(null);

      final result = repository.getCurrentUser();

      expect(result, isNull);
    });
  });
}
