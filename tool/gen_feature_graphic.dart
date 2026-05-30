// Generates the Play Store feature graphic (1024x500). Image-only — add the
// title in Canva/Photoshop if you want custom typography.
// Run: dart run tool/gen_feature_graphic.dart
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _w = 1024;
const _h = 500;

void main() {
  Directory('store_assets').createSync(recursive: true);

  final canvas = img.Image(width: _w, height: _h);

  // Vertical gradient bg (dark navy → near-black)
  for (var y = 0; y < _h; y++) {
    final t = y / _h;
    final r = (0x15 * (1 - t) + 0x05 * t).round();
    final g = (0x20 * (1 - t) + 0x06 * t).round();
    final b = (0x3A * (1 - t) + 0x17 * t).round();
    img.fillRect(canvas,
        x1: 0, y1: y, x2: _w - 1, y2: y, color: img.ColorRgb8(r, g, b));
  }

  // Subtle grid lines
  final gridLine = img.ColorRgba8(0x00, 0xE5, 0xFF, 38);
  for (var x = 0; x < _w; x += 56) {
    img.drawLine(canvas, x1: x, y1: 0, x2: x, y2: _h - 1, color: gridLine);
  }
  for (var y = 0; y < _h; y += 56) {
    img.drawLine(canvas, x1: 0, y1: y, x2: _w - 1, y2: y, color: gridLine);
  }

  // Scattered glow dots
  final cyan = img.ColorRgb8(0x00, 0xE5, 0xFF);
  final purple = img.ColorRgb8(0xB3, 0x88, 0xFF);
  final pink = img.ColorRgb8(0xFF, 0x40, 0x81);
  final rng = math.Random(7);
  for (var i = 0; i < 80; i++) {
    final x = rng.nextInt(_w);
    final y = rng.nextInt(_h);
    final r = rng.nextInt(2) + 1;
    final color = i % 3 == 0 ? purple : (i % 3 == 1 ? pink : cyan);
    img.fillCircle(canvas, x: x, y: y, radius: r, color: color);
  }

  // Tile (icon) on the left — visual anchor.
  final tileSize = 320;
  final tileX = 90;
  final tileY = (_h - tileSize) ~/ 2;
  final white = img.ColorRgb8(255, 255, 255);
  img.fillRect(canvas,
      x1: tileX,
      y1: tileY,
      x2: tileX + tileSize,
      y2: tileY + tileSize,
      color: white,
      radius: 60);
  _drawIconArrows(canvas, tileX.toDouble(), tileY.toDouble(),
      tileSize.toDouble());

  // Right side — three glowing example arrows (cyan/purple/pink).
  final centerX = (tileX + tileSize + _w) ~/ 2 + 40;
  _bigArrow(canvas, centerX - 100, 130, 120, cyan, 'right');
  _bigArrow(canvas, centerX + 60, 230, 120, purple, 'down');
  _bigArrow(canvas, centerX - 40, 360, 120, pink, 'up');

  File('store_assets/feature_graphic.png')
      .writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('  wrote store_assets/feature_graphic.png (1024x500)');
}

void _drawIconArrows(img.Image c, double tileX, double tileY, double tileSize) {
  final red = img.ColorRgb8(0xC8, 0x29, 0x29);
  final blue = img.ColorRgb8(0x21, 0x66, 0xD9);
  final pad = tileSize * 0.18;
  final inner = tileSize - 2 * pad;
  final cell = inner / 2;

  _arrow(c, tileX + pad + cell * 0.5, tileY + pad + cell * 0.5,
      cell * 0.75, red, 'lBend');
  _arrow(c, tileX + pad + cell * 1.5, tileY + pad + cell * 0.5,
      cell * 0.75, blue, 'up');
  _arrow(c, tileX + pad + cell * 0.5, tileY + pad + cell * 1.5,
      cell * 0.75, red, 'up');
  _arrow(c, tileX + pad + cell * 1.5, tileY + pad + cell * 1.5,
      cell * 0.75, blue, 'down');
}

