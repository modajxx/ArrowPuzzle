import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/solver.dart';
import '../models/game_state.dart';
import '../models/level.dart';
import 'feedback_service.dart';

/// Override this in a nested [ProviderScope] when entering a level.
final currentLevelProvider = Provider<Level>((ref) {
  throw UnimplementedError(
    'currentLevelProvider must be overridden before use',
  );
});

class GameNotifier extends Notifier<GameState> {
  @override
  GameState build() {
    final level = ref.watch(currentLevelProvider);
    return GameState.fromLevel(level);
  }

  static const escapeAnimMs = 260;
  static const blockedAnimMs = 420;
  static const hintDisplayMs = 2500;

  Future<void> tap(int r, int c) async {
    if (state.status != GameStatus.playing) return;
    if (state.grid.at(r, c) == null) return;
    if (state.escaping.contains((r, c))) return;

    final feedback = ref.read(feedbackServiceProvider);

    if (state.grid.canEscape(r, c)) {
      feedback.tapEscape();
      final clearingHinted = state.hintedArrow == (r, c);
      state = state.copyWith(
        moves: state.moves + 1,
        escaping: {...state.escaping, (r, c)},
        clearHintedArrow: clearingHinted,
      );
      await Future.delayed(const Duration(milliseconds: escapeAnimMs));
      final newGrid = state.grid.removeArrow(r, c);
      final newEscaping = {...state.escaping}..remove((r, c));
      final complete = newGrid.isEmpty;
      state = state.copyWith(
        grid: newGrid,
        escaping: newEscaping,
        status: complete ? GameStatus.complete : GameStatus.playing,
      );
      if (complete) feedback.levelComplete();
    } else {
      feedback.tapBlocked();
      final remainingLives = state.lives - 1;
      state = state.copyWith(
        moves: state.moves + 1,
        lives: remainingLives,
        recentlyBlocked: (r, c),
        blockedNonce: state.blockedNonce + 1,
        status: remainingLives <= 0 ? GameStatus.gameOver : GameStatus.playing,
      );
      await Future.delayed(const Duration(milliseconds: blockedAnimMs));
      if (state.recentlyBlocked == (r, c)) {
        state = state.copyWith(clearRecentlyBlocked: true);
      }
    }
  }

  /// Picks an escapable arrow and highlights it briefly. No-op if no hints
  /// remain, nothing is escapable, or a hint is already showing.
  /// Returns synchronously; the auto-clear timer runs in the background.
  void useHint() {
    if (state.status != GameStatus.playing) return;
    if (state.hints <= 0) return;
    if (state.hintedArrow != null) return;

    final escapable = Solver.escapable(state.grid);
    if (escapable.isEmpty) return;

    final pick = escapable.first;
    ref.read(feedbackServiceProvider).hint();
    state = state.copyWith(
      hintedArrow: pick,
      hintNonce: state.hintNonce + 1,
      hints: state.hints - 1,
    );

    Future.delayed(const Duration(milliseconds: hintDisplayMs)).then((_) {
      if (state.hintedArrow == pick) {
        state = state.copyWith(clearHintedArrow: true);
      }
    });
  }

  void restart() {
    final level = ref.read(currentLevelProvider);
    state = GameState.fromLevel(level);
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameState>(
  GameNotifier.new,
  dependencies: [currentLevelProvider],
);
