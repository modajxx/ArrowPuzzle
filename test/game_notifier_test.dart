import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_puzzle/models/arrow.dart';
import 'package:arrow_puzzle/models/direction.dart';
import 'package:arrow_puzzle/models/game_state.dart';
import 'package:arrow_puzzle/models/grid.dart';
import 'package:arrow_puzzle/models/level.dart';
import 'package:arrow_puzzle/services/feedback_service.dart';
import 'package:arrow_puzzle/services/game_notifier.dart';
import 'package:arrow_puzzle/services/prefs_provider.dart';

Level _twoByTwoLevel() => Level(
      id: 1,
      difficulty: 'easy',
      lives: 3,
      hints: 2,
      grid: Grid.fromList([
        [const Arrow(Direction.up), const Arrow(Direction.right)],
        [const Arrow(Direction.down), const Arrow(Direction.left)],
      ]),
    );

late SharedPreferences _mockPrefs;

ProviderContainer _containerFor(Level level) {
  return ProviderContainer(
    overrides: [
      currentLevelProvider.overrideWithValue(level),
      sharedPreferencesProvider.overrideWithValue(_mockPrefs),
      feedbackServiceProvider
          .overrideWith((ref) => FeedbackService(ref, disabled: true)),
    ],
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    _mockPrefs = await SharedPreferences.getInstance();
  });
  group('GameNotifier', () {
    test('initial state mirrors the level', () {
      final c = _containerFor(_twoByTwoLevel());
      addTearDown(c.dispose);
      final state = c.read(gameProvider);
      expect(state.lives, 3);
      expect(state.hints, 2);
      expect(state.grid.arrowCount, 4);
      expect(state.status, GameStatus.playing);
    });

    test('tapping an escapable arrow eventually removes it', () async {
      final c = _containerFor(_twoByTwoLevel());
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      // (0,0) up is on top row → escapable
      await notifier.tap(0, 0);

      final state = c.read(gameProvider);
      expect(state.grid.at(0, 0), null);
      expect(state.grid.arrowCount, 3);
      expect(state.lives, 3, reason: 'no life lost for valid tap');
    });

    test('tapping a blocked arrow loses a life and triggers blocked feedback',
        () async {
      // Grid where (0,0) right is blocked by (0,1) left
      final blocked = Level(
        id: 99,
        difficulty: 'test',
        lives: 3,
        hints: 0,
        grid: Grid.fromList([
          [const Arrow(Direction.right), const Arrow(Direction.left)],
        ]),
      );
      final c = _containerFor(blocked);
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      await notifier.tap(0, 0);
      final state = c.read(gameProvider);

      expect(state.lives, 2);
      expect(state.grid.arrowCount, 2, reason: 'arrow still there');
      expect(state.status, GameStatus.playing);
    });

    test('losing all lives transitions to gameOver', () async {
      final deadlock = Level(
        id: 99,
        difficulty: 'test',
        lives: 1,
        hints: 0,
        grid: Grid.fromList([
          [const Arrow(Direction.right), const Arrow(Direction.left)],
        ]),
      );
      final c = _containerFor(deadlock);
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      await notifier.tap(0, 0);
      expect(c.read(gameProvider).status, GameStatus.gameOver);
    });

    test('clearing the grid transitions to complete', () async {
      final trivial = Level(
        id: 99,
        difficulty: 'test',
        lives: 3,
        hints: 0,
        grid: Grid.fromList([
          [const Arrow(Direction.up)],
        ]),
      );
      final c = _containerFor(trivial);
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      await notifier.tap(0, 0);
      expect(c.read(gameProvider).status, GameStatus.complete);
      expect(c.read(gameProvider).grid.isEmpty, true);
    });

    test('restart resets the grid and lives', () async {
      final blocked = Level(
        id: 99,
        difficulty: 'test',
        lives: 2,
        hints: 0,
        grid: Grid.fromList([
          [const Arrow(Direction.right), const Arrow(Direction.left)],
        ]),
      );
      final c = _containerFor(blocked);
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      await notifier.tap(0, 0);
      expect(c.read(gameProvider).lives, 1);

      notifier.restart();
      expect(c.read(gameProvider).lives, 2);
      expect(c.read(gameProvider).grid.arrowCount, 2);
      expect(c.read(gameProvider).status, GameStatus.playing);
    });

    test('useHint highlights an escapable arrow and consumes a hint', () {
      final c = _containerFor(_twoByTwoLevel());
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      notifier.useHint();
      final state = c.read(gameProvider);

      expect(state.hints, 1);
      expect(state.hintedArrow, isNotNull);
      // The hinted cell must actually be escapable on the current grid.
      final (r, hc) = state.hintedArrow!;
      expect(state.grid.canEscape(r, hc), true);
    });

    test('useHint is a no-op when no hints remain', () {
      final noHints = Level(
        id: 99,
        difficulty: 'test',
        lives: 3,
        hints: 0,
        grid: Grid.fromList([
          [const Arrow(Direction.up)],
        ]),
      );
      final c = _containerFor(noHints);
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      notifier.useHint();
      expect(c.read(gameProvider).hintedArrow, null);
    });

    test('useHint is a no-op when nothing is escapable', () {
      final deadlock = Level(
        id: 99,
        difficulty: 'test',
        lives: 3,
        hints: 2,
        grid: Grid.fromList([
          [const Arrow(Direction.right), const Arrow(Direction.left)],
        ]),
      );
      final c = _containerFor(deadlock);
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      notifier.useHint();
      final state = c.read(gameProvider);
      expect(state.hintedArrow, null);
      expect(state.hints, 2, reason: 'hint should not be consumed if useless');
    });

    test('tapping the hinted arrow clears the hint state', () async {
      final c = _containerFor(_twoByTwoLevel());
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      notifier.useHint();
      final hinted = c.read(gameProvider).hintedArrow!;
      await notifier.tap(hinted.$1, hinted.$2);

      expect(c.read(gameProvider).hintedArrow, null);
    });

    test('taps are ignored after gameOver', () async {
      final deadlock = Level(
        id: 99,
        difficulty: 'test',
        lives: 1,
        hints: 0,
        grid: Grid.fromList([
          [const Arrow(Direction.right), const Arrow(Direction.left)],
        ]),
      );
      final c = _containerFor(deadlock);
      addTearDown(c.dispose);
      final notifier = c.read(gameProvider.notifier);

      await notifier.tap(0, 0); // → gameOver
      await notifier.tap(0, 1); // should be no-op
      expect(c.read(gameProvider).lives, 0);
    });
  });
}
