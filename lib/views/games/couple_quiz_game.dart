import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/quiz_questions.dart';
import '../../providers/game_provider.dart';
import '../../widgets/glass_card.dart';

class CoupleQuizGameView extends StatefulWidget {
  const CoupleQuizGameView({super.key});

  @override
  State<CoupleQuizGameView> createState() => _CoupleQuizGameViewState();
}

class _CoupleQuizGameViewState extends State<CoupleQuizGameView> {
  late final List<QuizQuestion> _questions;
  late int _cursor;
  int? _selected;
  bool _showAnswer = false;

  QuizQuestion get _question => _questions[_cursor % _questions.length];

  @override
  void initState() {
    super.initState();
    final provider = context.read<GameProvider>();
    _questions = List.of(provider.quizQuestions);
    _cursor = provider.quizCursor;
  }

  Future<void> _answer(int index) async {
    if (_showAnswer) return;
    setState(() {
      _selected = index;
      _showAnswer = true;
    });
    await context.read<GameProvider>().advanceQuiz();
    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    setState(() {
      _cursor++;
      _selected = null;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onu Ne Kadar Tanıyorsun? 💌'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Soru ${_cursor + 1}')),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: question.options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final correct = index == question.correctIndex;
                      final selected = index == _selected;
                      final color = !_showAnswer
                          ? Colors.white
                          : correct
                          ? Colors.green.shade400
                          : selected
                          ? Colors.red.shade400
                          : Colors.white;
                      return GlassCard(
                        color: color,
                        onTap: _showAnswer ? null : () => _answer(index),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryPink.withValues(
                                alpha: 0.14,
                              ),
                              child: Text(String.fromCharCode(65 + index)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: (_showAnswer && (correct || selected))
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  'Sorular sen çıkana kadar devam eder; kaldığın soru kaydedilir.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
