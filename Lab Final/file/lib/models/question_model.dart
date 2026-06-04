class QuestionModel {
  final int id;

  final String question;

  final String optionA;

  final String optionB;

  final String optionC;

  final String optionD;

  final String correctAnswer;

  QuestionModel({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });
}
