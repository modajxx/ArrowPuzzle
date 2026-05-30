import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/daily_challenge_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import 'game_screen.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(dailyChallengeServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      extendBodyBehindAppBar: true,
      body: AppBackground(child: SafeArea(child: _DailyBody(service: service))),
    );
  }
}

class _DailyBody extends StatefulWidget {
  final DailyChallengeService service;
  const _DailyBody({required this.service});

  @override
  State<_DailyBody> createState() => _DailyBodyState();
}

class _DailyBodyState extends State<_DailyBody> {
  // Tracked so the calendar refreshes after a play session pops.
  int _refreshTick = 0;

  void _refresh() => setState(() => _refreshTick++);

  Future<void> _playToday() async {
    final today = _todayDateOnly();
    final level = DailyChallengeService.generateFor(today);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          level: level,
          hideNextLevel: true,
          onComplete: (stars) =>
              widget.service.recordCompletion(today, stars),
        ),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayDateOnly();
    final difficulty = DailyChallengeService.difficultyFor(today);
    final todayStars = widget.service.getStarsFor(today);
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      key: ValueKey(_refreshTick),
      children: [
        _TodayCard(
          date: today,
          difficulty: difficulty,
          stars: todayStars,
          onPlay: _playToday,
        ),
        const SizedBox(height: 32),
        Text('This Month', style: t.titleLarge),
        const SizedBox(height: 12),
        _CalendarGrid(
          year: today.year,
          month: today.month,
          today: today,
          service: widget.service,
        ),
        const SizedBox(height: 24),
        _TrophyRow(service: widget.service),
      ],
    );
  }

  DateTime _todayDateOnly() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}

class _TodayCard extends StatelessWidget {
  final DateTime date;
  final DailyDifficulty difficulty;
  final int stars;
  final VoidCallback onPlay;
  const _TodayCard({
    required this.date,
    required this.difficulty,
    required this.stars,
    required this.onPlay,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final played = stars > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_months[date.month - 1]} ${date.day}, ${date.year}',
            style: t.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Difficulty: ${difficulty.name}',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (played) ...[
            Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: AppColors.accent,
                    size: 28,
                  ),
                const SizedBox(width: 12),
                Text('Best', style: t.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(
                    onPressed: onPlay, child: const Text('Play Again')),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.ios_share,
                      color: AppColors.neonGreen),
                  tooltip: 'Share',
                  onPressed: () => ShareService.shareDaily(
                      date: date, stars: stars),
                ),
              ],
            ),
          ] else
            FilledButton(onPressed: onPlay, child: const Text('Play Today')),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final DateTime today;
  final DailyChallengeService service;
  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.today,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sun = 0
    final cells = <Widget>[];

    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final isFuture = date.isAfter(today);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final completed = service.isCompleted(date);
      cells.add(_DayCell(
        day: d,
        isToday: isToday,
        isFuture: isFuture,
        completed: completed,
      ));
    }

    return Column(
      children: [
        const _WeekdayHeader(),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: cells,
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();
  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        for (final d in _days)
          Expanded(
            child: Center(
              child: Text(d, style: muted),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isFuture;
  final bool completed;
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Container(
      decoration: BoxDecoration(
        color: completed
            ? AppColors.accent.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: AppColors.accent, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: t.bodyMedium?.copyWith(
              color: isFuture && !isToday ? muted : null,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            completed ? Icons.star : Icons.star_border,
            size: 12,
            color: completed ? AppColors.accent : muted.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _TrophyRow extends StatelessWidget {
  final DailyChallengeService service;
  const _TrophyRow({required this.service});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final months = service.completedMonths().toList()
      ..sort((a, b) =>
          (a.year * 100 + a.month).compareTo(b.year * 100 + b.month));
    final fullyDone = months
        .where((m) => service.monthCompleted(m.year, m.month))
        .toList();

    if (fullyDone.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined,
                color: Theme.of(context).disabledColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete every day of a month to earn a trophy.',
                style: t.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final m in fullyDone) _Trophy(year: m.year, month: m.month),
      ],
    );
  }
}

class _Trophy extends StatelessWidget {
  final int year;
  final int month;
  const _Trophy({required this.year, required this.month});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events, color: AppColors.accent, size: 28),
          const SizedBox(height: 4),
          Text('${_TodayCard._months[month - 1]} $year',
              style: t.bodyMedium),
        ],
      ),
    );
  }
}
