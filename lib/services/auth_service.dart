
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  // Mengambil pengguna yang sedang login.
  User? get currentUser => _client.auth.currentUser;

  // Register dengan Nama dan Role.
  Future<AuthResponse> register({
    required String email,
    required String password,
    String name = '',
    String role = 'seeker',
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
      },
    );
  }

  // Login pengguna.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout pengguna.
  Future<void> logout() {
    return _client.auth.signOut();
  }
}
