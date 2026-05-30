import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../models/level.dart';
import '../services/game_notifier.dart';
import '../engine/solver.dart';
import '../services/level_service.dart';
import '../services/progress_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/grid_board.dart';
import '../widgets/heart_bar.dart';
import '../widgets/hint_button.dart';
import 'level_loader_screen.dart';

/// Optional custom completion recorder. Receives the earned stars (1-3).
typedef CompletionRecorder = Future<void> Function(int stars);

class GameScreen extends StatelessWidget {
  final Level level;
  final CompletionRecorder? onComplete;
  final bool hideNextLevel;

  const GameScreen({
    super.key,
    required this.level,
    this.onComplete,
    this.hideNextLevel = false,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [currentLevelProvider.overrideWithValue(level)],
      child: _GameScreenBody(
        onComplete: onComplete,
        hideNextLevel: hideNextLevel,
      ),
    );
  }
}

class _GameScreenBody extends ConsumerStatefulWidget {
  final CompletionRecorder? onComplete;
  final bool hideNextLevel;
  const _GameScreenBody({required this.onComplete, required this.hideNextLevel});

  @override
  ConsumerState<_GameScreenBody> createState() => _GameScreenBodyState();
}

class _GameScreenBodyState extends ConsumerState<_GameScreenBody>
    with TickerProviderStateMixin {
  late final AnimationController _shake;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _shake.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shake.forward(from: 0);
  }

  void _triggerConfetti() {
    _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);

    ref.listen<int>(gameProvider.select((s) => s.blockedNonce),
        (prev, next) {
      if (prev != null && next > prev) _triggerShake();
    });

    ref.listen<GameState>(gameProvider, (prev, next) {
      if (prev?.status != GameStatus.complete &&
          next.status == GameStatus.complete) {
        _triggerConfetti();
        _recordCompletion(ref, next);
      }
    });

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _shake,
                builder: (_, child) {
                  final dx =
                      math.sin(_shake.value * math.pi * 5) * (1 - _shake.value) * 10;
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    _TopBar(state: state),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: const GridBoard(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          HintButton(
                            hintsLeft: state.hints,
                            onTap: state.status == GameStatus.playing
                                ? notifier.useHint
                                : null,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirection: math.pi / 2,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.05,
                  numberOfParticles: 24,
                  maxBlastForce: 30,
                  minBlastForce: 10,
                  gravity: 0.25,
                  colors: const [
                    AppColors.neonCyan,
                    AppColors.neonPurple,
                    AppColors.star,
                    AppColors.heart,
                    AppColors.neonGreen,
                  ],
                ),
              ),
              if (state.status == GameStatus.complete)
                _OverlayPanel(
                  key: const ValueKey('complete'),
                  child: _CompleteContent(
                    state: state,
                    onPlayAgain: notifier.restart,
                    hideNextLevel: widget.hideNextLevel,
                  ),
                ),
              if (state.status == GameStatus.gameOver)
                _OverlayPanel(
                  key: const ValueKey('gameOver'),
                  child: _GameOverContent(onRetry: notifier.restart),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _recordCompletion(WidgetRef ref, GameState state) async {
    final stars = ProgressService.starsFor(
      livesStart: state.level.lives,
      livesRemaining: state.lives,
    );
    if (widget.onComplete != null) {
      await widget.onComplete!(stars);
      return;
    }
    final progress = ref.read(progressServiceProvider);
    await progress.recordCompletion(state.level.id, stars);
  }
}

class _TopBar extends StatelessWidget {
  final GameState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          const Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Level ${state.level.id}', style: t.titleLarge),
              Text('${state.moves} moves',
                  style: t.bodyMedium?.copyWith(fontSize: 11)),
            ],
          ),
          const Spacer(),
          HeartBar(lives: state.lives, max: state.level.lives),
        ],
      ),
    );
  }
}

class _OverlayPanel extends StatelessWidget {
  final Widget child;
  const _OverlayPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (_, t, _) => ColoredBox(
        color: Colors.black.withValues(alpha: 0.55 * t),
        child: Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.82 + 0.18 * t,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompleteContent extends ConsumerWidget {
  final GameState state;
  final VoidCallback onPlayAgain;
  final bool hideNextLevel;
  const _CompleteContent({
    required this.state,
    required this.onPlayAgain,
    this.hideNextLevel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final stars = ProgressService.starsFor(
      livesStart: state.level.lives,
      livesRemaining: state.lives,
    );
    final levelIdsAsync = ref.watch(levelIdsProvider);
    final nextId = state.level.id + 1;
    final hasNext =
        !hideNextLevel && (levelIdsAsync.value?.contains(nextId) ?? false);
    final optimal = Solver.findSolution(state.level.grid)?.length ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Level Complete!', style: t.displayLarge?.copyWith(fontSize: 28)),
        const SizedBox(height: 20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _BounceStar(
                filled: i < stars,
                delay: Duration(milliseconds: 300 + i * 220),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          'Moves: ${state.moves}'
          '${state.moves == optimal && optimal > 0 ? "  (Perfect!)" : "  · Optimal: $optimal"}',
          style: t.bodyMedium,
        ),
        const SizedBox(height: 20),
        if (hasNext)
          FilledButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => LevelLoaderScreen(levelId: nextId),
              ),
            ),
            child: const Text('Next Level'),
          ),
        if (hasNext) const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () => ShareService.shareLevelComplete(
                levelId: state.level.id,
                moves: state.moves,
                stars: stars,
                optimal: optimal,
              ),
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text('SHARE'),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onPlayAgain, child: const Text('Play Again')),
          ],
        ),
      ],
    );
  }
}

class _BounceStar extends StatelessWidget {
  final bool filled;
  final Duration delay;
  const _BounceStar({required this.filled, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600) + delay,
      curve: Curves.easeOutBack,
      builder: (_, t, _) {
        final delayMs = delay.inMilliseconds.toDouble();
        final totalMs = 600.0 + delayMs;
        final adj = ((t * totalMs - delayMs) / 600).clamp(0.0, 1.0);
        return Opacity(
          opacity: adj,
          child: Transform.scale(
            scale: adj,
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 56,
              color: filled
                  ? AppColors.star
                  : AppColors.lightTextMuted.withValues(alpha: 0.5),
              shadows: filled
                  ? [
                      Shadow(
                        color: AppColors.star.withValues(alpha: 0.6),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _GameOverContent extends StatelessWidget {
  final VoidCallback onRetry;
  const _GameOverContent({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.heart_broken,
            color: AppColors.heart.withValues(alpha: 0.8), size: 56),
        const SizedBox(height: 16),
        Text('Out of Lives', style: t.displayLarge?.copyWith(fontSize: 28)),
        const SizedBox(height: 12),
        Text(
          'Take a breath, try a different order.',
          style: t.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Quit'),
        ),
      ],
    );
  }
}
