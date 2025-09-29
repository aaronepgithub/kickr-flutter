import 'dart:convert';

import 'package:kickr_flutter/highscore/high_score.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreRepository {
  static const _highScoresKey = 'high_scores';

  Future<void> saveHighScore(HighScore highScore) async {
    final prefs = await SharedPreferences.getInstance();
    final highScores = await getAllHighScores();
    highScores[highScore.courseName] = highScore;

    final highScoresJson = highScores.map(
      (key, value) => MapEntry(key, jsonEncode(value.toJson())),
    );

    await prefs.setString(_highScoresKey, jsonEncode(highScoresJson));
  }

  Future<HighScore?> getHighScore(String courseName) async {
    final highScores = await getAllHighScores();
    return highScores[courseName];
  }

  Future<Map<String, HighScore>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final highScoresJsonString = prefs.getString(_highScoresKey);

    if (highScoresJsonString == null) {
      return {};
    }

    final Map<String, dynamic> highScoresJson =
        jsonDecode(highScoresJsonString);
    return highScoresJson.map(
      (key, value) => MapEntry(
        key,
        HighScore.fromJson(jsonDecode(value)),
      ),
    );
  }
}