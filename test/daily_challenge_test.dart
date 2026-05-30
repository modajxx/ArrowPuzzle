import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/engine/solver.dart';
import 'package:arrow_puzzle/services/daily_challenge_service.dart';

void main() {
  group('DailyChallengeService.generateFor', () {
    test('is deterministic — same date → same level', () {
      final date = DateTime(2026, 5, 30);
      final a = DailyChallengeService.generateFor(date);
      final b = DailyChallengeService.generateFor(date);
      expect(a.id, b.id);
      expect(a.grid.debugString(), b.grid.debugString());
    });

    test('different days produce different puzzles', () {
      final a = DailyChallengeService.generateFor(DateTime(2026, 5, 30));
      final b = DailyChallengeService.generateFor(DateTime(2026, 5, 31));
      expect(a.grid.debugString() == b.grid.debugString(), false);
    });

    test('every day in a 60-day window is solvable', () {
      final start = DateTime(2026, 1, 1);
      for (var i = 0; i < 60; i++) {
        final d = start.add(Duration(days: i));
        final level = DailyChallengeService.generateFor(d);
        expect(Solver.isSolvable(level.grid), true,
            reason: 'failed on $d:\n${level.grid.debugString()}');
      }
    });

    test('id encodes the date as YYYYMMDD', () {
      final level = DailyChallengeService.generateFor(DateTime(2026, 5, 30));
      expect(level.id, 20260530);
    });
  });

  group('DailyChallengeService.difficultyFor', () {
    test('weekday → difficulty mapping', () {
      DateTime atWeekday(int wd) {
        // 2026-05-04 is a Monday (weekday 1)
        return DateTime(2026, 5, 3 + wd);
      }

      expect(DailyChallengeService.difficultyFor(atWeekday(1)),
          DailyDifficulty.easy); // Mon
      expect(DailyChallengeService.difficultyFor(atWeekday(2)),
          DailyDifficulty.easy); // Tue
      expect(DailyChallengeService.difficultyFor(atWeekday(3)),
          DailyDifficulty.normal); // Wed
      expect(DailyChallengeService.difficultyFor(atWeekday(5)),
          DailyDifficulty.normal); // Fri
      expect(DailyChallengeService.difficultyFor(atWeekday(6)),
          DailyDifficulty.hard); // Sat
      expect(DailyChallengeService.difficultyFor(atWeekday(7)),
          DailyDifficulty.hard); // Sun
    });
  });

  group('DailyChallengeService progress', () {
    late DailyChallengeService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = DailyChallengeService(await SharedPreferences.getInstance());
    });

    test('getStarsFor returns 0 by default', () {
      expect(service.getStarsFor(DateTime(2026, 5, 30)), 0);
      expect(service.isCompleted(DateTime(2026, 5, 30)), false);
    });

    test('recordCompletion only beats personal best', () async {
      final d = DateTime(2026, 5, 30);
      await service.recordCompletion(d, 2);
      expect(service.getStarsFor(d), 2);
      await service.recordCompletion(d, 1);
      expect(service.getStarsFor(d), 2, reason: 'lower should not overwrite');
      await service.recordCompletion(d, 3);
      expect(service.getStarsFor(d), 3);
    });

    test('monthCompleted requires every day', () async {
      // Only complete some of May 2026 (31 days)
      for (var d = 1; d <= 30; d++) {
        await service.recordCompletion(DateTime(2026, 5, d), 1);
      }
      expect(service.monthCompleted(2026, 5), false);
      await service.recordCompletion(DateTime(2026, 5, 31), 1);
      expect(service.monthCompleted(2026, 5), true);
    });

    test('completedMonths surfaces unique year/month pairs', () async {
      await service.recordCompletion(DateTime(2026, 1, 5), 1);
      await service.recordCompletion(DateTime(2026, 1, 10), 1);
      await service.recordCompletion(DateTime(2026, 2, 3), 1);
      final months = service.completedMonths();
      expect(months, {
        (year: 2026, month: 1),
        (year: 2026, month: 2),
      });
    });
  });
}
