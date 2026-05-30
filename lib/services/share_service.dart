import 'package:share_plus/share_plus.dart';

class ShareService {
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.jtpl.arrowpuzzle';

  static Future<void> shareLevelComplete({
    required int levelId,
    required int moves,
    required int stars,
    required int optimal,
  }) async {
    final perfect = moves == optimal && stars == 3;
    final lines = <String>[
      perfect
          ? '🏆 Perfect run on Level $levelId — Arrow Puzzle!'
          : '⚡ Cleared Level $levelId in $moves moves on Arrow Puzzle!',
      '${"⭐" * stars}${"☆" * (3 - stars)}',
      '',
      'Beat me if you can 👇',
      playStoreUrl,
    ];
    await SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  static Future<void> shareTimerScore({
    required int score,
    required int levelsCleared,
  }) async {
    final lines = [
      '🔥 Timer Attack on Arrow Puzzle!',
      'Score: $score · $levelsCleared levels in 60 seconds',
      '',
      'Beat me if you can 👇',
      playStoreUrl,
    ];
    await SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  static Future<void> shareDaily({
    required DateTime date,
    required int stars,
  }) async {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final lines = [
      '🗓️ Today\'s Arrow Puzzle Challenge — $dateStr',
      '${"⭐" * stars}${"☆" * (3 - stars)}',
      '',
      'Beat me if you can 👇',
      playStoreUrl,
    ];
    await SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }
}
