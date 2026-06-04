import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final SupabaseClient client = Supabase.instance.client;

  // Daily Quiz
  Future<void> updateDailyQuiz({
    required String userId,
    required int newStreak,
  }) async {
    try {
      await client
          .from('profiles')
          .update({'streak': newStreak}).eq('id', userId);
    } catch (e) {
      print('Error updating daily quiz: $e');
    }
  }

  Future<List<dynamic>> getDailyQuiz() async {
    try {
      final response = await client.from('quizzes').select();
      final quizzes = response as List<dynamic>? ?? [];
      if (quizzes.isEmpty) {
        return [
          {
            'id': 1,
            'title': 'Daily Challenge',
          }
        ];
      }

      return quizzes;
    } catch (e) {
      print('Error fetching daily quiz: $e');
      return [
        {
          'id': 1,
          'title': 'Daily Challenge',
        }
      ];
    }
  }

  // Questions

  Future<List<dynamic>> getQuestions(int quizId) async {
    try {
      final response =
          await client.from('questions').select().eq('quiz_id', quizId);
      final questions = response as List<dynamic>? ?? [];

      if (questions.isNotEmpty) {
        return questions;
      }

      // Fallback default questions when DB is empty
      return _getDefaultQuestions(quizId);
    } catch (e) {
      print('Error fetching questions: $e');
      return _getDefaultQuestions(quizId);
    }
  }

  List<Map<String, dynamic>> _getDefaultQuestions(int quizId) {
    return [
      {
        'id': 1,
        'quiz_id': quizId,
        'question': 'What is Flutter?',
        'option_a': 'UI toolkit',
        'option_b': 'Database',
        'option_c': 'Web server',
        'option_d': 'Operating system',
        'correct_answer': 'UI toolkit',
      },
      {
        'id': 2,
        'quiz_id': quizId,
        'question': 'Who developed the Dart language?',
        'option_a': 'Google',
        'option_b': 'Microsoft',
        'option_c': 'Apple',
        'option_d': 'Facebook',
        'correct_answer': 'Google',
      },
      {
        'id': 3,
        'quiz_id': quizId,
        'question': 'Which widget is used for layout in Flutter?',
        'option_a': 'Container',
        'option_b': 'Row/Column',
        'option_c': 'Scaffold',
        'option_d': 'Theme',
        'correct_answer': 'Row/Column',
      },
      {
        'id': 4,
        'quiz_id': quizId,
        'question': 'Supabase is primarily used as a:',
        'option_a': 'Backend-as-a-Service',
        'option_b': 'Frontend framework',
        'option_c': 'Design tool',
        'option_d': 'CI system',
        'correct_answer': 'Backend-as-a-Service',
      },
      {
        'id': 5,
        'quiz_id': quizId,
        'question': 'Which file holds the app entry point in Flutter?',
        'option_a': 'index.html',
        'option_b': 'main.dart',
        'option_c': 'app.dart',
        'option_d': 'pubspec.yaml',
        'correct_answer': 'main.dart',
      },
      {
        'id': 6,
        'quiz_id': quizId,
        'question': 'State management library shown in this project is:',
        'option_a': 'Provider',
        'option_b': 'Redux',
        'option_c': 'Bloc',
        'option_d': 'GetX',
        'correct_answer': 'Provider',
      },
      {
        'id': 7,
        'quiz_id': quizId,
        'question': 'What does SDK stand for?',
        'option_a': 'Software Development Kit',
        'option_b': 'System Deployment Kit',
        'option_c': 'Software Design Kit',
        'option_d': 'Standard Dev Kit',
        'correct_answer': 'Software Development Kit',
      },
      {
        'id': 8,
        'quiz_id': quizId,
        'question': 'Which widget provides basic visual layout structure?',
        'option_a': 'MaterialApp',
        'option_b': 'Scaffold',
        'option_c': 'SafeArea',
        'option_d': 'GestureDetector',
        'correct_answer': 'Scaffold',
      },
      {
        'id': 9,
        'quiz_id': quizId,
        'question': 'Which command installs Flutter packages?',
        'option_a': 'flutter pub get',
        'option_b': 'dart get',
        'option_c': 'npm install',
        'option_d': 'pub install',
        'correct_answer': 'flutter pub get',
      },
      {
        'id': 10,
        'quiz_id': quizId,
        'question': 'What is the supabase client available as in this app?',
        'option_a': 'Supabase.instance.client',
        'option_b': 'SupabaseClient()',
        'option_c': 'supabaseClient',
        'option_d': 'Client()',
        'correct_answer': 'Supabase.instance.client',
      },
    ];
  }

  // Save Result

  Future<void> submitResult({
    required String userId,
    required int quizId,
    required int score,
    required int correctAnswers,
  }) async {
    try {
      await client.from('results').insert({
        'user_id': userId,
        'quiz_id': quizId,
        'score': score,
        'correct_answers': correctAnswers,
      });
    } catch (e) {
      print('Error submitting result: $e');
    }
  }

  // Update XP

  Future<void> updateUserPoints({
    required String userId,
    required int points,
  }) async {
    try {
      await client.from('profiles').update({'points': points}).eq('id', userId);
    } catch (e) {
      print('Error updating user points: $e');
    }
  }
}
