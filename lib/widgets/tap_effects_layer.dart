import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tap_heart.dart';
import '../providers/tap_effects_provider.dart';

class TapEffectsLayer extends StatefulWidget {
  final Widget child;
  final String surfaceId;
  final bool allowHeartPlacement;

  const TapEffectsLayer({
    super.key,
    required this.child,
    required this.surfaceId,
    this.allowHeartPlacement = true,
  });

  @override
  State<TapEffectsLayer> createState() => _TapEffectsLayerState();
}

class _TapEffectsLayerState extends State<TapEffectsLayer>
    with TickerProviderStateMixin {
  final _random = Random();
  final _bursts = <_TapBurst>[];
  final _pointerStarts = <int, Offset>{};
  final _scrollOffset = ValueNotifier<double>(0);
  DateTime? _lastTapAt;
  Offset? _lastTapPosition;

  @override
  void dispose() {
    _scrollOffset.dispose();
    for (final burst in _bursts) {
      burst.controller.dispose();
    }
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerStarts[event.pointer] = event.localPosition;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final origin = _pointerStarts[event.pointer];
    if (origin != null && (event.localPosition - origin).distance > 10) {
      // A drag/scroll must not start a particle animation while the
      // scrollable is already producing frames.
      _pointerStarts.remove(event.pointer);
    }
  }

  void _handlePointerUp(PointerUpEvent event, Size size) {
    if (_pointerStarts.remove(event.pointer) == null) return;
    _handleTap(event.localPosition, size);
  }

  void _handleTap(Offset position, Size size) {
    if (size.isEmpty) return;
    final now = DateTime.now();
    final isDoubleTap =
        _lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 360) &&
        _lastTapPosition != null &&
        (position - _lastTapPosition!).distance < 42;
    _lastTapAt = now;
    _lastTapPosition = position;

    if (isDoubleTap && widget.allowHeartPlacement) {
      context.read<TapEffectsProvider>().toggleHeart(
        widget.surfaceId,
        position.dx / size.width,
        position.dy + _scrollOffset.value,
      );
      _lastTapAt = null;
      return;
    }

    final burst = _TapBurst(position, _random, this);
    setState(() {
      _bursts.add(burst);
      if (_bursts.length > 3) {
        _bursts.removeAt(0).controller.dispose();
      }
    });
    burst.controller
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed || !mounted) return;
        setState(() => _bursts.remove(burst));
        burst.controller.dispose();
      })
      ..forward();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      final next = notification.metrics.pixels.clamp(0.0, double.infinity);
      if ((_scrollOffset.value - next).abs() > 0.5) {
        // Only the heart overlay listens to this notifier. The page, lists and
        // active particle painters are not rebuilt during scrolling.
        _scrollOffset.value = next;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: (event) => _handlePointerUp(event, size),
            onPointerCancel: (event) => _pointerStarts.remove(event.pointer),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(child: widget.child),
                if (widget.allowHeartPlacement)
                  IgnorePointer(
                    child: _HeartOverlay(
                      surfaceId: widget.surfaceId,
                      size: size,
                      scrollOffset: _scrollOffset,
                    ),
                  ),
                if (_bursts.isNotEmpty)
                  IgnorePointer(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _BurstPainter(List.of(_bursts)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeartOverlay extends StatelessWidget {
  final String surfaceId;
  final Size size;
  final ValueListenable<double> scrollOffset;

  const _HeartOverlay({
    required this.surfaceId,
    required this.size,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<TapEffectsProvider, List<TapHeart>>(
      selector: (_, provider) => provider.heartsFor(surfaceId).toList(),
      shouldRebuild: (previous, next) => !_sameHearts(previous, next),
      builder: (_, hearts, _) {
        if (hearts.isEmpty) return const SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: scrollOffset,
          builder: (_, offset, _) => RepaintBoundary(
            child: Stack(
              children: [
                for (final heart in hearts)
                  if (heart.contentY - offset >= -32 &&
                      heart.contentY - offset <= size.height + 32)
                    Positioned(
                      left: heart.x * size.width - 13,
                      top: heart.contentY - offset - 13,
                      child: const Icon(
                        Icons.favorite,
                        color: Color(0xFF1877F2),
                        size: 27,
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  static bool _sameHearts(List<TapHeart> a, List<TapHeart> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].x != b[i].x ||
          a[i].contentY != b[i].contentY) {
        return false;
      }
    }
    return true;
  }
}

class _TapBurst {
  final Offset origin;
  final AnimationController controller;
  final List<_Particle> particles;

  _TapBurst(this.origin, Random random, TickerProvider vsync)
    : controller = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 1150),
        animationBehavior: AnimationBehavior.preserve,
      ),
      particles = List.generate(6, (_) => _Particle(random));
}

class _Particle {
  final double angle;
  final double distance;
  final String emoji;

  _Particle(Random random)
    : angle = random.nextDouble() * pi * 2,
      distance = 34 + random.nextDouble() * 52,
      emoji = const [
        '\u{2728}',
        '\u{1F499}',
        '\u{1F496}',
        '\u{1F338}',
        '\u{2B50}',
      ][random.nextInt(5)];
}

class _BurstPainter extends CustomPainter {
  final List<_TapBurst> bursts;
  late final List<List<TextPainter>> _painters;

  _BurstPainter(this.bursts)
    : super(
        repaint: Listenable.merge(
          bursts.map((burst) => burst.controller).toList(growable: false),
        ),
      ) {
    _painters = bursts
        .map(
          (burst) => burst.particles
              .map(
                (particle) => TextPainter(
                  text: TextSpan(
                    text: particle.emoji,
                    style: const TextStyle(fontSize: 23),
                  ),
                  textDirection: TextDirection.ltr,
                )..layout(),
              )
              .toList(growable: false),
        )
        .toList(growable: false);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var burstIndex = 0; burstIndex < bursts.length; burstIndex++) {
      final burst = bursts[burstIndex];
      final progress = Curves.easeOutCubic.transform(burst.controller.value);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      for (var index = 0; index < burst.particles.length; index++) {
        final particle = burst.particles[index];
        final painter = _painters[burstIndex][index];
        final offset = Offset(
          cos(particle.angle) * particle.distance * progress,
          sin(particle.angle) * particle.distance * progress - 18 * progress,
        );
        final scale = 1 - progress * 0.22;
        canvas.save();
        canvas.translate(
          burst.origin.dx + offset.dx,
          burst.origin.dy + offset.dy,
        );
        canvas.scale(scale);
        // Fade only the tiny glyph bounds. A full-screen saveLayer here caused
        // a large GPU allocation for every animation frame on mobile devices.
        canvas.saveLayer(
          Rect.fromLTWH(
            -painter.width / 2,
            -painter.height / 2,
            painter.width,
            painter.height,
          ),
          Paint()..color = Colors.white.withValues(alpha: opacity),
        );
        painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
        canvas.restore();
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) {
    if (oldDelegate.bursts.length != bursts.length) return true;
    for (var index = 0; index < bursts.length; index++) {
      if (!identical(oldDelegate.bursts[index], bursts[index])) return true;
    }
    return false;
  }
}
