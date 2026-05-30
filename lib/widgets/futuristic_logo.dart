import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/direction.dart';
import '../theme/app_theme.dart';
import 'arrow_painter.dart';

/// A square "puzzle tile" logo — a mini 3x3 arrow grid, one arrow glowing.
/// Looks game-like (similar in spirit to Easybrain's puzzle-tile icons),
/// not abstract.
class FuturisticLogo extends StatefulWidget {
  final double size;
  const FuturisticLogo({super.key, this.size = 140});

  @override
  State<FuturisticLogo> createState() => _FuturisticLogoState();
}

class _FuturisticLogoState extends State<FuturisticLogo>
    with TickerProviderStateMixin {
  late final AnimationController _highlight;
  late final AnimationController _pulse;

  // Fixed mini-puzzle pattern (3x3): nulls + colored arrows
  static const _pattern = <List<Direction?>>[
    [Direction.right, Direction.right, Direction.down],
    [null, Direction.up, Direction.down],
    [Direction.up, null, Direction.left],
  ];
  static const _highlightCells = [(0, 0), (1, 1), (2, 2), (0, 2), (2, 0)];

  @override
  void initState() {
    super.initState();
    _highlight = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _highlight.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_highlight, _pulse]),
        builder: (_, _) {
          final pulse = 0.5 + 0.5 * math.sin(_pulse.value * 2 * math.pi);
          final hlIndex =
              (_highlight.value * _highlightCells.length).floor() %
                  _highlightCells.length;
          final hlCell = _highlightCells[hlIndex];

          return Stack(
            children: [
              // Outer glow
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan
                          .withValues(alpha: 0.45 + 0.20 * pulse),
                      blurRadius: 28 + 16 * pulse,
                      spreadRadius: 2 + 3 * pulse,
                    ),
                    BoxShadow(
                      color: AppColors.neonPurple
                          .withValues(alpha: 0.3 + 0.15 * pulse),
                      blurRadius: 40 + 12 * pulse,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              // Tile background
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A2A55),
                      Color(0xFF0A0E27),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              // 3x3 grid of mini-arrows
              Padding(
                padding: EdgeInsets.all(size * 0.12),
                child: Column(
                  children: List.generate(3, (r) {
                    return Expanded(
                      child: Row(
                        children: List.generate(3, (c) {
                          return Expanded(
                            child: _buildMiniCell(
                              dir: _pattern[r][c],
                              highlighted: hlCell == (r, c),
                              pulse: pulse,
                              cellSize: size * 0.25,
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
              // Corner accent dot
              Positioned(
                top: size * 0.08,
                right: size * 0.08,
                child: Container(
                  width: 6 + 4 * pulse,
                  height: 6 + 4 * pulse,
                  decoration: BoxDecoration(
                    color: AppColors.neonPink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPink.withValues(alpha: 0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMiniCell({
    required Direction? dir,
    required bool highlighted,
    required double pulse,
    required double cellSize,
  }) {
    if (dir == null) {
      return Center(
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.darkDot,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    final color = highlighted
        ? AppColors.neonPink
        : AppColors.neonCyan.withValues(alpha: 0.85);
    return CustomPaint(
      painter: ArrowPainter(
        direction: dir,
        color: color,
        glowColor: color,
        glowIntensity: highlighted ? 0.9 + 0.1 * pulse : 0.3,
        scale: 0.85,
      ),
    );
  }
}
