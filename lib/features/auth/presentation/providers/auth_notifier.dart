import 'package:api/core/errors/result.dart';
import 'package:api/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);

    final currentUser = _repository.getCurrentUser();

    return AuthState(user: currentUser);
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.register(email: email, password: password);

    switch (result) {
      case Success(data: final user):
        state = AuthState(user: user);

      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.login(email: email, password: password);

    switch (result) {
      case Success(data: final user):
        state = AuthState(user: user);

      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.logout();

    switch (result) {
      case Success():
        state = const AuthState();

      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
    }
  }
}
