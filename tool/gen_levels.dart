// Generates additional hand-curated levels into assets/levels/.
// Uses Random+Solver to produce only solvable, interesting puzzles.
// Run: dart run tool/gen_levels.dart
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
  final double density;
  final int seed;
  const _Spec(this.id, this.difficulty, this.rows, this.cols, this.density,
      this.seed);
}

void main() {
  // Curated difficulty curve for levels 16-30.
  final specs = <_Spec>[
    // 5x5 challenges
    _Spec(16, 'hard', 5, 5, 0.55, 1601),
    _Spec(17, 'hard', 5, 5, 0.60, 1702),
    _Spec(18, 'hard', 5, 5, 0.65, 1803),
    // 5x6 / 6x5
    _Spec(19, 'hard', 6, 5, 0.55, 1904),
    _Spec(20, 'hard', 5, 6, 0.55, 2005),
    // 6x6
    _Spec(21, 'expert', 6, 6, 0.50, 2106),
    _Spec(22, 'expert', 6, 6, 0.55, 2207),
    _Spec(23, 'expert', 6, 6, 0.60, 2308),
    // 7x6 / 6x7
    _Spec(24, 'expert', 7, 6, 0.50, 2409),
    _Spec(25, 'expert', 6, 7, 0.50, 2510),
    // 7x7 finales
    _Spec(26, 'expert', 7, 7, 0.45, 2611),
    _Spec(27, 'expert', 7, 7, 0.50, 2712),
    _Spec(28, 'expert', 7, 7, 0.55, 2813),
    // 8x7 / 7x8
    _Spec(29, 'expert', 8, 7, 0.45, 2914),
    _Spec(30, 'expert', 7, 8, 0.45, 3015),
  ];

  for (final spec in specs) {
    final (grid, attempts) = _generate(spec);
    final json = {
      'id': spec.id,
      'difficulty': spec.difficulty,
      'lives': 3,
      'hints': spec.difficulty == 'expert' ? 3 : 2,
      'grid': _gridToJson(grid),
    };
    final path =
        'assets/levels/level_${spec.id.toString().padLeft(3, '0')}.json';
    File(path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
    stdout.writeln(
        '  level ${spec.id}  ${spec.rows}x${spec.cols} ${spec.difficulty}  '
        '${grid.arrowCount} arrows  ($attempts attempts)');
  }

  // Rebuild index.json with all 30 levels.
  final ids = List.generate(30, (i) => i + 1);
  File('assets/levels/index.json').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert({'levels': ids}));
  stdout.writeln('\nUpdated index.json with ${ids.length} levels.');
}

(Grid, int) _generate(_Spec spec) {
  var attempt = 0;
  while (true) {
    final seed = spec.seed * 100000 + attempt;
    final rng = Random(seed);
    final cells = List.generate(spec.rows, (_) {
      return List.generate(spec.cols, (_) {
        if (rng.nextDouble() > spec.density) return null;
        return Arrow(Direction.values[rng.nextInt(4)]);
      });
    });
    final grid = Grid.fromList(cells);
    // Skip trivial puzzles (everything escapes immediately).
    if (grid.arrowCount > 4 &&
        Solver.escapable(grid).length == grid.arrowCount) {
      attempt++;
      continue;
    }
    if (Solver.isSolvable(grid)) return (grid, attempt + 1);
    attempt++;
  }
}

List<List<String?>> _gridToJson(Grid grid) {
  return List.generate(grid.rows, (r) {
    return List.generate(grid.cols, (c) {
      return grid.at(r, c)?.direction.name;
    });
  });
}
