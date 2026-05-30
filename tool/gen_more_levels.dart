// Generates levels 31-60 using a CONSTRUCTIVE algorithm:
// build the puzzle in reverse-solve-order so every result is guaranteed
// solvable, with no expensive solver loop.
//
// Run: dart run tool/gen_more_levels.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:arrow_puzzle/engine/solver.dart';
import 'package:arrow_puzzle/models/arrow.dart';
import 'package:arrow_puzzle/models/direction.dart';
import 'package:arrow_puzzle/models/grid.dart';

class _Spec {
  final int id;
  final String difficulty;
  final int rows;
  final int cols;
  final int targetArrows;
  final int seed;
  const _Spec(this.id, this.difficulty, this.rows, this.cols,
      this.targetArrows, this.seed);
}

void main() {
  final specs = <_Spec>[
    // INSANE (7x7 to 8x8, moderate fill)
    _Spec(31, 'insane', 6, 7, 22, 3116),
    _Spec(32, 'insane', 7, 6, 22, 3217),
    _Spec(33, 'insane', 7, 7, 26, 3318),
    _Spec(34, 'insane', 7, 7, 28, 3419),
    _Spec(35, 'insane', 7, 7, 30, 3520),
    _Spec(36, 'insane', 7, 7, 32, 3621),
    _Spec(37, 'insane', 8, 7, 30, 3722),
    _Spec(38, 'insane', 7, 8, 32, 3823),
    _Spec(39, 'insane', 8, 7, 34, 3924),
    _Spec(40, 'insane', 7, 8, 35, 4025),
    // BOSS (8x8 high fill)
    _Spec(41, 'boss', 8, 8, 32, 4126),
    _Spec(42, 'boss', 8, 8, 34, 4227),
    _Spec(43, 'boss', 8, 8, 36, 4328),
    _Spec(44, 'boss', 8, 8, 38, 4429),
    _Spec(45, 'boss', 8, 8, 40, 4530),
    _Spec(46, 'boss', 8, 9, 38, 4631),
    _Spec(47, 'boss', 9, 8, 40, 4732),
    _Spec(48, 'boss', 8, 9, 42, 4833),
    _Spec(49, 'boss', 9, 8, 44, 4934),
    _Spec(50, 'boss', 9, 9, 42, 5035),
    // FINALE (9x9 dense)
    _Spec(51, 'boss', 9, 9, 46, 5136),
    _Spec(52, 'boss', 9, 9, 48, 5237),
    _Spec(53, 'boss', 9, 9, 50, 5338),
    _Spec(54, 'boss', 9, 9, 52, 5439),
    _Spec(55, 'boss', 9, 9, 54, 5540),
    _Spec(56, 'boss', 9, 9, 56, 5641),
    _Spec(57, 'boss', 9, 9, 58, 5742),
    _Spec(58, 'boss', 9, 9, 60, 5843),
    _Spec(59, 'boss', 9, 9, 62, 5944),
    _Spec(60, 'boss', 9, 9, 64, 6045),
  ];

  for (final spec in specs) {
    final grid = _construct(spec);
    // Sanity-check (cheap — we trust the construction).
    assert(Solver.isSolvable(grid),
        'Construction bug: level ${spec.id} not solvable');
    final json = {
      'id': spec.id,
      'difficulty': spec.difficulty,
      'lives': spec.difficulty == 'boss' ? 5 : 4,
      'hints': spec.difficulty == 'boss' ? 4 : 3,
      'grid': _gridToJson(grid),
    };
    final path =
        'assets/levels/level_${spec.id.toString().padLeft(3, '0')}.json';
    File(path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
    stdout.writeln(
        '  level ${spec.id}  ${spec.rows}x${spec.cols} ${spec.difficulty}  '
        '${grid.arrowCount} arrows');
  }

  final ids = List.generate(60, (i) => i + 1);
  File('assets/levels/index.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({'levels': ids}));
  stdout.writeln('\nUpdated index.json with ${ids.length} levels.');
}

/// Build a puzzle in reverse-solve-order. At each step we add an arrow whose
/// path to the edge is currently CLEAR — this arrow can escape last in the
/// solve sequence, guaranteeing total solvability.
Grid _construct(_Spec spec) {
  final rng = Random(spec.seed);
  var cells = List.generate(spec.rows, (_) =>
      List<Arrow?>.filled(spec.cols, null));

  bool canEscape(int r, int c, Direction dir) {
    final (dr, dc) = dir.delta;
    var nr = r + dr, nc = c + dc;
    while (nr >= 0 && nr < spec.rows && nc >= 0 && nc < spec.cols) {
      if (cells[nr][nc] != null) return false;
      nr += dr;
      nc += dc;
    }
    return true;
  }

  for (var added = 0; added < spec.targetArrows; added++) {
    final candidates = <(int, int, Direction)>[];
    for (var r = 0; r < spec.rows; r++) {
      for (var c = 0; c < spec.cols; c++) {
        if (cells[r][c] != null) continue;
        for (final dir in Direction.values) {
          if (canEscape(r, c, dir)) candidates.add((r, c, dir));
        }
      }
    }
    if (candidates.isEmpty) break; // grid is too full to add anything legal
    final pick = candidates[rng.nextInt(candidates.length)];
    cells[pick.$1][pick.$2] = Arrow(pick.$3);
  }
  return Grid.fromList(cells);
}

List<List<String?>> _gridToJson(Grid grid) {
  return List.generate(grid.rows, (r) {
    return List.generate(grid.cols, (c) {
      return grid.at(r, c)?.direction.name;
    });
  });
}
