import '../models/grid.dart';

class Solver {
  /// All arrow positions that can currently escape the grid.
  static List<(int, int)> escapable(Grid grid) {
    final out = <(int, int)>[];
    for (final (r, c) in grid.positions()) {
      if (grid.canEscape(r, c)) out.add((r, c));
    }
    return out;
  }

  /// True if the grid can be fully cleared by some sequence of taps.
  /// Used at level-design time to validate hand-made puzzles.
  ///
  /// Uses DFS with seen-state memoization to prune duplicate sub-states.
  static bool isSolvable(Grid grid) {
    final seen = <String>{};
    return _solve(grid, seen);
  }

  /// Returns a solution sequence (list of (r,c) taps) if solvable, else null.
  static List<(int, int)>? findSolution(Grid grid) {
    final seen = <String>{};
    final path = <(int, int)>[];
    return _findPath(grid, seen, path) ? List.unmodifiable(path) : null;
  }

  static bool _solve(Grid grid, Set<String> seen) {
    if (grid.isEmpty) return true;
    final key = grid.debugString();
    if (!seen.add(key)) return false;
    for (final (r, c) in escapable(grid)) {
      if (_solve(grid.removeArrow(r, c), seen)) return true;
    }
    return false;
  }

  static bool _findPath(Grid grid, Set<String> seen, List<(int, int)> path) {
    if (grid.isEmpty) return true;
    final key = grid.debugString();
    if (!seen.add(key)) return false;
    for (final (r, c) in escapable(grid)) {
      path.add((r, c));
      if (_findPath(grid.removeArrow(r, c), seen, path)) return true;
      path.removeLast();
    }
    return false;
  }
}
