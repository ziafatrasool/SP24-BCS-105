import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardService {
  final SupabaseClient client = Supabase.instance.client;

  Future<List<dynamic>> getTopUsers() async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .order('points', ascending: false)
          .limit(50);

      final users = response as List<dynamic>? ?? [];

      if (users.isEmpty) {
        // Return sample leaderboard when DB is empty
        return [
          {
            'id': 'user_1',
            'full_name': 'Ziafat Malik',
            'points': 2300,
            'avatar_url': ''
          },
          {
            'id': 'user_2',
            'full_name': 'tehseen',
            'points': 2100,
            'avatar_url': ''
          },
          {
            'id': 'user_3',
            'full_name': 'Ayesha',
            'points': 1900,
            'avatar_url': ''
          },
        ];
      }

      return users;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      // Return sample leaderboard on error
      return [
        {
          'id': 'user_1',
          'full_name': 'Ziafat Malik',
          'points': 2300,
          'avatar_url': ''
        },
        {
          'id': 'user_2',
          'full_name': 'tehseen',
          'points': 2100,
          'avatar_url': ''
        },
        {
          'id': 'user_3',
          'full_name': 'Ayesha',
          'points': 1900,
          'avatar_url': ''
        },
      ];
    }
  }
}
