import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tap_effects_provider.dart';

class TapEffectsLayer extends StatefulWidget {
  final Widget child;
  final String surfaceId;

  const TapEffectsLayer({
    super.key,
    required this.child,
    required this.surfaceId,
  });

  @override
  State<TapEffectsLayer> createState() => _TapEffectsLayerState();
}

class _TapEffectsLayerState extends State<TapEffectsLayer>
    with TickerProviderStateMixin {
  final _random = Random();
  final _bursts = <_TapBurst>[];
  DateTime? _lastTapAt;
  Offset? _lastTapPosition;

  @override
  void dispose() {
    for (final burst in _bursts) {
      burst.controller.dispose();
    }
    super.dispose();
  }

  void _handlePointer(PointerDownEvent event, Size size) {
    if (size.isEmpty) return;
    final now = DateTime.now();
    final isDoubleTap =
        _lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 280) &&
        _lastTapPosition != null &&
        (event.localPosition - _lastTapPosition!).distance < 28;
    _lastTapAt = now;
    _lastTapPosition = event.localPosition;

    if (isDoubleTap) {
      context.read<TapEffectsProvider>().toggleHeart(
        widget.surfaceId,
        event.localPosition.dx / size.width,
        event.localPosition.dy / size.height,
      );
      _lastTapAt = null;
      return;
    }

    final burst = _TapBurst(event.localPosition, _random, this);
    setState(() {
      _bursts.add(burst);
      if (_bursts.length > 5) {
        _bursts.removeAt(0).controller.dispose();
      }
    });
    burst.controller.forward();
    burst.controller.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() => _bursts.remove(burst));
      burst.controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) => _handlePointer(event, size),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.child,
              IgnorePointer(
                child: Consumer<TapEffectsProvider>(
                  builder: (_, provider, _) => Stack(
                    children: [
                      for (final heart in provider.heartsFor(widget.surfaceId))
                        Positioned(
                          left: heart.x * size.width - 13,
                          top: heart.y * size.height - 13,
                          child: const Text(
                            '\u{1F499}',
                            style: TextStyle(fontSize: 26),
                          ),
                        ),
                      for (final burst in _bursts)
                        RepaintBoundary(child: _BurstParticles(burst: burst)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TapBurst {
  final Offset origin;
  final AnimationController controller;
  final List<_Particle> particles;

  _TapBurst(this.origin, Random random, TickerProvider vsync)
    : controller = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 520),
      ),
      particles = List.generate(6, (_) => _Particle(random));
}

class _Particle {
  final double angle;
  final double distance;
  final String emoji;

  _Particle(Random random)
    : angle = random.nextDouble() * pi * 2,
      distance = 24 + random.nextDouble() * 42,
      emoji = const [
        '\u{2728}',
        '\u{1F499}',
        '\u{1F496}',
        '\u{1F338}',
        '\u{2B50}',
      ][random.nextInt(5)];
}

class _BurstParticles extends StatelessWidget {
  final _TapBurst burst;

  const _BurstParticles({required this.burst});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: burst.controller,
      builder: (_, _) {
        final progress = Curves.easeOut.transform(burst.controller.value);
        return Stack(
          children: [
            for (final particle in burst.particles)
              _ParticleView(
                origin: burst.origin,
                particle: particle,
                progress: progress,
              ),
          ],
        );
      },
    );
  }
}

class _ParticleView extends StatelessWidget {
  final Offset origin;
  final _Particle particle;
  final double progress;

  const _ParticleView({
    required this.origin,
    required this.particle,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final offset = Offset(
      cos(particle.angle) * particle.distance * progress,
      sin(particle.angle) * particle.distance * progress - 16 * progress,
    );
    return Positioned(
      left: origin.dx + offset.dx - 10,
      top: origin.dy + offset.dy - 10,
      child: Opacity(
        opacity: 1 - progress,
        child: Transform.scale(
          scale: 1 - progress * 0.25,
          child: Text(particle.emoji, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}
