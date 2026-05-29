import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../state/app_colors.dart';

/// Animated “Northern Lights” background with vignette + subtle grain.
///
/// Designed to be placed behind screens (ignore pointer).
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    this.intensity = 1.0,
    this.enableBlur = true,
    this.enableGrain = true,
  });

  final double intensity;
  final bool enableBlur;
  final bool enableGrain;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9000),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.intensity <= 0) {
      return const IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(color: AppColors.bg),
        ),
      );
    }

    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                // Base color.
                const DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.bg),
                ),
                // Aurora blobs.
                CustomPaint(
                  painter: _AuroraPainter(t: t, intensity: widget.intensity),
                ),
                // Soft blur for “glow”.
                if (widget.enableBlur)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                    child: const SizedBox.expand(),
                  ),
                // Vignette (focus center).
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.10),
                      radius: 1.05,
                      colors: [
                        Colors.transparent,
                        Color(0x99000000),
                      ],
                      stops: [0.55, 1.0],
                    ),
                  ),
                ),
                // Subtle grain/noise.
                if (widget.enableGrain)
                  Opacity(
                    opacity: 0.10 * widget.intensity,
                    child: const CustomPaint(painter: _GrainPainter()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({required this.t, required this.intensity});

  final double t; // 0..1
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final p = Paint()..blendMode = BlendMode.screen;

    // Animated anchors.
    final a1 = Offset(
      size.width * (0.15 + 0.08 * math.sin(t * math.pi * 2)),
      size.height * (0.22 + 0.06 * math.cos(t * math.pi * 2)),
    );
    final a2 = Offset(
      size.width * (0.78 + 0.06 * math.cos(t * math.pi * 2)),
      size.height * (0.32 + 0.08 * math.sin(t * math.pi * 2)),
    );
    final a3 = Offset(
      size.width * (0.48 + 0.10 * math.sin(t * math.pi * 2 + 1.7)),
      size.height * (0.82 + 0.06 * math.cos(t * math.pi * 2 + 1.2)),
    );

    void blob({
      required Offset c,
      required double r,
      required Color color,
      double alpha = 1,
    }) {
      final a = (alpha * intensity).clamp(0.0, 1.0);
      final shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.20 * a),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.58, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
      p.shader = shader;
      canvas.drawRect(rect, p);
    }

    blob(c: a1, r: size.shortestSide * 0.58, color: AppColors.secondary, alpha: 0.95);
    blob(c: a2, r: size.shortestSide * 0.52, color: AppColors.primary, alpha: 0.90);
    blob(c: a3, r: size.shortestSide * 0.66, color: AppColors.accent, alpha: 0.55);

    // Cold gradient sweep.
    final sweep = LinearGradient(
      begin: Alignment(-1.0, -0.6 + 0.12 * math.sin(t * math.pi * 2)),
      end: Alignment(1.0, 0.9),
      colors: [
        AppColors.primary.withValues(alpha: 0.12 * intensity),
        AppColors.secondary.withValues(alpha: 0.10 * intensity),
        Colors.transparent,
      ],
    ).createShader(rect);
    p.shader = sweep;
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.intensity != intensity;
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.12);

    // Deterministic “noise” based on size; cheap and stable.
    final seed = (size.width * 1000).round() ^ (size.height * 1000).round();
    final r = math.Random(seed);

    final dots = (size.shortestSide * 0.90).round().clamp(220, 640);
    for (var i = 0; i < dots; i++) {
      final dx = r.nextDouble() * size.width;
      final dy = r.nextDouble() * size.height;
      final s = 0.5 + r.nextDouble() * 1.2;
      final a = 0.025 + r.nextDouble() * 0.05;
      paint.color = Colors.white.withValues(alpha: a);
      canvas.drawRect(Rect.fromLTWH(dx, dy, s, s), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}