void _bigArrow(img.Image c, double cx, double cy, double size, img.Color color,
    String dir) {
  _arrow(c, cx, cy, size, color, dir);
}

void _arrow(img.Image c, double cx, double cy, double size, img.Color color,
    String kind) {
  final thick = size * 0.18;
  switch (kind) {
    case 'up':
      img.fillRect(c,
          x1: (cx - thick / 2).round(),
          y1: (cy - size * 0.35).round(),
          x2: (cx + thick / 2).round(),
          y2: (cy + size * 0.45).round(),
          color: color,
          radius: thick * 0.5);
      _triangle(c, [
        (cx, cy - size * 0.50),
        (cx + size * 0.30, cy - size * 0.20),
        (cx - size * 0.30, cy - size * 0.20),
      ], color);
      break;
    case 'down':
      img.fillRect(c,
          x1: (cx - thick / 2).round(),
          y1: (cy - size * 0.45).round(),
          x2: (cx + thick / 2).round(),
          y2: (cy + size * 0.35).round(),
          color: color,
          radius: thick * 0.5);
      _triangle(c, [
        (cx, cy + size * 0.50),
        (cx + size * 0.30, cy + size * 0.20),
        (cx - size * 0.30, cy + size * 0.20),
      ], color);
      break;
    case 'right':
      img.fillRect(c,
          x1: (cx - size * 0.45).round(),
          y1: (cy - thick / 2).round(),
          x2: (cx + size * 0.35).round(),
          y2: (cy + thick / 2).round(),
          color: color,
          radius: thick * 0.5);
      _triangle(c, [
        (cx + size * 0.50, cy),
        (cx + size * 0.20, cy - size * 0.30),
        (cx + size * 0.20, cy + size * 0.30),
      ], color);
      break;
    case 'lBend':
      img.fillRect(c,
          x1: (cx + size * 0.15 - thick / 2).round(),
          y1: (cy - size * 0.45).round(),
          x2: (cx + size * 0.15 + thick / 2).round(),
          y2: (cy + size * 0.10).round(),
          color: color,
          radius: thick * 0.5);
      img.fillRect(c,
          x1: (cx - size * 0.30).round(),
          y1: (cy + size * 0.10 - thick / 2).round(),
          x2: (cx + size * 0.15 + thick / 2).round(),
          y2: (cy + size * 0.10 + thick / 2).round(),
          color: color,
          radius: thick * 0.5);
      _triangle(c, [
        (cx - size * 0.45, cy + size * 0.10),
        (cx - size * 0.20, cy + size * 0.10 - size * 0.22),
        (cx - size * 0.20, cy + size * 0.10 + size * 0.22),
      ], color);
      break;
  }
}

void _triangle(img.Image c, List<(double, double)> pts, img.Color color) {
  final xs = pts.map((p) => p.$1).toList();
  final ys = pts.map((p) => p.$2).toList();
  final minX = xs.reduce(math.min).floor();
  final maxX = xs.reduce(math.max).ceil();
  final minY = ys.reduce(math.min).floor();
  final maxY = ys.reduce(math.max).ceil();
  for (var y = minY; y <= maxY; y++) {
    for (var x = minX; x <= maxX; x++) {
      if (_inTriangle(x + 0.5, y + 0.5, pts)) {
        if (x >= 0 && x < c.width && y >= 0 && y < c.height) {
          c.setPixel(x, y, color);
        }
      }
    }
  }
}

bool _inTriangle(double px, double py, List<(double, double)> p) {
  double s((double, double) a, (double, double) b, (double, double) c) =>
      (a.$1 - c.$1) * (b.$2 - c.$2) - (b.$1 - c.$1) * (a.$2 - c.$2);
  final d1 = s((px, py), p[0], p[1]);
  final d2 = s((px, py), p[1], p[2]);
  final d3 = s((px, py), p[2], p[0]);
  return !((d1 < 0 || d2 < 0 || d3 < 0) && (d1 > 0 || d2 > 0 || d3 > 0));
}
