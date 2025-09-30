import 'dart:convert';

import 'package:kickr_flutter/highscore/high_score.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreRepository {
  static const _highScoresKey = 'high_scores';

  Future<void> saveHighScore(HighScore highScore) async {
    final prefs = await SharedPreferences.getInstance();
    final highScores = await getAllHighScores();
    highScores[highScore.courseName] = highScore;

    // Convert the map of HighScore objects to a map of JSON objects
    final highScoresJson = highScores.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    // Encode the entire map to a single JSON string
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

    // Decode the main JSON string into a map
    final Map<String, dynamic> highScoresJson =
        jsonDecode(highScoresJsonString);

    // Convert the inner JSON objects back to HighScore objects
    return highScoresJson.map(
      (key, value) => MapEntry(
        key,
        HighScore.fromJson(value as Map<String, dynamic>),
      ),
    );
  }
}