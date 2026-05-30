import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/level_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'level_loader_screen.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelIdsAsync = ref.watch(levelIdsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Levels')),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: levelIdsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (ids) => GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1,
              ),
              itemCount: ids.length,
              itemBuilder: (_, i) => _LevelCard(
                levelId: ids[i],
                entryIndex: i,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends ConsumerWidget {
  final int levelId;
  final int entryIndex;
  const _LevelCard({required this.levelId, required this.entryIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressServiceProvider);
    final unlocked = progress.isUnlocked(levelId);
    final stars = progress.getStars(levelId);
    final t = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final card = unlocked
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: stars == 3
                    ? [
                        AppColors.accent.withValues(alpha: 0.20),
                        AppColors.accentDeep.withValues(alpha: 0.10),
                      ]
                    : [
                        surface.withValues(alpha: 0.9),
                        surface.withValues(alpha: 0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accent
                    .withValues(alpha: stars == 3 ? 0.8 : 0.35),
                width: stars == 3 ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark
                          ? AppColors.darkCardShadow
                          : AppColors.lightCardShadow),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$levelId',
                    style: t.displayLarge?.copyWith(fontSize: 30)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final filled = i < stars;
                    return Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: filled
                          ? AppColors.star
                          : Theme.of(context).disabledColor,
                    );
                  }),
                ),
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Center(
              child: Icon(Icons.lock,
                  size: 28, color: Theme.of(context).disabledColor),
            ),
          );

    final tappable = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: unlocked
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LevelLoaderScreen(levelId: levelId),
                ),
              )
          : null,
      child: card,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + entryIndex * 30),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) {
        final delayFrac =
            (entryIndex * 30) / (300 + entryIndex * 30).toDouble();
        final adj = ((t - delayFrac) / (1 - delayFrac)).clamp(0.0, 1.0);
        return Opacity(
          opacity: adj,
          child: Transform.translate(
            offset: Offset(0, (1 - adj) * 20),
            child: child,
          ),
        );
      },
      child: tappable,
    );
  }
}
