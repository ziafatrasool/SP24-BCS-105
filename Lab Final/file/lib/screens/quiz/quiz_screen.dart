import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/images.dart';
import '../../models/question_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/quiz_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/loading_animation.dart';
import '../../widgets/page_background.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  late Future<List<QuestionModel>> _questionsFuture;
  int currentQuestion = 0;
  int score = 0;
  int quizId = 0;

  @override
  void initState() {
    super.initState();
    _questionsFuture = _loadQuestions();
  }

  Future<List<QuestionModel>> _loadQuestions() async {
    final quizzes = await _quizService.getDailyQuiz();
    if (quizzes.isEmpty) {
      throw Exception('No quiz available.');
    }

    final quiz = quizzes.first as Map<String, dynamic>;
    quizId = quiz['id'] is int
        ? quiz['id'] as int
        : int.parse(quiz['id'].toString());

    final questionsData = await _quizService.getQuestions(quizId);
    final loadedQuestions = questionsData.map<QuestionModel>((item) {
      final data = item as Map<String, dynamic>;
      return QuestionModel(
        id: data['id'] is int
            ? data['id'] as int
            : int.parse(data['id'].toString()),
        question: data['question']?.toString() ?? '',
        optionA: data['option_a']?.toString() ?? '',
        optionB: data['option_b']?.toString() ?? '',
        optionC: data['option_c']?.toString() ?? '',
        optionD: data['option_d']?.toString() ?? '',
        correctAnswer: data['correct_answer']?.toString() ?? '',
      );
    }).toList();

    if (loadedQuestions.isEmpty) {
      throw Exception('Quiz has no questions.');
    }

    loadedQuestions.shuffle();
    return loadedQuestions.take(10).toList();
  }

  void checkAnswer(String selected, List<QuestionModel> questions) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isCorrect = selected == questions[currentQuestion].correctAnswer;

    if (settings.soundEnabled) {
      if (isCorrect) {
        SoundService().playCorrect(settings.volume);
      } else {
        SoundService().playWrong(settings.volume);
      }
    }

    if (isCorrect) {
      score += 10;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            totalQuestions: questions.length,
            quizId: quizId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImages.logo),
        ),
        title: const Text('Daily Challenge'),
      ),
      body: PageBackground(
        child: SafeArea(
          child: FutureBuilder<List<QuestionModel>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingAnimation());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Unable to load quiz. ${snapshot.error}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final questions = snapshot.data!;
              final question = questions[currentQuestion];
              final options = [
                question.optionA,
                question.optionB,
                question.optionC,
                question.optionD,
              ];

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 360;
                  final padding = EdgeInsets.all(isSmall ? 14 : 20);
                  final questionStyle = TextStyle(
                    fontSize: isSmall ? 20 : 22,
                    fontWeight: FontWeight.bold,
                  );
                  return SingleChildScrollView(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: (currentQuestion + 1) / questions.length,
                          minHeight: 6,
                        ),
                        SizedBox(height: isSmall ? 20 : 30),
                        Text(
                          question.question,
                          style: questionStyle,
                        ),
                        SizedBox(height: isSmall ? 20 : 30),
                        ...options.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 14 : 18,
                                    horizontal: 12,
                                  ),
                                ),
                                onPressed: () {
                                  checkAnswer(option, questions);
                                },
                                child: Text(
                                  option,
                                  style: TextStyle(fontSize: isSmall ? 16 : 18),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
