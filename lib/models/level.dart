import 'arrow.dart';
import 'direction.dart';
import 'grid.dart';

class Level {
  final int id;
  final String difficulty;
  final int lives;
  final int hints;
  final Grid grid;

  const Level({
    required this.id,
    required this.difficulty,
    required this.lives,
    required this.hints,
    required this.grid,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    final rawGrid = (json['grid'] as List).cast<List>();
    final cells = rawGrid
        .map<List<Arrow?>>((row) => row
            .map<Arrow?>((cell) =>
                cell == null ? null : Arrow(Direction.fromString(cell as String)))
            .toList())
        .toList();
    return Level(
      id: json['id'] as int,
      difficulty: json['difficulty'] as String? ?? 'normal',
      lives: json['lives'] as int? ?? 3,
      hints: json['hints'] as int? ?? 2,
      grid: Grid.fromList(cells),
    );
  }
}
