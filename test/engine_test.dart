import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_puzzle/models/arrow.dart';
import 'package:arrow_puzzle/models/direction.dart';
import 'package:arrow_puzzle/models/grid.dart';
import 'package:arrow_puzzle/engine/solver.dart';

// Test helpers
Arrow up() => const Arrow(Direction.up);
Arrow down() => const Arrow(Direction.down);
Arrow left() => const Arrow(Direction.left);
Arrow right() => const Arrow(Direction.right);

void main() {
  group('Direction', () {
    test('delta values point the right way', () {
      expect(Direction.up.delta, (-1, 0));
      expect(Direction.down.delta, (1, 0));
      expect(Direction.left.delta, (0, -1));
      expect(Direction.right.delta, (0, 1));
    });

    test('fromString parses all four', () {
      expect(Direction.fromString('up'), Direction.up);
      expect(Direction.fromString('down'), Direction.down);
      expect(Direction.fromString('left'), Direction.left);
      expect(Direction.fromString('right'), Direction.right);
    });

    test('fromString throws on unknown', () {
      expect(() => Direction.fromString('diagonal'), throwsArgumentError);
    });
  });

  group('Grid construction', () {
    test('empty grid has correct size and no arrows', () {
      final g = Grid.empty(3, 4);
      expect(g.rows, 3);
      expect(g.cols, 4);
      expect(g.isEmpty, true);
      expect(g.arrowCount, 0);
    });

    test('fromList rejects ragged rows', () {
      expect(
        () => Grid.fromList([
          [up(), null],
          [up()],
        ]),
        throwsArgumentError,
      );
    });

    test('positions returns all non-null cells', () {
      final g = Grid.fromList([
        [up(), null, right()],
        [null, down(), null],
      ]);
      expect(g.arrowCount, 3);
      expect(g.positions().toSet(), {(0, 0), (0, 2), (1, 1)});
    });
  });

  group('canEscape — clear paths', () {
    test('up arrow with clear path above escapes', () {
      final g = Grid.fromList([
        [null],
        [null],
        [up()],
      ]);
      expect(g.canEscape(2, 0), true);
    });

    test('down arrow with clear path below escapes', () {
      final g = Grid.fromList([
        [down()],
        [null],
        [null],
      ]);
      expect(g.canEscape(0, 0), true);
    });

    test('left arrow with clear path escapes', () {
      final g = Grid.fromList([
        [null, null, left()],
      ]);
      expect(g.canEscape(0, 2), true);
    });

    test('right arrow with clear path escapes', () {
      final g = Grid.fromList([
        [right(), null, null],
      ]);
      expect(g.canEscape(0, 0), true);
    });

    test('arrow at edge facing outward escapes immediately', () {
      final g = Grid.fromList([
        [up(), down()],
      ]);
      // top row: up has no cells above (off-grid) → escapes
      expect(g.canEscape(0, 0), true);
      // bottom row of 1-row grid: down has no cells below → escapes
      expect(g.canEscape(0, 1), true);
    });
  });

  group('canEscape — blocked paths', () {
    test('up arrow blocked by any arrow above cannot escape', () {
      final g = Grid.fromList([
        [down()],
        [null],
        [up()],
      ]);
      expect(g.canEscape(2, 0), false);
    });

    test('right arrow blocked by next-cell arrow', () {
      final g = Grid.fromList([
        [right(), left(), null],
      ]);
      expect(g.canEscape(0, 0), false);
    });

    test('blocking arrow direction does not matter', () {
      // Any non-null cell blocks
      for (final blocker in [up(), down(), left(), right()]) {
        final g = Grid.fromList([
          [right(), blocker],
        ]);
        expect(g.canEscape(0, 0), false, reason: 'blocked by $blocker');
      }
    });
  });

  group('canEscape — edge cases', () {
    test('empty cell returns false', () {
      final g = Grid.empty(2, 2);
      expect(g.canEscape(0, 0), false);
    });

    test('1x1 grid with single arrow always escapes', () {
      for (final d in Direction.values) {
        final g = Grid.fromList([[Arrow(d)]]);
        expect(g.canEscape(0, 0), true, reason: 'direction $d');
      }
    });
  });

  group('removeArrow', () {
    test('removes arrow at position', () {
      final g = Grid.fromList([
        [up(), down()],
      ]);
      final g2 = g.removeArrow(0, 0);
      expect(g2.at(0, 0), null);
      expect(g2.at(0, 1), down());
    });

    test('throws when removing empty cell', () {
      final g = Grid.empty(2, 2);
      expect(() => g.removeArrow(0, 0), throwsStateError);
    });

    test('original grid is unchanged (immutability)', () {
      final g = Grid.fromList([
        [up()],
      ]);
      g.removeArrow(0, 0);
      expect(g.at(0, 0), up());
    });
  });

  group('Solver.escapable', () {
    test('returns all currently escapable arrows', () {
      // Top row: up arrows on top row all escape (off-grid above)
      final g = Grid.fromList([
        [up(), up(), up()],
        [down(), null, right()],
      ]);
      final esc = Solver.escapable(g).toSet();
      // (0,0), (0,1), (0,2) all escape upward (no row above)
      // (1,0) down escapes (no row below)
      // (1,2) right escapes (no col to the right)
      expect(esc, {(0, 0), (0, 1), (0, 2), (1, 0), (1, 2)});
    });

    test('returns empty when nothing escapable', () {
      // Two arrows blocking each other
      final g = Grid.fromList([
        [right(), left()],
      ]);
      expect(Solver.escapable(g), isEmpty);
    });
  });

  group('Solver.isSolvable', () {
    test('empty grid is trivially solvable', () {
      expect(Solver.isSolvable(Grid.empty(3, 3)), true);
    });

    test('all arrows pointing outward → solvable', () {
      final g = Grid.fromList([
        [up(), up()],
        [down(), down()],
      ]);
      expect(Solver.isSolvable(g), true);
    });

    test('deadlock pair → unsolvable', () {
      // Two arrows facing each other with no other escape
      final g = Grid.fromList([
        [right(), left()],
      ]);
      expect(Solver.isSolvable(g), false);
    });

    test('order-dependent puzzle is solvable when correct order exists', () {
      // Two up arrows in same column: must tap top first, then bottom
      final g = Grid.fromList([
        [up()],
        [up()],
      ]);
      expect(Solver.isSolvable(g), true);
    });
  });

  group('Solver.findSolution', () {
    test('returns null for unsolvable', () {
      final g = Grid.fromList([
        [right(), left()],
      ]);
      expect(Solver.findSolution(g), null);
    });

    test('returns a valid tap sequence', () {
      final g = Grid.fromList([
        [up()],
        [up()],
      ]);
      final sol = Solver.findSolution(g);
      expect(sol, isNotNull);
      expect(sol!.length, 2);
      // Must tap row 0 first (only one currently escapable)
      expect(sol[0], (0, 0));
      expect(sol[1], (1, 0));
    });

    test('replaying the solution actually clears the grid', () {
      // 2x2 order-dependent puzzle: (1,1)left is blocked by (1,0)down
      // until (1,0) is tapped first.
      final g = Grid.fromList([
        [up(), right()],
        [down(), left()],
      ]);
      final sol = Solver.findSolution(g);
      expect(sol, isNotNull);
      expect(sol!.length, 4);

      var current = g;
      for (final (r, c) in sol) {
        expect(current.canEscape(r, c), true,
            reason: 'step ($r,$c) should be escapable on:\n${current.debugString()}');
        current = current.removeArrow(r, c);
      }
      expect(current.isEmpty, true);
    });
  });
}
