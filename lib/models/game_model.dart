class GameModel {
  int? id;
  int targetNumber;
  int attempts;
  DateTime date;
  bool isWin;
  int maxNumber;
  int minNumber;

  GameModel({
    this.id,
    required this.targetNumber,
    required this.attempts,
    required this.date,
    required this.isWin,
    required this.maxNumber,
    required this.minNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetNumber': targetNumber,
      'attempts': attempts,
      'date': date.toIso8601String(),
      'isWin': isWin ? 1 : 0,
      'maxNumber': maxNumber,
      'minNumber': minNumber,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      id: map['id'],
      targetNumber: map['targetNumber'],
      attempts: map['attempts'],
      date: DateTime.parse(map['date']),
      isWin: map['isWin'] == 1,
      maxNumber: map['maxNumber'],
      minNumber: map['minNumber'],
    );
  }

  String getFormattedDate() {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}';
  }
}