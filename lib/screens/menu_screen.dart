import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../services/level_service.dart';
import '../services/progress_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/futuristic_logo.dart';
import 'daily_screen.dart';
import 'level_loader_screen.dart';
import 'level_select_screen.dart';
import 'settings_screen.dart';
import 'timer_screen.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelIds = ref.watch(levelIdsProvider);
    final progress = ref.watch(progressServiceProvider);

    int playId() {
      final ids = levelIds.value;
      if (ids == null || ids.isEmpty) return 1;
      for (final id in ids) {
        if (progress.isUnlocked(id) && progress.getStars(id) == 0) return id;
      }
      return ids.last;
    }

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 80),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const FuturisticLogo(size: 150),
                        const SizedBox(height: 24),
                        // Title — properly centered with FittedBox so it never clips
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (rect) => const LinearGradient(
                                colors: [
                                  AppColors.neonCyan,
                                  AppColors.neonPurple,
                                  AppColors.neonPink,
                                ],
                              ).createShader(rect),
                              child: const Text(
                                'ARROW PUZZLE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '// tap. think. clear.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Rajdhani',
                            fontSize: 13,
                            letterSpacing: 3,
                            color:
                                AppColors.neonCyan.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 48),
                        _MenuButton(
                          label: 'PLAY',
                          icon: Icons.play_arrow_rounded,
                          color: AppColors.neonCyan,
                          primary: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  LevelLoaderScreen(levelId: playId()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          label: 'LEVELS',
                          icon: Icons.grid_view_rounded,
                          color: AppColors.neonPurple,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LevelSelectScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          label: 'TIMER ATTACK',
                          icon: Icons.bolt_rounded,
                          color: AppColors.neonPink,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TimerScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          label: 'DAILY',
                          icon: Icons.calendar_today_outlined,
                          color: AppColors.neonGreen,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const DailyScreen()),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              // Top-right action row — kept LAST in the Stack so it sits ON
              // TOP of the scroll view and receives taps.
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.ios_share,
                            color: AppColors.neonGreen),
                        tooltip: 'Share',
                        onPressed: () => SharePlus.instance.share(
                          ShareParams(
                            text:
                                '🎮 Try Arrow Puzzle — a relaxing tap-away logic '
                                'game!\n\n${ShareService.playStoreUrl}',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings,
                            color: AppColors.neonCyan),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool primary;
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = primary ? color : Colors.transparent;
    final textColor = primary ? AppColors.darkBgBottom : color;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: primary ? 0.65 : 0.4),
              blurRadius: primary ? 26 : 14,
              spreadRadius: primary ? 1 : 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
