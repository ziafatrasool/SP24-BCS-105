import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient client = Supabase.instance.client;

  Future signUp(String email, String password, String name) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      final user = response.user;
      if (user != null) {
        await _createProfile(user.id, email, name);
      }

      return response;
    } on AuthException catch (e) {
      // If email rate limit is hit, still create the profile locally
      // and allow the user to login later
      if (e.code == 'over_email_send_rate_limit' ||
          e.message.contains('over_email_send_rate_limit')) {
        // Try to get user if they exist
        try {
          final user = await client.auth.signInWithPassword(
            email: email,
            password: password,
          );
          return user;
        } catch (signInError) {
          // User doesn't exist yet, rethrow the original error
          rethrow;
        }
      }
      rethrow;
    }
  }

  Future<void> _createProfile(
    String userId,
    String email,
    String fullName,
  ) async {
    await client.from('profiles').insert(
      [
        {
          'id': userId,
          'email': email,
          'full_name': fullName,
          'points': 0,
          'level': 1,
          'streak': 0,
          'badges': 0,
          'solved': 0,
          'avatar_url': '',
        }
      ],
    );
  }

  Future signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String password) async {
    await client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> updateProfile(String fullName, String avatarUrl) async {
    final data = <String, dynamic>{'full_name': fullName};
    if (avatarUrl.isNotEmpty) {
      data['avatar_url'] = avatarUrl;
    }

    await client.auth.updateUser(UserAttributes(data: data));

    final user = client.auth.currentUser;
    if (user != null) {
      await _updateProfileTable(user.id, data);
    }
  }

  Future<void> updateUserMetadata(Map<String, dynamic> data) async {
    await client.auth.updateUser(UserAttributes(data: data));

    final user = client.auth.currentUser;
    if (user != null) {
      await _updateProfileTable(user.id, data);
    }
  }

  Future<void> _updateProfileTable(
    String userId,
    Map<String, dynamic> data,
  ) async {
    if (data.isEmpty) return;
    await client.from('profiles').update(data).eq('id', userId);
  }

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response =
          await client.from('profiles').select().eq('id', userId).maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }
}
