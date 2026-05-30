import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/arrow.dart';
import '../theme/app_theme.dart';
import 'arrow_painter.dart';

class ArrowCell extends StatefulWidget {
  final Arrow? arrow;
  final double size;
  final bool escaping;
  final bool blocked;
  final int blockedNonce;
  final bool hint;
  final int hintNonce;
  final bool canEscape;
  final int entryIndex;
  final VoidCallback? onTap;

  const ArrowCell({
    super.key,
    required this.arrow,
    required this.size,
    this.escaping = false,
    this.blocked = false,
    this.blockedNonce = 0,
    this.hint = false,
    this.hintNonce = 0,
    this.canEscape = false,
    this.entryIndex = 0,
    this.onTap,
  });

  @override
  State<ArrowCell> createState() => _ArrowCellState();
}

class _ArrowCellState extends State<ArrowCell>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _ripple;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2800 + widget.entryIndex * 60),
    )..repeat();
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _idle.dispose();
    _ripple.dispose();
    super.dispose();
  }

  void _onTap() {
    _ripple.forward(from: 0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark ? AppColors.darkDot : AppColors.lightDot;
    final arrowColor = AppColors.neonCyan;

    if (widget.arrow == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dotColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    final color = widget.blocked ? AppColors.heart : arrowColor;
    final size = widget.size;

    // Pulsing idle: subtle float + brightness pulse
    Widget core = AnimatedBuilder(
      animation: _idle,
      builder: (_, _) {
        final pulse = math.sin(_idle.value * 2 * math.pi);
        final dy = pulse * 1.5;
        final baseGlow = widget.canEscape ? 0.85 : 0.45;
        final glow = baseGlow + 0.20 * pulse;
        return Transform.translate(
          offset: Offset(0, dy),
          child: CustomPaint(
            size: Size(size, size),
            painter: ArrowPainter(
              direction: widget.arrow!.direction,
              color: color,
              glowColor: color,
              glowIntensity: glow,
            ),
          ),
        );
      },
    );

    // Tap ripple overlay
    core = Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _ripple,
          builder: (_, _) {
            final v = _ripple.value;
            if (v == 0) return const SizedBox();
            return Container(
              width: size * (0.4 + 0.6 * v),
              height: size * (0.4 + 0.6 * v),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: (1 - v) * 0.6),
                  width: 2,
                ),
              ),
            );
          },
        ),
        core,
      ],
    );

    if (widget.hint) {
      core = TweenAnimationBuilder<double>(
        key: ValueKey('hint-${widget.hintNonce}'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 2500),
        builder: (_, t, child) {
          final pulse = (math.sin(t * math.pi * 4).abs()) * (1 - t);
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.neonPurple.withValues(alpha: 0.4 * pulse + 0.1),
                  AppColors.neonPurple.withValues(alpha: 0),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPurple
                      .withValues(alpha: 0.4 + 0.5 * pulse),
                  blurRadius: 18 * pulse + 4,
                  spreadRadius: 3 * pulse,
                ),
              ],
            ),
            child: child,
          );
        },
        child: core,
      );
    }

    if (widget.escaping) {
      final (dr, dc) = widget.arrow!.direction.delta;
      core = TweenAnimationBuilder<double>(
        key: ValueKey('escape-${identityHashCode(widget.arrow)}'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeIn,
        builder: (_, t, child) => Opacity(
          opacity: 1 - t,
          child: Transform.translate(
            offset: Offset(dc * size * t * 1.8, dr * size * t * 1.8),
            child: Transform.scale(scale: 1 + 0.3 * t, child: child),
          ),
        ),
        child: core,
      );
    } else if (widget.blocked) {
      core = TweenAnimationBuilder<double>(
        key: ValueKey('shake-${widget.blockedNonce}'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 420),
        builder: (_, t, child) {
          final shake = math.sin(t * math.pi * 6) * (1 - t) * 8;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: core,
      );
    }

    // Staggered entrance
    core = TweenAnimationBuilder<double>(
      key: ValueKey('entry-${identityHashCode(widget.arrow)}'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + widget.entryIndex * 40),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) {
        final delayFrac =
            (widget.entryIndex * 40) / (360 + widget.entryIndex * 40).toDouble();
        final adj = ((t - delayFrac) / (1 - delayFrac)).clamp(0.0, 1.0);
        return Opacity(
          opacity: adj,
          child: Transform.scale(scale: 0.5 + 0.5 * adj, child: child),
        );
      },
      child: core,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: core,
    );
  }
}
