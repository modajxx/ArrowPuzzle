// Quick CLI validator for level JSON files. Run from project root:
//   dart run tool/validate_levels.dart
// Exits non-zero if any level is missing, malformed, or unsolvable.
import 'dart:convert';
import 'dart:io';

import 'package:arrow_puzzle/engine/solver.dart';
import 'package:arrow_puzzle/models/level.dart';

void main() async {
  final indexFile = File('assets/levels/index.json');
  if (!indexFile.existsSync()) {
    stderr.writeln('Missing assets/levels/index.json');
    exit(2);
  }

  final ids = ((jsonDecode(indexFile.readAsStringSync())
              as Map<String, dynamic>)['levels'] as List)
      .cast<int>();

  var bad = 0;
  for (final id in ids) {
    final path = 'assets/levels/level_${id.toString().padLeft(3, '0')}.json';
    final f = File(path);
    if (!f.existsSync()) {
      stderr.writeln('MISSING  $path');
      bad++;
      continue;
    }
    try {
      final level = Level.fromJson(
        jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
      );
      if (level.id != id) {
        stderr.writeln('ID MISMATCH  $path (id field is ${level.id})');
        bad++;
        continue;
      }
      final solution = Solver.findSolution(level.grid);
      if (solution == null) {
        stderr.writeln('UNSOLVABLE  level $id\n${level.grid.debugString()}');
        bad++;
        continue;
      }
      stdout.writeln(
          'OK  level $id  (${level.grid.rows}x${level.grid.cols}, '
          '${level.grid.arrowCount} arrows, '
          'solve in ${solution.length} taps)');
    } catch (e) {
      stderr.writeln('PARSE ERROR  $path: $e');
      bad++;
    }
  }

  if (bad > 0) {
    stderr.writeln('\n$bad level(s) failed validation.');
    exit(1);
  }
  stdout.writeln('\nAll ${ids.length} levels valid.');
}
