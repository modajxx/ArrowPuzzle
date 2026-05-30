import 'arrow.dart';
import 'direction.dart';

/// Immutable grid of arrows. All mutating operations return a new Grid.
class Grid {
  final int rows;
  final int cols;
  final List<List<Arrow?>> _cells;

  Grid._(this.rows, this.cols, this._cells);

  factory Grid.fromList(List<List<Arrow?>> cells) {
    final rows = cells.length;
    if (rows == 0) throw ArgumentError('Grid must have at least one row');
    final cols = cells[0].length;
    if (cells.any((r) => r.length != cols)) {
      throw ArgumentError('All rows must have the same length');
    }
    final copy = cells.map((r) => List<Arrow?>.unmodifiable(r)).toList();
    return Grid._(rows, cols, List.unmodifiable(copy));
  }

  factory Grid.empty(int rows, int cols) {
    final cells = List.generate(
      rows,
      (_) => List<Arrow?>.filled(cols, null),
    );
    return Grid.fromList(cells);
  }

  Arrow? at(int r, int c) => _cells[r][c];

  bool inBounds(int r, int c) => r >= 0 && r < rows && c >= 0 && c < cols;

  bool get isEmpty {
    for (final row in _cells) {
      for (final cell in row) {
        if (cell != null) return false;
      }
    }
    return true;
  }

  int get arrowCount {
    var n = 0;
    for (final row in _cells) {
      for (final cell in row) {
        if (cell != null) n++;
      }
    }
    return n;
  }

  /// Returns every (row, col) position currently containing an arrow.
  List<(int, int)> positions() {
    final out = <(int, int)>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (_cells[r][c] != null) out.add((r, c));
      }
    }
    return out;
  }

  /// True if the arrow at (r,c) has a clear path to the grid edge in its
  /// direction. Returns false if (r,c) is empty.
  bool canEscape(int r, int c) {
    final arrow = at(r, c);
    if (arrow == null) return false;
    final (dr, dc) = arrow.direction.delta;
    var nr = r + dr;
    var nc = c + dc;
    while (inBounds(nr, nc)) {
      if (_cells[nr][nc] != null) return false;
      nr += dr;
      nc += dc;
    }
    return true;
  }

  /// Returns a new Grid with the arrow at (r,c) removed. Throws if cell is empty.
  Grid removeArrow(int r, int c) {
    if (_cells[r][c] == null) {
      throw StateError('No arrow at ($r,$c)');
    }
    final newCells = _cells
        .map((row) => List<Arrow?>.from(row))
        .toList();
    newCells[r][c] = null;
    return Grid.fromList(newCells);
  }

  /// Human-readable debug representation. Empty cell = `.`,
  /// arrows = `^ v < >` for up/down/left/right.
  String debugString() {
    final buf = StringBuffer();
    for (final row in _cells) {
      for (final cell in row) {
        buf.write(switch (cell?.direction) {
          null => '.',
          Direction.up => '^',
          Direction.down => 'v',
          Direction.left => '<',
          Direction.right => '>',
        });
        buf.write(' ');
      }
      buf.writeln();
    }
    return buf.toString();
  }
}
