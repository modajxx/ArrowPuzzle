import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HeartBar extends StatefulWidget {
  final int lives;
  final int max;
  const HeartBar({super.key, required this.lives, this.max = 3});

  @override
  State<HeartBar> createState() => _HeartBarState();
}

class _HeartBarState extends State<HeartBar> {
  late int _lastLives = widget.lives;

  @override
  void didUpdateWidget(covariant HeartBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lives != widget.lives) {
      _lastLives = oldWidget.lives;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.max, (i) {
        final wasFilled = i < _lastLives;
        final filled = i < widget.lives;
        final justLost = wasFilled && !filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: TweenAnimationBuilder<double>(
            key: ValueKey('heart-$i-${widget.lives}'),
            tween: Tween(begin: justLost ? 1 : 0, end: justLost ? 0 : 1),
            duration: const Duration(milliseconds: 360),
            curve: justLost ? Curves.easeIn : Curves.easeOutBack,
            builder: (_, t, _) {
              final scale = justLost ? (1.0 + 0.6 * (1 - t)) : t;
              return Opacity(
                opacity: filled ? 1.0 : (justLost ? t : 0.3),
                child: Transform.scale(
                  scale: scale.clamp(0.5, 1.6),
                  child: _Heart(filled: filled || justLost),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _Heart extends StatelessWidget {
  final bool filled;
  const _Heart({required this.filled});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => filled
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.heart, AppColors.heartDeep],
            ).createShader(rect)
          : LinearGradient(
              colors: [
                AppColors.heart.withValues(alpha: 0.35),
                AppColors.heartDeep.withValues(alpha: 0.35),
              ],
            ).createShader(rect),
      child: Icon(
        filled ? Icons.favorite : Icons.favorite_border,
        size: 26,
        color: Colors.white,
      ),
    );
  }
}
