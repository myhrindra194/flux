import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionManager {
  final SupabaseClient _supabase;

  AuthSessionManager(this._supabase);

  String? get accessToken {
    return _supabase.auth.currentSession?.accessToken;
  }

  Future<String?> refreshAccessToken() async {
    final response = await _supabase.auth.refreshSession();

    return response.session?.accessToken;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
