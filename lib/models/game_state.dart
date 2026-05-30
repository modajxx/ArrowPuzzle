import 'grid.dart';
import 'level.dart';

enum GameStatus { playing, complete, gameOver }

class GameState {
  final Level level;
  final Grid grid;
  final int lives;
  final int hints;
  final int moves;
  final Set<(int, int)> escaping;
  final (int, int)? recentlyBlocked;
  final int blockedNonce;
  final (int, int)? hintedArrow;
  final int hintNonce;
  final GameStatus status;

  const GameState({
    required this.level,
    required this.grid,
    required this.lives,
    required this.hints,
    this.moves = 0,
    this.escaping = const {},
    this.recentlyBlocked,
    this.blockedNonce = 0,
    this.hintedArrow,
    this.hintNonce = 0,
    this.status = GameStatus.playing,
  });

  factory GameState.fromLevel(Level level) => GameState(
        level: level,
        grid: level.grid,
        lives: level.lives,
        hints: level.hints,
      );

  GameState copyWith({
    Grid? grid,
    int? lives,
    int? hints,
    int? moves,
    Set<(int, int)>? escaping,
    (int, int)? recentlyBlocked,
    bool clearRecentlyBlocked = false,
    int? blockedNonce,
    (int, int)? hintedArrow,
    bool clearHintedArrow = false,
    int? hintNonce,
    GameStatus? status,
  }) {
    return GameState(
      level: level,
      grid: grid ?? this.grid,
      lives: lives ?? this.lives,
      hints: hints ?? this.hints,
      moves: moves ?? this.moves,
      escaping: escaping ?? this.escaping,
      recentlyBlocked:
          clearRecentlyBlocked ? null : (recentlyBlocked ?? this.recentlyBlocked),
      blockedNonce: blockedNonce ?? this.blockedNonce,
      hintedArrow:
          clearHintedArrow ? null : (hintedArrow ?? this.hintedArrow),
      hintNonce: hintNonce ?? this.hintNonce,
      status: status ?? this.status,
    );
  }
}
