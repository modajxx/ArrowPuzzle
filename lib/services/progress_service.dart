import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'prefs_provider.dart';

class ProgressService {
  final SharedPreferences _prefs;
  ProgressService(this._prefs);

  static String _starsKey(int id) => 'level_${id}_stars';

  /// 0 = not completed, 1-3 = stars earned. Only the best score is kept.
  int getStars(int levelId) => _prefs.getInt(_starsKey(levelId)) ?? 0;

  bool isCompleted(int levelId) => getStars(levelId) > 0;

  /// Level 1 is always unlocked; later levels need the previous one cleared.
  bool isUnlocked(int levelId) {
    if (levelId <= 1) return true;
    return isCompleted(levelId - 1);
  }

  /// Records a completion. Only persists if [stars] beats the existing record.
  Future<void> recordCompletion(int levelId, int stars) async {
    assert(stars >= 1 && stars <= 3);
    if (stars > getStars(levelId)) {
      await _prefs.setInt(_starsKey(levelId), stars);
    }
  }

  /// 3 stars = no lives lost, 2 = 1 lost, 1 = 2+ lost.
  static int starsFor({required int livesStart, required int livesRemaining}) {
    final lost = (livesStart - livesRemaining).clamp(0, livesStart);
    if (lost == 0) return 3;
    if (lost == 1) return 2;
    return 1;
  }

  Future<void> resetAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('level_'));
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}

final progressServiceProvider = Provider<ProgressService>(
  (ref) => ProgressService(ref.watch(sharedPreferencesProvider)),
);
