import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HintButton extends StatefulWidget {
  final int hintsLeft;
  final VoidCallback? onTap;
  const HintButton({super.key, required this.hintsLeft, required this.onTap});

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && widget.hintsLeft > 0;
    final color = enabled
        ? AppColors.accent
        : (Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkTextMuted
            : AppColors.lightTextMuted);

    return GestureDetector(
      onTap: enabled ? widget.onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final pulse = enabled
              ? 0.5 + 0.5 * math.sin(_ctrl.value * 2 * math.pi)
              : 0.0;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.accent
                            .withValues(alpha: 0.25 + 0.25 * pulse),
                        blurRadius: 10 + 6 * pulse,
                        spreadRadius: 1 + 2 * pulse,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.lightbulb_outline, color: color, size: 26),
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: enabled
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '${widget.hintsLeft}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
