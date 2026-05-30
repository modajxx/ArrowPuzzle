import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/services/progress_service.dart';

void main() {
  late ProgressService progress;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    progress = ProgressService(await SharedPreferences.getInstance());
  });

  group('starsFor', () {
    test('3 stars when no lives lost', () {
      expect(ProgressService.starsFor(livesStart: 3, livesRemaining: 3), 3);
    });
    test('2 stars when 1 life lost', () {
      expect(ProgressService.starsFor(livesStart: 3, livesRemaining: 2), 2);
    });
    test('1 star when 2+ lives lost', () {
      expect(ProgressService.starsFor(livesStart: 3, livesRemaining: 1), 1);
      expect(ProgressService.starsFor(livesStart: 3, livesRemaining: 0), 1);
    });
  });

  group('progress persistence', () {
    test('getStars returns 0 by default', () {
      expect(progress.getStars(1), 0);
      expect(progress.isCompleted(1), false);
    });

    test('recordCompletion stores stars', () async {
      await progress.recordCompletion(1, 2);
      expect(progress.getStars(1), 2);
      expect(progress.isCompleted(1), true);
    });

    test('recordCompletion only beats personal best', () async {
      await progress.recordCompletion(1, 2);
      await progress.recordCompletion(1, 1);
      expect(progress.getStars(1), 2, reason: 'lower score should not overwrite');
      await progress.recordCompletion(1, 3);
      expect(progress.getStars(1), 3, reason: 'higher score should overwrite');
    });
  });

  group('unlocking', () {
    test('level 1 is always unlocked', () {
      expect(progress.isUnlocked(1), true);
    });

    test('level N+1 unlocks only after N is completed', () async {
      expect(progress.isUnlocked(2), false);
      await progress.recordCompletion(1, 1);
      expect(progress.isUnlocked(2), true);
      expect(progress.isUnlocked(3), false);
    });
  });

  test('resetAll clears all progress', () async {
    await progress.recordCompletion(1, 3);
    await progress.recordCompletion(2, 2);
    await progress.resetAll();
    expect(progress.getStars(1), 0);
    expect(progress.getStars(2), 0);
  });
}
