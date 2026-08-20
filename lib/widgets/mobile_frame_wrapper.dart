import 'dart:math' as math;

import 'package:flutter/material.dart';

class MobileFrameWrapper extends StatelessWidget {
  final Widget child;

  const MobileFrameWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 720) return child;
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: SizedBox(
              width: math.min(720, constraints.maxWidth),
              height: constraints.maxHeight,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 24)],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
