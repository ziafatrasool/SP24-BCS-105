import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  static Future<void> seedInitialData() async {
    try {
      final existingQuiz =
          await client.from('quizzes').select('id').limit(1) as List<dynamic>;
      if (existingQuiz.isNotEmpty) {
        return;
      }

      final insertedQuiz = await client.from('quizzes').insert([
        {'title': 'Daily Challenge'}
      ]).select() as List<dynamic>;

      final quizId = insertedQuiz.isNotEmpty ? insertedQuiz.first['id'] : null;

      if (quizId == null) {
        return;
      }

      final questions = [
        {
          'quiz_id': quizId,
          'question': 'What is Flutter?',
          'option_a': 'UI toolkit',
          'option_b': 'Database',
          'option_c': 'Web server',
          'option_d': 'Operating system',
          'correct_answer': 'UI toolkit',
        },
        {
          'quiz_id': quizId,
          'question': 'Who developed the Dart language?',
          'option_a': 'Google',
          'option_b': 'Microsoft',
          'option_c': 'Apple',
          'option_d': 'Facebook',
          'correct_answer': 'Google',
        },
        {
          'quiz_id': quizId,
          'question': 'Which widget is used for layout in Flutter?',
          'option_a': 'Container',
          'option_b': 'Row/Column',
          'option_c': 'Scaffold',
          'option_d': 'Theme',
          'correct_answer': 'Row/Column',
        },
        {
          'quiz_id': quizId,
          'question': 'Supabase is primarily used as a:',
          'option_a': 'Backend-as-a-Service',
          'option_b': 'Frontend framework',
          'option_c': 'Design tool',
          'option_d': 'CI system',
          'correct_answer': 'Backend-as-a-Service',
        },
        {
          'quiz_id': quizId,
          'question': 'Which file holds the app entry point in Flutter?',
          'option_a': 'index.html',
          'option_b': 'main.dart',
          'option_c': 'app.dart',
          'option_d': 'pubspec.yaml',
          'correct_answer': 'main.dart',
        },
        {
          'quiz_id': quizId,
          'question': 'State management library shown in this project is:',
          'option_a': 'Provider',
          'option_b': 'Redux',
          'option_c': 'Bloc',
          'option_d': 'GetX',
          'correct_answer': 'Provider',
        },
        {
          'quiz_id': quizId,
          'question': 'What does SDK stand for?',
          'option_a': 'Software Development Kit',
          'option_b': 'System Deployment Kit',
          'option_c': 'Software Design Kit',
          'option_d': 'Standard Dev Kit',
          'correct_answer': 'Software Development Kit',
        },
        {
          'quiz_id': quizId,
          'question': 'Which widget provides basic visual layout structure?',
          'option_a': 'MaterialApp',
          'option_b': 'Scaffold',
          'option_c': 'SafeArea',
          'option_d': 'GestureDetector',
          'correct_answer': 'Scaffold',
        },
        {
          'quiz_id': quizId,
          'question': 'Which command installs Flutter packages?',
          'option_a': 'flutter pub get',
          'option_b': 'dart get',
          'option_c': 'npm install',
          'option_d': 'pub install',
          'correct_answer': 'flutter pub get',
        },
        {
          'quiz_id': quizId,
          'question': 'What is the supabase client available as in this app?',
          'option_a': 'Supabase.instance.client',
          'option_b': 'SupabaseClient()',
          'option_c': 'supabaseClient',
          'option_d': 'Client()',
          'correct_answer': 'Supabase.instance.client',
        },
      ];

      await client.from('questions').insert(questions);

      final existingBadges =
          await client.from('badges').select('id').limit(1) as List<dynamic>;
      if (existingBadges.isEmpty) {
        await client.from('badges').insert([
          {
            'title': 'First Quiz',
            'description': 'Complete your first quiz',
            'icon': '🎉',
            'unlocked': false,
          },
          {
            'title': 'Beginner',
            'description': 'Solve 10 Questions',
            'icon': '🥉',
            'unlocked': false,
          },
          {
            'title': 'Regular',
            'description': 'Solve 25 Questions',
            'icon': '🏅',
            'unlocked': false,
          },
          {
            'title': 'Intermediate',
            'description': 'Solve 50 Questions',
            'icon': '🏆',
            'unlocked': false,
          },
          {
            'title': 'Skilled',
            'description': 'Solve 100 Questions',
            'icon': '🥈',
            'unlocked': false,
          },
          {
            'title': 'Expert',
            'description': 'Solve 250 Questions',
            'icon': '🏅',
            'unlocked': false,
          },
          {
            'title': 'Master',
            'description': 'Solve 500 Questions',
            'icon': '🥇',
            'unlocked': false,
          },
          {
            'title': 'Perfect Score',
            'description': 'Get all answers correct in a quiz',
            'icon': '🌟',
            'unlocked': false,
          },
          {
            'title': '7-Day Streak',
            'description': 'Complete quizzes 7 days in a row',
            'icon': '🔥',
            'unlocked': false,
          },
          {
            'title': '30-Day Streak',
            'description': 'Complete quizzes 30 days in a row',
            'icon': '🔥',
            'unlocked': false,
          },
        ]);
      }

      // Seed top player profiles if not exist
      final existingProfiles =
          await client.from('profiles').select('id').limit(1) as List<dynamic>;
      if (existingProfiles.isEmpty) {
        await client.from('profiles').insert([
          {
            'full_name': 'Ziafat Malik',
            'points': 2300,
            'level': 23,
            'streak': 15,
            'solved': 115,
            'badges': [],
            'avatar_url': '',
          },
          {
            'full_name': 'tehseen',
            'points': 2100,
            'level': 21,
            'streak': 12,
            'solved': 105,
            'badges': [],
            'avatar_url': '',
          },
          {
            'full_name': 'Ayesha',
            'points': 1900,
            'level': 19,
            'streak': 10,
            'solved': 95,
            'badges': [],
            'avatar_url': '',
          },
        ]);
      }

      if (kDebugMode) {
        debugPrint(
            'Supabase seed: default quiz, questions, profiles, and badges inserted.');
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Supabase seed failed: $error');
      }
    }
  }
}
