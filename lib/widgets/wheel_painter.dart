import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class WheelPainter extends CustomPainter {
  final List<String> options;

  const WheelPainter({required this.options});

  static const _colors = [
    Color(0xFFFF5F78),
    Color(0xFFE85D92),
    Color(0xFFB7791F),
    Color(0xFF287A62),
    Color(0xFF8054A6),
    Color(0xFFC43D72),
    Color(0xFF4A154B),
    Color(0xFF71329D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final sweepAngle = (2 * pi) / options.length;

    for (var index = 0; index < options.length; index++) {
      final startAngle = index * sweepAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()..color = _colors[index % _colors.length],
      );
      _paintLabel(
        canvas,
        center,
        radius,
        startAngle,
        sweepAngle,
        options[index],
      );
    }

    canvas.drawCircle(center, 20, Paint()..color = Colors.white);
    canvas.drawCircle(center, 11, Paint()..color = AppTheme.primaryPink);
  }

  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    String label,
  ) {
    final angle = startAngle + sweepAngle / 2;
    final position = Offset(
      center.dx + radius * 0.67 * cos(angle),
      center.dy + radius * 0.67 * sin(angle),
    );
    final maxCharacters = options.length > 18
        ? 9
        : options.length > 12
        ? 12
        : 16;
    final visibleLabel = label.length > maxCharacters
        ? '${label.substring(0, maxCharacters - 1)}…'
        : label;
    final painter = TextPainter(
      text: TextSpan(
        text: visibleLabel,
        style: TextStyle(
          color: Colors.white,
          fontSize: options.length > 20
              ? 7.5
              : options.length > 14
              ? 9
              : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: radius * 0.48);

    canvas
      ..save()
      ..translate(position.dx, position.dy)
      ..rotate(angle);
    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) =>
      !identical(oldDelegate.options, options) &&
      oldDelegate.options != options;
}
