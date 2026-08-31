import 'package:api/core/errors/failures.dart';
import 'package:api/core/errors/result.dart';
import 'package:api/features/auth/domain/entities/user_entity.dart';
import 'package:api/features/auth/domain/repositories/auth_repository.dart';
import 'package:api/features/auth/presentation/providers/auth_notifier.dart';
import 'package:api/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeUserEntity extends UserEntity {
  const FakeUserEntity({required super.id, required super.email});
}

void main() {
  late MockAuthRepository repository;
  late ProviderContainer container;

  const user = FakeUserEntity(id: 'user-123', email: 'test@test.com');

  setUp(() {
    repository = MockAuthRepository();

    when(() => repository.getCurrentUser()).thenReturn(null);

    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier - login', () {
    test('login réussi met à jour le user', () async {
      when(
        () => repository.login(email: 'test@test.com', password: 'password123'),
      ).thenAnswer((_) async => const Success<UserEntity>(user));

      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.login(email: 'test@test.com', password: 'password123');

      final state = container.read(authNotifierProvider);

      expect(state.user, isNotNull);
      expect(state.user!.id, 'user-123');
      expect(state.user!.email, 'test@test.com');
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(
        () => repository.login(email: 'test@test.com', password: 'password123'),
      ).called(1);
    });

    test('login échoué met à jour errorMessage', () async {
      when(
        () => repository.login(
          email: 'test@test.com',
          password: 'wrong-password',
        ),
      ).thenAnswer(
        (_) async => const Error<UserEntity>(
          ServerFailure('Email ou mot de passe incorrect.'),
        ),
      );

      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.login(email: 'test@test.com', password: 'wrong-password');

      final state = container.read(authNotifierProvider);

      expect(state.user, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Email ou mot de passe incorrect.');
    });
  });

  group('AuthNotifier - register', () {
    test('register réussi met à jour le user', () async {
      when(
        () =>
            repository.register(email: 'new@test.com', password: 'password123'),
      ).thenAnswer((_) async => const Success<UserEntity>(user));

      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.register(email: 'new@test.com', password: 'password123');

      final state = container.read(authNotifierProvider);

      expect(state.user, isNotNull);
      expect(state.user!.id, 'user-123');
      expect(state.user!.email, 'test@test.com');
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(
        () =>
            repository.register(email: 'new@test.com', password: 'password123'),
      ).called(1);
    });

    test('register échoué met à jour errorMessage', () async {
      when(
        () =>
            repository.register(email: 'new@test.com', password: 'password123'),
      ).thenAnswer(
        (_) async => const Error<UserEntity>(
          ServerFailure('Impossible de créer le compte.'),
        ),
      );

      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.register(email: 'new@test.com', password: 'password123');

      final state = container.read(authNotifierProvider);

      expect(state.user, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, 'Impossible de créer le compte.');
    });
  });

  group('AuthNotifier - logout', () {
    test('logout réussi supprime le user', () async {
      when(() => repository.getCurrentUser()).thenReturn(user);

      when(
        () => repository.logout(),
      ).thenAnswer((_) async => const Success<void>(null));

      final testContainer = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      final notifier = testContainer.read(authNotifierProvider.notifier);

      expect(testContainer.read(authNotifierProvider).user, isNotNull);

      await notifier.logout();

      final state = testContainer.read(authNotifierProvider);

      expect(state.user, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);

      verify(() => repository.logout()).called(1);

      testContainer.dispose();
    });

    test('logout échoué met à jour errorMessage', () async {
      when(() => repository.logout()).thenAnswer(
        (_) async => const Error<void>(NetworkFailure('Connexion impossible.')),
      );

      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.logout();

      final state = container.read(authNotifierProvider);

      expect(state.isLoading, false);
      expect(state.errorMessage, 'Connexion impossible.');
    });
  });

  group('AuthNotifier - initial state', () {
    test('récupère l utilisateur courant', () {
      when(() => repository.getCurrentUser()).thenReturn(user);

      final testContainer = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );

      final state = testContainer.read(authNotifierProvider);

      expect(state.user, isNotNull);
      expect(state.user!.id, 'user-123');
      expect(state.user!.email, 'test@test.com');

      testContainer.dispose();
    });

    test('user est null lorsqu aucun utilisateur n est connecté', () {
      final state = container.read(authNotifierProvider);

      expect(state.user, isNull);
    });
  });
}
