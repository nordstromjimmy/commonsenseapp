import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fact.dart';
import '../providers/facts_provider.dart';
import '../services/stats_service.dart';
import 'quiz_result_screen.dart';

class QuizPlayScreen extends StatefulWidget {
  final List<Fact> facts;
  final List<Fact> allFacts;
  final String categoryName;

  const QuizPlayScreen({
    super.key,
    required this.facts,
    required this.allFacts,
    required this.categoryName,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _totalPoints = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _allCorrectSoFar = true;
  DateTime? _questionStartTime;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _loadQuestion();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _loadQuestion() {
    final current = widget.facts[_currentIndex];
    final wrongPool =
        widget.allFacts
            .where((f) => f.id != current.id && f.answer != current.answer)
            .toList()
          ..shuffle();

    final wrongAnswers = wrongPool.take(3).map((f) => f.answer).toList();
    _options = [...wrongAnswers, current.answer]..shuffle();

    _selectedAnswer = null;
    _answered = false;
    _questionStartTime = DateTime.now();

    _progressController.animateTo((_currentIndex + 1) / widget.facts.length);
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final current = widget.facts[_currentIndex];
    final isCorrect = answer == current.answer;
    final secondsTaken = DateTime.now()
        .difference(_questionStartTime!)
        .inSeconds;
    final isLast = _currentIndex == widget.facts.length - 1;
    final willBePerfect = _allCorrectSoFar && isCorrect;

    final points = StatsService.calculatePoints(
      correct: isCorrect,
      secondsTaken: secondsTaken,
      isPerfectScore: willBePerfect,
      isLastQuestion: isLast,
    );

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (isCorrect) {
        _correctAnswers++;
        _totalPoints += points;
      } else {
        _allCorrectSoFar = false;
      }
    });
  }

  Future<void> _next() async {
    if (_currentIndex < widget.facts.length - 1) {
      setState(() => _currentIndex++);
      _loadQuestion();
    } else {
      // Save result
      final result = QuizResult(
        category: widget.categoryName,
        totalQuestions: widget.facts.length,
        correctAnswers: _correctAnswers,
        pointsEarned: _totalPoints,
        completedAt: DateTime.now(),
      );
      await StatsService.saveResult(result);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultScreen(
              result: result,
              facts: widget.facts,
              allFacts: widget.allFacts,
              categoryName: widget.categoryName,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.read<FactsProvider>().strings;
    final current = widget.facts[_currentIndex];
    final total = widget.facts.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showQuitDialog(context, strings.backHome),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, _) => LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: const Color(0xFF1E293B),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentIndex + 1}/$total',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Points display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalPoints pts',
                          style: const TextStyle(
                            color: Color(0xFF818CF8),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        widget.categoryName,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question text
                    Text(
                      current.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Answer options
                    ..._options.map(
                      (option) => _buildOption(
                        option: option,
                        correctAnswer: current.answer,
                        strings_next: strings.next,
                      ),
                    ),

                    // Explanation after answer
                    if (_answered && current.explanation.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          current.explanation,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Next button
                    if (_answered)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
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
                            _currentIndex < total - 1
                                ? strings.next
                                : strings.yourScore,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String option,
    required String correctAnswer,
    required String strings_next,
  }) {
    final isSelected = _selectedAnswer == option;
    final isCorrect = option == correctAnswer;

    Color bgColor = const Color(0xFF1E293B);
    Color borderColor = Colors.transparent;
    Color textColor = const Color(0xFF94A3B8);
    Widget? trailingIcon;

    if (_answered) {
      if (isCorrect) {
        bgColor = const Color(0xFF22C55E).withOpacity(0.1);
        borderColor = const Color(0xFF22C55E);
        textColor = const Color(0xFF4ADE80);
        trailingIcon = const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF22C55E),
          size: 20,
        );
      } else if (isSelected) {
        bgColor = const Color(0xFFEF4444).withOpacity(0.1);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFFC8181);
        trailingIcon = const Icon(
          Icons.cancel_rounded,
          color: Color(0xFFEF4444),
          size: 20,
        );
      }
    } else if (isSelected) {
      bgColor = const Color(0xFF6366F1).withOpacity(0.1);
      borderColor = const Color(0xFF6366F1);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }

  void _showQuitDialog(BuildContext context, String backLabel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Quit Quiz?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Your progress will be lost.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Quit',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}
