import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../providers/game_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../data/quiz_questions.dart';

class CoupleQuizGameView extends StatefulWidget {
  const CoupleQuizGameView({super.key});

  @override
  State<CoupleQuizGameView> createState() => _CoupleQuizGameViewState();
}

class _CoupleQuizGameViewState extends State<CoupleQuizGameView> {
  late ConfettiController _confettiController;
  late final List<QuizQuestion> _questions;
  late QuizQuestion _currentQuestion;
  int? _selectedOptionIndex;
  bool _isAnswering = false;
  bool? _isCorrectAnswer;

  int _correctCount = 0;
  int _streakCount = 0;
  int _totalAnswered = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 500),
    );
    _questions = List<QuizQuestion>.from(
      context.read<GameProvider>().quizQuestions,
    )..shuffle(Random());
    _currentQuestion = _questions.first;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _loadNextQuestion() {
    if (_totalAnswered >= _questions.length) {
      _finishQuiz();
      return;
    }
    setState(() {
      _currentQuestion = _questions[_totalAnswered];
      _selectedOptionIndex = null;
      _isAnswering = false;
      _isCorrectAnswer = null;
    });
  }

  void _answerQuestion(int selectedIndex) {
    if (_isAnswering) return;

    final isCorrect = selectedIndex == _currentQuestion.correctIndex;

    setState(() {
      _isAnswering = true;
      _selectedOptionIndex = selectedIndex;
      _isCorrectAnswer = isCorrect;
      _totalAnswered++;
    });

    if (isCorrect) {
      _correctCount++;
      _streakCount++;
      _confettiController.play();
    } else {
      _streakCount = 0;
    }

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        _loadNextQuestion();
      }
    });
  }

  Future<void> _finishQuiz() async {
    final percentage = ((_correctCount / _questions.length) * 100).round();
    await context.read<GameProvider>().updateQuizScore(percentage);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quiz Tamamlandı 🎉'),
        content: Text(
          '${_questions.length} soruda $_correctCount doğru cevap verdin.\nBaşarı: %$percentage',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Onu Ne Kadar Tanıyorsun? 💌',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.deepOrange,
                      size: 16,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Seri: $_streakCount',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score & Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cevaplanan: $_totalAnswered/${_questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          'Doğru: $_correctCount',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Question Card
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        _currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF331B29),
                          height: 1.35,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Visual Feedback Text Banner
                    if (_isAnswering)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isCorrectAnswer == true
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isCorrectAnswer == true
                                ? Colors.green.shade400
                                : Colors.red.shade400,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isCorrectAnswer == true
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: _isCorrectAnswer == true
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isCorrectAnswer == true
                                    ? 'Tebrikler! Doğru Cevap! 🎉💖'
                                    : 'Yanlış Cevap! Doğru: ${_currentQuestion.options[_currentQuestion.correctIndex]} 💔',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _isCorrectAnswer == true
                                      ? Colors.green.shade900
                                      : Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 4 Options List with Color Highlights & Flashes
                    Expanded(
                      child: ListView.separated(
                        itemCount: _currentQuestion.options.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedOptionIndex == index;
                          final isCorrectIndex =
                              index == _currentQuestion.correctIndex;

                          Color cardColor = Colors.white.withValues(
                            alpha: 0.92,
                          );
                          Color textColor = const Color(0xFF331B29);
                          Color iconBgColor = AppTheme.primaryPink.withValues(
                            alpha: 0.15,
                          );
                          Color iconColor = AppTheme.primaryPink;

                          if (_isAnswering) {
                            if (isSelected) {
                              if (isCorrectIndex) {
                                cardColor = Colors.green.shade500;
                                textColor = Colors.white;
                                iconBgColor = Colors.white.withValues(
                                  alpha: 0.25,
                                );
                                iconColor = Colors.white;
                              } else {
                                cardColor = Colors.red.shade400;
                                textColor = Colors.white;
                                iconBgColor = Colors.white.withValues(
                                  alpha: 0.25,
                                );
                                iconColor = Colors.white;
                              }
                            } else if (isCorrectIndex) {
                              cardColor = Colors.green.shade400;
                              textColor = Colors.white;
                              iconBgColor = Colors.white.withValues(
                                alpha: 0.25,
                              );
                              iconColor = Colors.white;
                            }
                          }

                          return GlassCard(
                            color: cardColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            onTap: _isAnswering
                                ? null
                                : () => _answerQuestion(index),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: iconBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: iconColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _currentQuestion.options[index],
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (_isAnswering && isCorrectIndex)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 6,
                emissionFrequency: 0.02,
                shouldLoop: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
