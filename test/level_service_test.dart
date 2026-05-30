import 'package:flutter_test/flutter_test.dart';

import 'package:arrow_puzzle/engine/solver.dart';
import 'package:arrow_puzzle/models/level.dart';
import 'package:arrow_puzzle/services/level_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Level.fromJson', () {
    test('parses a minimal valid level', () {
      final level = Level.fromJson({
        'id': 1,
        'difficulty': 'easy',
        'lives': 3,
        'hints': 2,
        'grid': [
          ['up', null],
          [null, 'down'],
        ],
      });
      expect(level.id, 1);
      expect(level.difficulty, 'easy');
      expect(level.lives, 3);
      expect(level.hints, 2);
      expect(level.grid.rows, 2);
      expect(level.grid.cols, 2);
      expect(level.grid.arrowCount, 2);
    });

    test('defaults difficulty/lives/hints when missing', () {
      final level = Level.fromJson({
        'id': 99,
        'grid': [
          ['up'],
        ],
      });
      expect(level.difficulty, 'normal');
      expect(level.lives, 3);
      expect(level.hints, 2);
    });
  });

  group('bundled levels', () {
    test('index lists at least one level', () async {
      final ids = await LevelService.availableLevelIds();
      expect(ids, isNotEmpty);
    });

    test('every listed level loads and is solvable', () async {
      final ids = await LevelService.availableLevelIds();
      for (final id in ids) {
        final level = await LevelService.loadById(id);
        expect(level.id, id, reason: 'id field must match filename');
        expect(level.lives, greaterThan(0));
        expect(Solver.isSolvable(level.grid), true,
            reason: 'level $id should be solvable:\n${level.grid.debugString()}');
      }
    });
  });
}
