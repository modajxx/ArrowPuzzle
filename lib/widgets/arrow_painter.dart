import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/direction.dart';

/// Paints an arrow with neon glow. Brightness of glow scales with [glowIntensity].
class ArrowPainter extends CustomPainter {
  final Direction direction;
  final Color color;
  final Color glowColor;
  final double scale;
  final double glowIntensity; // 0.0 - 1.0

  ArrowPainter({
    required this.direction,
    required this.color,
    Color? glowColor,
    this.scale = 1.0,
    this.glowIntensity = 0.7,
  }) : glowColor = glowColor ?? color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = math.min(size.width, size.height) * 0.6 * scale;
    final shaftThick = s * 0.20;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(_rotation);

    final shaftLeft = -s / 2;
    final shaftRight = s * 0.10;
    final shaftRect = RRect.fromLTRBR(
      shaftLeft,
      -shaftThick / 2,
      shaftRight,
      shaftThick / 2,
      Radius.circular(shaftThick * 0.5),
    );

    final headHalf = s * 0.30;
    final path = Path()
      ..moveTo(s * 0.02, -headHalf)
      ..lineTo(s / 2, 0)
      ..lineTo(s * 0.02, headHalf)
      ..close();

    // Outer glow (large, soft)
    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.45 * glowIntensity)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          8 + 6 * glowIntensity,
        );
      canvas.drawRRect(shaftRect, glowPaint);
      canvas.drawPath(path, glowPaint);

      // Inner glow (small, brighter)
      final innerGlow = Paint()
        ..color = glowColor.withValues(alpha: 0.6 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRRect(shaftRect, innerGlow);
      canvas.drawPath(path, innerGlow);
    }

    // Solid arrow body
    final fill = Paint()..color = color;
    canvas.drawRRect(shaftRect, fill);
    canvas.drawPath(path, fill);

    canvas.restore();
  }

  double get _rotation => switch (direction) {
        Direction.right => 0.0,
        Direction.down => math.pi / 2,
        Direction.left => math.pi,
        Direction.up => -math.pi / 2,
      };

  @override
  bool shouldRepaint(covariant ArrowPainter old) =>
      old.direction != direction ||
      old.color != color ||
      old.glowColor != glowColor ||
      old.scale != scale ||
      old.glowIntensity != glowIntensity;
}
