import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/supabase_client.dart';

class AuthRepository {
  const AuthRepository();

  SupabaseClient get _client => SupabaseService.client;

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(OAuthProvider.apple);
  }
}
