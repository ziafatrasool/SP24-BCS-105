class GameModel {
  int? id;
  int guess;
  String result;
  String time;

  GameModel({
    this.id,
    required this.guess,
    required this.result,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'guess': guess, 'result': result, 'time': time};
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      guess: map['guess'],
      result: map['result'],
      time: map['time'],
    );
  }
}
