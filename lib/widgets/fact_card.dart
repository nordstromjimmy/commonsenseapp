import 'package:commonsense_app/l10n/app_strings.dart';
import 'package:commonsense_app/models/category.dart';
import 'package:flutter/material.dart';
import '../models/fact.dart';

class FactCard extends StatefulWidget {
  final Fact fact;
  final VoidCallback? onNext;
  final Category? category;
  final AppStrings strings;

  const FactCard({
    super.key,
    required this.fact,
    required this.strings,
    this.onNext,
    this.category,
  });

  @override
  State<FactCard> createState() => _FactCardState();
}

class _FactCardState extends State<FactCard>
    with SingleTickerProviderStateMixin {
  bool _revealed = false;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void didUpdateWidget(FactCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fact.id != widget.fact.id) {
      _revealed = false;
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reveal() {
    setState(() => _revealed = true);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Row(
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
                  child: Text(
                    widget.strings.didYouKnow,
                    style: TextStyle(
                      color: Color(0xFF818CF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.category != null)
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
                      widget.category!.name,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Question
            Text(
              widget.fact.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Reveal or answer
            if (!_revealed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _reveal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.strings.showAnswer,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Answer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF22C55E).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.fact.answer,
                              style: const TextStyle(
                                color: Color(0xFF4ADE80),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Explanation
                    Text(
                      widget.fact.explanation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
