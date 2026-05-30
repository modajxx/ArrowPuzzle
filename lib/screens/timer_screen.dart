import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/solver.dart';
import '../models/arrow.dart';
import '../models/direction.dart';
import '../models/grid.dart';
import '../models/level.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'game_screen.dart';

const _timerDurationSec = 60;
const _scorePerLevel = 100;

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int _secondsLeft = _timerDurationSec;
  int _score = 0;
  int _levelsCleared = 0;
  bool _running = false;
  bool _finished = false;
  Timer? _ticker;
  late Level _currentLevel;
  final Random _rng = Random(DateTime.now().millisecondsSinceEpoch);

  @override
  void initState() {
    super.initState();
    _currentLevel = _nextLevel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _finished = false;
      _secondsLeft = _timerDurationSec;
      _score = 0;
      _levelsCleared = 0;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) _finish();
    });
  }

  void _finish() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _finished = true;
    });
  }

  void _onLevelDone(int stars) {
    setState(() {
      _score += _scorePerLevel + stars * 25 + _secondsLeft * 2;
      _levelsCleared++;
      _currentLevel = _nextLevel();
    });
  }

  Level _nextLevel() {
    // Smaller, faster puzzles for timer mode.
    final size = 3 + _rng.nextInt(2); // 3x3 or 4x4
    return _generate(size, size, 0.55);
  }

  Level _generate(int rows, int cols, double density) {
    var attempt = 0;
    while (true) {
      final rng = Random(_rng.nextInt(1 << 30) + attempt);
      final cells = List.generate(rows, (_) {
        return List.generate(cols, (_) {
          if (rng.nextDouble() > density) return null;
          return Arrow(Direction.values[rng.nextInt(4)]);
        });
      });
      final grid = Grid.fromList(cells);
      if (Solver.isSolvable(grid) && grid.arrowCount >= 3) {
        return Level(
          id: -1, // not persisted
          difficulty: 'timer',
          lives: 5,
          hints: 0,
          grid: grid,
        );
      }
      attempt++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TIMER ATTACK')),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: !_running && !_finished
                ? _StartCard(onStart: _start)
                : _finished
                    ? _ResultCard(
                        score: _score,
                        levels: _levelsCleared,
                        onRetry: _start,
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 16),
                          _StatusBar(
                            seconds: _secondsLeft,
                            score: _score,
                            levels: _levelsCleared,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _TimerGame(
                              key: ValueKey(_levelsCleared),
                              level: _currentLevel,
                              onComplete: _onLevelDone,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _finish,
                            icon: const Icon(Icons.stop, size: 18),
                            label: const Text('End'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  final VoidCallback onStart;
  const _StartCard({required this.onStart});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 80, color: AppColors.neonCyan),
          const SizedBox(height: 24),
          Text('60 SECONDS', style: t.displayLarge?.copyWith(fontSize: 28)),
          const SizedBox(height: 12),
          Text(
            'Clear as many puzzles as you can.\n+100 per level, +25 per star,\nbonus for remaining time.',
            style: t.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton(onPressed: onStart, child: const Text('START')),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int score;
  final int levels;
  final VoidCallback onRetry;
  const _ResultCard(
      {required this.score, required this.levels, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events,
              size: 80, color: AppColors.neonCyan),
          const SizedBox(height: 24),
          Text('TIME UP', style: t.displayLarge?.copyWith(fontSize: 28)),
          const SizedBox(height: 24),
          Text('$score',
              style: t.displayLarge?.copyWith(
                fontSize: 56,
                color: AppColors.neonCyan,
                shadows: [
                  Shadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.6),
                      blurRadius: 16),
                ],
              )),
          const SizedBox(height: 4),
          Text('SCORE',
              style: t.bodyMedium?.copyWith(letterSpacing: 4)),
          const SizedBox(height: 16),
          Text('$levels levels cleared', style: t.bodyMedium),
          const SizedBox(height: 32),
          FilledButton(onPressed: onRetry, child: const Text('PLAY AGAIN')),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => ShareService.shareTimerScore(
                  score: score,
                  levelsCleared: levels,
                ),
                icon: const Icon(Icons.ios_share, size: 18),
                label: const Text('SHARE'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final int seconds;
  final int score;
  final int levels;
  const _StatusBar({
    required this.seconds,
    required this.score,
    required this.levels,
  });
  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 10;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatusChip(
            label: 'TIME',
            value: '${seconds}s',
            color: urgent ? AppColors.heart : AppColors.neonCyan,
          ),
          _StatusChip(
            label: 'SCORE',
            value: '$score',
            color: AppColors.neonPurple,
          ),
          _StatusChip(
            label: 'CLEARED',
            value: '$levels',
            color: AppColors.neonGreen,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatusChip(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Text(label,
              style: t.bodyMedium?.copyWith(
                fontSize: 10,
                color: color,
                letterSpacing: 2,
              )),
          const SizedBox(height: 2),
          Text(value,
              style: t.titleLarge?.copyWith(fontSize: 18, color: color)),
        ],
      ),
    );
  }
}

class _TimerGame extends StatelessWidget {
  final Level level;
  final void Function(int stars) onComplete;
  const _TimerGame({super.key, required this.level, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return _EmbeddedGame(level: level, onComplete: onComplete);
  }
}

/// Minimal embedded game without app bar / overlays — for use inside Timer Attack.
class _EmbeddedGame extends ConsumerWidget {
  final Level level;
  final void Function(int stars) onComplete;
  const _EmbeddedGame(
      {required this.level, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GameScreen(
      level: level,
      hideNextLevel: true,
      onComplete: (stars) async {
        onComplete(stars);
      },
    );
  }
}
