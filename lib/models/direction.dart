enum Direction {
  up,
  down,
  left,
  right;

  (int dr, int dc) get delta => switch (this) {
        Direction.up => (-1, 0),
        Direction.down => (1, 0),
        Direction.left => (0, -1),
        Direction.right => (0, 1),
      };

  static Direction fromString(String s) => switch (s) {
        'up' => Direction.up,
        'down' => Direction.down,
        'left' => Direction.left,
        'right' => Direction.right,
        _ => throw ArgumentError('Unknown direction: $s'),
      };

  String get asString => name;
}
