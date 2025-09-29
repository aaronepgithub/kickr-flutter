import 'package:equatable/equatable.dart';

class HighScore extends Equatable {
  final String courseName;
  final String userName;
  final int timeInSeconds;

  const HighScore({
    required this.courseName,
    required this.userName,
    required this.timeInSeconds,
  });

  @override
  List<Object?> get props => [courseName, userName, timeInSeconds];

  // For JSON serialization
  Map<String, dynamic> toJson() => {
        'courseName': courseName,
        'userName': userName,
        'timeInSeconds': timeInSeconds,
      };

  factory HighScore.fromJson(Map<String, dynamic> json) => HighScore(
        courseName: json['courseName'],
        userName: json['userName'],
        timeInSeconds: json['timeInSeconds'],
      );
}