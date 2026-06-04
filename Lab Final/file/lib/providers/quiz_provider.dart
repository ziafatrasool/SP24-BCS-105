import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuizProvider extends ChangeNotifier {
  List<QuestionModel> _questions = [];

  int _currentQuestionIndex = 0;

  int _score = 0;

  List<QuestionModel> get questions => _questions;

  int get currentQuestionIndex => _currentQuestionIndex;

  int get score => _score;

  QuestionModel get currentQuestion => _questions[_currentQuestionIndex];

  void setQuestions(List<QuestionModel> questions) {
    _questions = questions;

    notifyListeners();
  }

  void checkAnswer(String selectedAnswer) {
    if (selectedAnswer == currentQuestion.correctAnswer) {
      _score += 10;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;

      notifyListeners();
    }
  }

  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;

  void resetQuiz() {
    _score = 0;

    _currentQuestionIndex = 0;

    notifyListeners();
  }
}
