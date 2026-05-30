import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/level.dart';

class LevelService {
  static const _indexPath = 'assets/levels/index.json';

  static Future<List<int>> availableLevelIds() async {
    final raw = await rootBundle.loadString(_indexPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (json['levels'] as List).cast<int>();
  }

  static Future<Level> loadById(int id) async {
    final path = 'assets/levels/level_${id.toString().padLeft(3, '0')}.json';
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Level.fromJson(json);
  }
}

final levelIdsProvider = FutureProvider<List<int>>((ref) {
  return LevelService.availableLevelIds();
});

final levelByIdProvider = FutureProvider.family<Level, int>((ref, id) {
  return LevelService.loadById(id);
});
