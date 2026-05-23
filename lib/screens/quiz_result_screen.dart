import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fact.dart';
import '../providers/facts_provider.dart';
import '../services/stats_service.dart';
import 'quiz_play_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;
  final List<Fact> facts;
  final List<Fact> allFacts;
  final String categoryName;
  final Map<int, List<String>> quizQuestions;

  const QuizResultScreen({
    super.key,
    required this.result,
    required this.facts,
    required this.allFacts,
    required this.categoryName,
    required this.quizQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final strings = context.read<FactsProvider>().strings;
    final percentage = StatsService.accuracy(
      result.correctAnswers,
      result.totalQuestions,
    );
    final isPerfect = result.correctAnswers == result.totalQuestions;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Trophy / result emoji
              Text(
                isPerfect
                    ? '🏆'
                    : percentage >= 70
                    ? '🎉'
                    : percentage >= 40
                    ? '💪'
                    : '📚',
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isPerfect ? strings.perfectScore : strings.yourScore,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoryName,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Score circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: _scoreColor(percentage), width: 4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toInt()}%',
                      style: TextStyle(
                        color: _scoreColor(percentage),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${result.correctAnswers} ${strings.outOf} ${result.totalQuestions}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Stats row
              Row(
                children: [
                  _buildStatCard(
                    emoji: '✅',
                    label: strings.correct,
                    value: '${result.correctAnswers}',
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    emoji: '⭐',
                    label: strings.pointsEarned,
                    value: '${result.pointsEarned}',
                    highlight: true,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    emoji: '❌',
                    label: 'Wrong',
                    value: '${result.totalQuestions - result.correctAnswers}',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bonus breakdown
              if (result.pointsEarned > result.correctAnswers * 10)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BONUS POINTS',
                        style: TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isPerfect)
                        _buildBonusRow('🏆', strings.perfectScore, '+20'),
                      _buildBonusRow(
                        '⚡',
                        strings.speedBonus,
                        '+${result.pointsEarned - (result.correctAnswers * 10) - (isPerfect ? 20 : 0)}',
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Play again button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPlayScreen(
                          facts: facts..shuffle(),
                          allFacts: allFacts,
                          categoryName: categoryName,
                          quizQuestions: quizQuestions,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    strings.playAgain,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    strings.backHome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _scoreColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF22C55E);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _buildStatCard({
    required String emoji,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: highlight
              ? const Color(0xFF6366F1).withOpacity(0.1)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: highlight
              ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.3))
              : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: highlight ? const Color(0xFF818CF8) : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBonusRow(String emoji, String label, String points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
          ),
          Text(
            points,
            style: const TextStyle(
              color: Color(0xFF818CF8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
