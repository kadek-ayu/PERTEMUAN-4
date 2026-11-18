import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: (map['email'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      role: (map['role'] ?? 'seeker') as String,
    );
  }
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  String? get currentUserRole => null;

  Future<UserProfile?> getMyProfile() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    final data = await _client
        .from('profiles')
        .select('id, email, name, role')
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return UserProfile.fromMap(data);
  }
}