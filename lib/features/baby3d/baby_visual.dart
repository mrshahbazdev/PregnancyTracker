import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// An interactive, fully offline "3D-style" baby visualization that scales and
/// changes shape with the gestational week. Users can drag to rotate it.
///
/// This is the reliable default renderer. A photorealistic glTF/AR model
/// (model_viewer_plus / Filament) can be layered on top per-week in production.
class BabyVisual extends StatefulWidget {
  const BabyVisual({super.key, required this.week});

  final int week;

  @override
  State<BabyVisual> createState() => _BabyVisualState();
}

class _BabyVisualState extends State<BabyVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob;
  double _rotationY = 0.4;
  double _dragStart = 0;
  double _rotationStart = 0;

  @override
  void initState() {
    super.initState();
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scale factor: week 4 (tiny) → week 40 (full). Non-linear for nicer feel.
    final t = ((widget.week - 4) / 36).clamp(0.0, 1.0);
    final scale = 0.16 + math.pow(t, 0.8).toDouble() * 0.84;

    return GestureDetector(
      onHorizontalDragStart: (d) {
        _dragStart = d.globalPosition.dx;
        _rotationStart = _rotationY;
      },
      onHorizontalDragUpdate: (d) {
        setState(() {
          _rotationY =
              _rotationStart + (d.globalPosition.dx - _dragStart) * 0.01;
        });
      },
      child: AnimatedBuilder(
        animation: _bob,
        builder: (context, _) {
          final bob = math.sin(_bob.value * math.pi * 2) * 6;
          return Center(
            child: Transform.translate(
              offset: Offset(0, bob),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(_rotationY),
                child: FractionallySizedBox(
                  widthFactor: scale,
                  heightFactor: scale,
                  child: CustomPaint(
                    painter: _BabyPainter(progress: t),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BabyPainter extends CustomPainter {
  _BabyPainter({required this.progress});

  /// 0 (early embryo) → 1 (full-term baby). Drives proportions.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Soft glow behind the baby.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.45),
          AppColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.55));
    canvas.drawCircle(center, w * 0.55, glow);

    final skin = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF6C9B8), Color(0xFFE8A98F)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Head: relatively larger early in pregnancy, more proportionate later.
    final headRadius = w * (0.30 - progress * 0.07);
    // Body curls below/around for the classic fetal pose.
    final bodyRadius = w * (0.20 + progress * 0.14);

    final headCenter = Offset(center.dx + w * 0.05, center.dy - h * 0.14);
    final bodyCenter = Offset(center.dx - w * 0.02, center.dy + h * 0.12);

    // Body (curled).
    canvas.drawCircle(bodyCenter, bodyRadius, skin);

    // A limb hint (knee tucked) — grows with progress.
    final limb = Path()
      ..moveTo(bodyCenter.dx - bodyRadius * 0.2, bodyCenter.dy)
      ..quadraticBezierTo(
        bodyCenter.dx - bodyRadius * (0.9 + progress * 0.4),
        bodyCenter.dy + bodyRadius * 0.2,
        bodyCenter.dx - bodyRadius * 0.4,
        bodyCenter.dy + bodyRadius * (0.9 + progress * 0.3),
      )
      ..quadraticBezierTo(
        bodyCenter.dx,
        bodyCenter.dy + bodyRadius * 0.5,
        bodyCenter.dx - bodyRadius * 0.2,
        bodyCenter.dy,
      );
    canvas.drawPath(limb, skin);

    // Head.
    canvas.drawCircle(headCenter, headRadius, skin);

    // Subtle shading on head for depth.
    final shade = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.transparent,
        ],
      ).createShader(
          Rect.fromCircle(center: headCenter, radius: headRadius));
    canvas.drawCircle(headCenter, headRadius, shade);

    // Facial features emerge after ~week 12 (progress ~0.22).
    if (progress > 0.22) {
      final featureAlpha = ((progress - 0.22) / 0.3).clamp(0.0, 1.0);
      final eye = Paint()
        ..color = const Color(0xFF5A3E36).withValues(alpha: featureAlpha);
      final eyeY = headCenter.dy - headRadius * 0.05;
      final eyeDx = headRadius * 0.35;
      final eyeR = headRadius * 0.07;
      canvas.drawCircle(
          Offset(headCenter.dx - eyeDx, eyeY), eyeR, eye);
      canvas.drawCircle(
          Offset(headCenter.dx + eyeDx * 0.4, eyeY), eyeR, eye);

      // Nose / mouth hint.
      final line = Paint()
        ..color = const Color(0xFFCB8A75).withValues(alpha: featureAlpha)
        ..strokeWidth = headRadius * 0.05
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(headCenter.dx - headRadius * 0.18,
            headCenter.dy + headRadius * 0.4),
        Offset(headCenter.dx + headRadius * 0.12,
            headCenter.dy + headRadius * 0.4),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BabyPainter old) =>
      old.progress != progress;
}
