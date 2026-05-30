import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/level_service.dart';
import '../widgets/app_background.dart';
import 'game_screen.dart';

class LevelLoaderScreen extends ConsumerWidget {
  final int levelId;
  const LevelLoaderScreen({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelAsync = ref.watch(levelByIdProvider(levelId));
    return levelAsync.when(
      data: (level) => GameScreen(level: level),
      loading: () => const Scaffold(
        body: AppBackground(
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load level $levelId\n\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
