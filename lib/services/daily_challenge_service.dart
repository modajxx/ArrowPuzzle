import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../engine/solver.dart';
import '../models/arrow.dart';
import '../models/direction.dart';
import '../models/grid.dart';
import '../models/level.dart';
import 'prefs_provider.dart';

enum DailyDifficulty { easy, normal, hard }

typedef _GridConfig = ({int rows, int cols, double density});

class DailyChallengeService {
  final SharedPreferences _prefs;
  DailyChallengeService(this._prefs);

  // ---- Date keys ----

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';

  static String _starsKey(DateTime d) => 'daily_${_ymd(d)}_stars';

  // ---- Progress ----

  int getStarsFor(DateTime date) => _prefs.getInt(_starsKey(date)) ?? 0;
  bool isCompleted(DateTime date) => getStarsFor(date) > 0;

  Future<void> recordCompletion(DateTime date, int stars) async {
    assert(stars >= 1 && stars <= 3);
    if (stars > getStarsFor(date)) {
      await _prefs.setInt(_starsKey(date), stars);
    }
  }

  /// All distinct months that have at least one completed day.
  /// Useful for "trophies" view.
  Set<({int year, int month})> completedMonths() {
    final months = <({int year, int month})>{};
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith('daily_')) continue;
      final ymd = key.substring(6, 14);
      months.add((
        year: int.parse(ymd.substring(0, 4)),
        month: int.parse(ymd.substring(4, 6)),
      ));
    }
    return months;
  }

  /// True when every day of a calendar month has a recorded completion.
  bool monthCompleted(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (var d = 1; d <= daysInMonth; d++) {
      if (!isCompleted(DateTime(year, month, d))) return false;
    }
    return true;
  }

  // ---- Level generation (deterministic per date) ----

  /// Same date → same puzzle on every device.
  /// Same date is replayable but only the best score is recorded.
  static Level generateFor(DateTime date) {
    final difficulty = difficultyFor(date);
    final config = _configFor(difficulty);
    final baseSeed = _seedFor(date);

    // Walk the seed forward until we find a solvable grid. We multiply baseSeed
    // by a large factor so adjacent days never share final seeds even if one
    // day's first attempt needs more retries than another's.
    var attempt = 0;
    while (true) {
      final seed = baseSeed * 100000 + attempt;
      final grid = _randomGrid(seed, config);
      if (Solver.isSolvable(grid)) {
        return Level(
          id: baseSeed, // yyyymmdd — won't collide with regular IDs (1-15)
          difficulty: difficulty.name,
          lives: 3,
          hints: difficulty == DailyDifficulty.hard ? 3 : 2,
          grid: grid,
        );
      }
      attempt++;
    }
  }

  static DailyDifficulty difficultyFor(DateTime d) {
    final w = d.weekday; // 1 = Mon, 7 = Sun
    if (w <= 2) return DailyDifficulty.easy;
    if (w <= 5) return DailyDifficulty.normal;
    return DailyDifficulty.hard;
  }

  static _GridConfig _configFor(DailyDifficulty d) => switch (d) {
        DailyDifficulty.easy => (rows: 3, cols: 3, density: 0.7),
        DailyDifficulty.normal => (rows: 4, cols: 4, density: 0.55),
        DailyDifficulty.hard => (rows: 5, cols: 5, density: 0.5),
      };

  static int _seedFor(DateTime d) =>
      d.year * 10000 + d.month * 100 + d.day;

  static Grid _randomGrid(int seed, _GridConfig config) {
    final rng = Random(seed);
    final cells = List.generate(config.rows, (_) {
      return List.generate(config.cols, (_) {
        if (rng.nextDouble() > config.density) return null;
        return Arrow(Direction.values[rng.nextInt(4)]);
      });
    });
    return Grid.fromList(cells);
  }
}

final dailyChallengeServiceProvider = Provider<DailyChallengeService>(
  (ref) => DailyChallengeService(ref.watch(sharedPreferencesProvider)),
);
