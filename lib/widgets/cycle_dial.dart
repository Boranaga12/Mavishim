import 'dart:math';
import 'package:flutter/material.dart';
import '../core/utils/cycle_calculator.dart';
import '../core/theme/cycle_phase_theme.dart';

class CycleDial extends StatelessWidget {
  final CycleInfo cycleInfo;

  const CycleDial({super.key, required this.cycleInfo});

  @override
  Widget build(BuildContext context) {
    final progress = (cycleInfo.currentCycleDay / cycleInfo.cycleLength).clamp(
      0.0,
      1.0,
    );
    final daysRemaining = cycleInfo.daysUntilNextPeriod;
    final isLate = cycleInfo.isLate;

    return RepaintBoundary(
      child: Center(
        child: SizedBox(
          width: 210,
          height: 210,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(200, 200),
                painter: _DialPainter(
                  progress: isLate ? 1.0 : progress,
                  phaseColor: cycleInfo.phaseColor,
                  trackColor: Colors.white,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cycleInfo.phaseColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLate ? Icons.warning_amber_rounded : Icons.favorite,
                      color: cycleInfo.phaseColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLate
                        ? '${cycleInfo.daysLate} GÜN GECİKTİ'
                        : '${cycleInfo.currentCycleDay}. GÜN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLate ? 17 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF331B29),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLate
                        ? 'Adet Bekleniyor'
                        : (daysRemaining == 0
                              ? 'Bugün Bekleniyor'
                              : 'Regle $daysRemaining Gün Kaldı'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cycleInfo.phaseColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final Color phaseColor;
  final Color trackColor;

  _DialPainter({
    required this.progress,
    required this.phaseColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    const strokeWidth = 12.0;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Paint
    final progressPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Active dot at tip
    final dotAngle = -pi / 2 + sweepAngle;
    final dotX = center.dx + radius * cos(dotAngle);
    final dotY = center.dy + radius * sin(dotAngle);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 1, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phaseColor != phaseColor;
  }
}
