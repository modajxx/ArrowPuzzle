import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_state.dart';
import '../services/game_notifier.dart';
import '../theme/app_theme.dart';
import 'arrow_cell.dart';

class GridBoard extends ConsumerWidget {
  const GridBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 18.0;
        final innerW = constraints.maxWidth - padding * 2;
        final innerH = constraints.maxHeight - padding * 2;
        final cellSize = (innerW / state.grid.cols)
            .clamp(0.0, innerH / state.grid.rows)
            .toDouble();
        final boardW = cellSize * state.grid.cols;
        final boardH = cellSize * state.grid.rows;

        return Center(
          child: Container(
            padding: const EdgeInsets.all(padding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.neonCyan.withValues(alpha: 0.06),
                        AppColors.neonPurple.withValues(alpha: 0.04),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.85),
                        Colors.white.withValues(alpha: 0.65),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonCyan.withValues(alpha: isDark ? 0.35 : 0.20),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.20),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: isDark
                      ? AppColors.darkCardShadow
                      : AppColors.lightCardShadow,
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SizedBox(
              width: boardW,
              height: boardH,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var r = 0; r < state.grid.rows; r++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var c = 0; c < state.grid.cols; c++)
                          ArrowCell(
                            arrow: state.grid.at(r, c),
                            size: cellSize,
                            escaping: state.escaping.contains((r, c)),
                            blocked: state.recentlyBlocked == (r, c),
                            blockedNonce: state.blockedNonce,
                            hint: state.hintedArrow == (r, c),
                            hintNonce: state.hintNonce,
                            canEscape: state.grid.at(r, c) != null &&
                                state.grid.canEscape(r, c),
                            entryIndex: r * state.grid.cols + c,
                            onTap: state.status == GameStatus.playing
                                ? () => notifier.tap(r, c)
                                : null,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
