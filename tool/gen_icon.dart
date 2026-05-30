// Generates app icon PNGs matching the user-requested red+blue 2x2 arrow style.
// Run: dart run tool/gen_icon.dart
//
// Outputs:
//   - icon.png       (legacy: white bg + 4 arrows)
//   - icon_fg.png    (adaptive foreground: transparent bg + 4 arrows,
//                     scaled to fit safe area)
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _size = 1024;

// Two-tone palette matching the reference image.
final _red = img.ColorRgb8(0xC8, 0x29, 0x29);
final _blue = img.ColorRgb8(0x21, 0x66, 0xD9);

void main() {
  Directory('assets/icons').createSync(recursive: true);

  // ---- Legacy icon: white bg ----
  final legacy = img.Image(width: _size, height: _size);
  img.fill(legacy, color: img.ColorRgb8(255, 255, 255));
  _drawArrows(legacy, alpha: 255);
  File('assets/icons/icon.png').writeAsBytesSync(img.encodePng(legacy));
  stdout.writeln('  wrote icon.png');

  // ---- Adaptive foreground: transparent bg ----
  final fg = img.Image(width: _size, height: _size, numChannels: 4);
  _drawArrows(fg, alpha: 255, safeArea: true);
  File('assets/icons/icon_fg.png').writeAsBytesSync(img.encodePng(fg));
  stdout.writeln('  wrote icon_fg.png');

  stdout.writeln('Done.');
}

void _drawArrows(img.Image canvas, {required int alpha, bool safeArea = false}) {
  final pad = safeArea ? _size * 0.18 : _size * 0.10;
  final inner = _size - 2 * pad;
  final cellSize = inner / 2;

  // Quadrants: (col, row, color, direction)
  // Directions chosen to roughly match the reference (looped flow).
  final cells = <(double, double, img.Color, _ArrowKind)>[
    // Top-left: red, L-bend down
    (pad + cellSize * 0.5, pad + cellSize * 0.5, _red, _ArrowKind.lBendDown),
    // Top-right: blue, straight up
    (pad + cellSize * 1.5, pad + cellSize * 0.5, _blue, _ArrowKind.straightUp),
    // Bottom-left: red, straight up
    (pad + cellSize * 0.5, pad + cellSize * 1.5, _red, _ArrowKind.straightUp),
    // Bottom-right: blue, straight down
    (pad + cellSize * 1.5, pad + cellSize * 1.5, _blue, _ArrowKind.straightDown),
  ];

  for (final (cx, cy, color, kind) in cells) {
    _drawArrowShape(canvas, cx, cy, cellSize * 0.78, color, kind);
  }
}

enum _ArrowKind { straightUp, straightDown, lBendDown }

void _drawArrowShape(
  img.Image canvas,
  double cx,
  double cy,
  double size,
  img.Color color,
  _ArrowKind kind,
) {
  final thick = size * 0.16;

  switch (kind) {
    case _ArrowKind.straightUp:
      _vshaft(canvas, cx, cy - size * 0.35, cy + size * 0.45, thick, color);
      _headUp(canvas, cx, cy - size * 0.45, size * 0.30, color);
      break;
    case _ArrowKind.straightDown:
      _vshaft(canvas, cx, cy - size * 0.45, cy + size * 0.35, thick, color);
      _headDown(canvas, cx, cy + size * 0.45, size * 0.30, color);
      break;
    case _ArrowKind.lBendDown:
      // Vertical shaft from top toward middle
      _vshaft(canvas, cx + size * 0.15, cy - size * 0.45, cy + size * 0.10,
          thick, color);
      // Horizontal shaft from right to left
      _hshaft(canvas, cx - size * 0.30, cx + size * 0.15 + thick / 2,
          cy + size * 0.10, thick, color);
      // Arrow head pointing left
      _headLeft(canvas, cx - size * 0.40, cy + size * 0.10, size * 0.28, color);
      break;
  }
}

void _vshaft(img.Image c, double x, double yTop, double yBot, double thick,
    img.Color color) {
  img.fillRect(
    c,
    x1: (x - thick / 2).round(),
    y1: yTop.round(),
    x2: (x + thick / 2).round(),
    y2: yBot.round(),
    color: color,
    radius: thick * 0.5,
  );
}

void _hshaft(img.Image c, double xLeft, double xRight, double y, double thick,
    img.Color color) {
  img.fillRect(
    c,
    x1: xLeft.round(),
    y1: (y - thick / 2).round(),
    x2: xRight.round(),
    y2: (y + thick / 2).round(),
    color: color,
    radius: thick * 0.5,
  );
}

void _headUp(img.Image c, double cx, double tipY, double size, img.Color color) {
  _drawTriangle(c, [
    (cx, tipY),
    (cx + size * 0.7, tipY + size),
    (cx - size * 0.7, tipY + size),
  ], color);
}

void _headDown(img.Image c, double cx, double tipY, double size, img.Color color) {
  _drawTriangle(c, [
    (cx, tipY),
    (cx + size * 0.7, tipY - size),
    (cx - size * 0.7, tipY - size),
  ], color);
}

void _headLeft(img.Image c, double tipX, double cy, double size, img.Color color) {
  _drawTriangle(c, [
    (tipX, cy),
    (tipX + size, cy - size * 0.7),
    (tipX + size, cy + size * 0.7),
  ], color);
}

void _drawTriangle(
  img.Image c,
  List<(double, double)> pts,
  img.Color color,
) {
  // Bounding box
  final xs = pts.map((p) => p.$1).toList();
  final ys = pts.map((p) => p.$2).toList();
  final minX = xs.reduce(math.min).floor();
  final maxX = xs.reduce(math.max).ceil();
  final minY = ys.reduce(math.min).floor();
  final maxY = ys.reduce(math.max).ceil();

  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      if (_pointInTriangle(x + 0.5, y + 0.5, pts)) {
        if (x >= 0 && x < c.width && y >= 0 && y < c.height) {
          c.setPixel(x, y, color);
        }
      }
    }
  }
}

bool _pointInTriangle(double px, double py, List<(double, double)> pts) {
  double sign((double, double) a, (double, double) b, (double, double) c) {
    return (a.$1 - c.$1) * (b.$2 - c.$2) - (b.$1 - c.$1) * (a.$2 - c.$2);
  }

  final d1 = sign((px, py), pts[0], pts[1]);
  final d2 = sign((px, py), pts[1], pts[2]);
  final d3 = sign((px, py), pts[2], pts[0]);
  final hasNeg = d1 < 0 || d2 < 0 || d3 < 0;
  final hasPos = d1 > 0 || d2 > 0 || d3 > 0;
  return !(hasNeg && hasPos);
}
