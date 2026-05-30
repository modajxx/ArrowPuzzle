import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Futuristic animated background: dark gradient + grid lines + drifting
/// star/particle field + scanning glow lines.
class AppBackground extends StatefulWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    final rng = math.Random(7);
    _stars = List.generate(60, (_) => _Star.random(rng));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = isDark ? AppColors.darkBgTop : AppColors.lightBgTop;
    final bottom = isDark ? AppColors.darkBgBottom : AppColors.lightBgBottom;
    final gridLine = isDark ? AppColors.darkGridLine : AppColors.lightGridLine;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.6),
          radius: 1.6,
          colors: [top, bottom],
        ),
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => CustomPaint(
          painter: _FuturisticPainter(
            t: _ctrl.value,
            gridColor: gridLine,
            stars: _stars,
            isDark: isDark,
          ),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  _Star(this.x, this.y, this.size, this.speed, this.phase);
  static _Star random(math.Random rng) => _Star(
        rng.nextDouble(),
        rng.nextDouble(),
        rng.nextDouble() * 1.8 + 0.4,
        rng.nextDouble() * 0.3 + 0.1,
        rng.nextDouble() * 2 * math.pi,
      );
}

class _FuturisticPainter extends CustomPainter {
  final double t;
  final Color gridColor;
  final List<_Star> stars;
  final bool isDark;
  _FuturisticPainter({
    required this.t,
    required this.gridColor,
    required this.stars,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid lines (cyber overlay)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    const spacing = 60.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Drifting stars
    for (final s in stars) {
      final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi + s.phase);
      final paint = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: pulse * 0.6);
      final dy = (s.y + t * s.speed) % 1.0;
      canvas.drawCircle(
        Offset(s.x * size.width, dy * size.height),
        s.size * (0.7 + 0.5 * pulse),
        paint,
      );
    }

    // 3. Scanning glow sweep (horizontal)
    if (isDark) {
      final sweepY = (t * 2.0) % 1.2 - 0.1;
      if (sweepY >= 0 && sweepY <= 1) {
        final sweepRect = Rect.fromLTWH(
            0, sweepY * size.height - 30, size.width, 60);
        final sweepPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.neonCyan.withValues(alpha: 0.06),
              Colors.transparent,
            ],
          ).createShader(sweepRect);
        canvas.drawRect(sweepRect, sweepPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FuturisticPainter old) => true;
}
