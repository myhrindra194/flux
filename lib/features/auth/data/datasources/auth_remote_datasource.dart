import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource(this._client);

  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw const ServerException('Impossible de créer le compte.');
      }

      return user;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnknownException();
    }
  }

  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw const ServerException('Impossible de se connecter.');
      }

      return user;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnknownException();
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } on AppException {
      rethrow;
    } catch (_) {
      throw const UnknownException();
    }
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
