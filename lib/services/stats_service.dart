import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizResult {
  final String category;
  final int totalQuestions;
  final int correctAnswers;
  final int pointsEarned;
  final DateTime completedAt;

  QuizResult({
    required this.category,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.pointsEarned,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'category': category,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'pointsEarned': pointsEarned,
    'completedAt': completedAt.toIso8601String(),
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    category: json['category'],
    totalQuestions: json['totalQuestions'],
    correctAnswers: json['correctAnswers'],
    pointsEarned: json['pointsEarned'],
    completedAt: DateTime.parse(json['completedAt']),
  );
}

class StatsService {
  static const _keyTotalPoints = 'stats_total_points';
  static const _keyTotalQuizzes = 'stats_total_quizzes';
  static const _keyTotalCorrect = 'stats_total_correct';
  static const _keyTotalAnswered = 'stats_total_answered';
  static const _keyHistory = 'stats_history';

  // Save a completed quiz result
  static Future<void> saveResult(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();

    final totalPoints =
        (prefs.getInt(_keyTotalPoints) ?? 0) + result.pointsEarned;
    final totalQuizzes = (prefs.getInt(_keyTotalQuizzes) ?? 0) + 1;
    final totalCorrect =
        (prefs.getInt(_keyTotalCorrect) ?? 0) + result.correctAnswers;
    final totalAnswered =
        (prefs.getInt(_keyTotalAnswered) ?? 0) + result.totalQuestions;

    await prefs.setInt(_keyTotalPoints, totalPoints);
    await prefs.setInt(_keyTotalQuizzes, totalQuizzes);
    await prefs.setInt(_keyTotalCorrect, totalCorrect);
    await prefs.setInt(_keyTotalAnswered, totalAnswered);

    // Save to history (keep last 20)
    final historyRaw = prefs.getStringList(_keyHistory) ?? [];
    historyRaw.insert(0, jsonEncode(result.toJson()));
    if (historyRaw.length > 20) historyRaw.removeLast();
    await prefs.setStringList(_keyHistory, historyRaw);
  }

  // Load all stats
  static Future<Map<String, dynamic>> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalPoints': prefs.getInt(_keyTotalPoints) ?? 0,
      'totalQuizzes': prefs.getInt(_keyTotalQuizzes) ?? 0,
      'totalCorrect': prefs.getInt(_keyTotalCorrect) ?? 0,
      'totalAnswered': prefs.getInt(_keyTotalAnswered) ?? 0,
    };
  }

  // Load quiz history
  static Future<List<QuizResult>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyRaw = prefs.getStringList(_keyHistory) ?? [];
    return historyRaw.map((e) => QuizResult.fromJson(jsonDecode(e))).toList();
  }

  // Calculate accuracy percentage
  static double accuracy(int correct, int total) {
    if (total == 0) return 0;
    return (correct / total) * 100;
  }

  // Calculate points for a question
  static int calculatePoints({
    required bool correct,
    required int secondsTaken,
    required bool isPerfectScore,
    required bool isLastQuestion,
  }) {
    if (!correct) return 0;
    int points = 10;
    if (secondsTaken <= 5) points += 5;
    if (isPerfectScore && isLastQuestion) points += 20;
    return points;
  }

  // Reset all stats
  static Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTotalPoints);
    await prefs.remove(_keyTotalQuizzes);
    await prefs.remove(_keyTotalCorrect);
    await prefs.remove(_keyTotalAnswered);
    await prefs.remove(_keyHistory);
  }
}
