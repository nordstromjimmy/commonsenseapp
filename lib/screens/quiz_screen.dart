import 'package:commonsense_app/models/fact.dart';
import 'package:commonsense_app/screens/quiz_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/facts_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedCategoryId;
  String _selectedCategoryName = '';
  int _questionCount = 10;

  final List<int> _questionOptions = [5, 10, 15, 20];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FactsProvider>();
    final strings = provider.strings;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 8),

            // Header
            const SizedBox(height: 12),
            Text(
              strings.quiz,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.quizSubtitle,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Category selection
            _buildSectionLabel(strings.chooseCategory),
            const SizedBox(height: 10),

            // All categories option
            _buildCategoryTile(
              label: '✨ ${strings.all}',
              subtitle: strings.mixedQuestions,
              isSelected: _selectedCategoryId == null,
              onTap: () => setState(() {
                _selectedCategoryId = null;
                _selectedCategoryName = strings.all;
              }),
            ),
            const SizedBox(height: 8),

            // Category list
            ...provider.categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildCategoryTile(
                  label: '${cat.icon} ${cat.name}',
                  subtitle: null,
                  isSelected: _selectedCategoryId == cat.id,
                  onTap: () => setState(() {
                    _selectedCategoryId = cat.id;
                    _selectedCategoryName = cat.name;
                  }),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Question count
            _buildSectionLabel(strings.numberOfQuestions),
            const SizedBox(height: 10),
            Row(
              children: _questionOptions.map((count) {
                final isSelected = _questionCount == count;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _questionCount = count),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Points info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPointsRow(
                    Icons.check_box,
                    const Color(0xFF60A5FA),
                    strings.pointsPerCorrect,
                    '+10 pts',
                  ),
                  const SizedBox(height: 8),
                  _buildPointsRow(
                    Icons.strikethrough_s,
                    const Color(0xFF60A5FA),
                    strings.pointsSpeedBonus,
                    '+10 pts',
                  ),
                  const SizedBox(height: 8),
                  _buildPointsRow(
                    Icons.point_of_sale,
                    const Color(0xFF60A5FA),
                    strings.pointsPerfectBonus,
                    '+10 pts',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.facts.isEmpty
                    ? null
                    : () => _startQuiz(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: const Color(0xFF334155),
                ),
                child: Text(
                  strings.startQuiz,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, FactsProvider provider) {
    List<Fact> facts = provider.facts
        .where(
          (f) =>
              _selectedCategoryId == null ||
              f.categoryId == _selectedCategoryId,
        )
        .toList();

    if (facts.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough facts in this category for a quiz!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    facts.shuffle();
    final quizFacts = facts.take(_questionCount).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPlayScreen(
          facts: quizFacts,
          allFacts: provider.facts,
          categoryName: _selectedCategoryId == null
              ? provider.strings.all
              : _selectedCategoryName,
          quizQuestions: provider.quizQuestions,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCategoryTile({
    required String label,
    required String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1).withValues(alpha: 0.1)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF334155), width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsRow(
    IconData icon,
    Color color,
    String label,
    String points,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ),
        Text(
          points,
          style: const TextStyle(
            color: Color(0xFF6366F1),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
