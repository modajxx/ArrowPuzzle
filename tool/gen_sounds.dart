// Generates WAV sound effects into assets/sounds/.
// Run from project root: dart run tool/gen_sounds.dart
//
// Pure procedural audio — no external samples needed. Sounds are intentionally
// subtle and short, matching the calm "tap-away" aesthetic.
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const _sampleRate = 44100;

void main() {
  Directory('assets/sounds').createSync(recursive: true);

  // Short upward chirp — pleasant escape sound.
  _writeWav('escape', _synthesize(
    durationMs: 180,
    samplerFn: (t, normT) {
      final freq = 700 + 600 * normT; // glide 700→1300 Hz
      return sin(2 * pi * freq * t);
    },
  ));

  // Low thunk for blocked taps.
  _writeWav('blocked', _synthesize(
    durationMs: 220,
    samplerFn: (t, normT) {
      final freq = 220 - 60 * normT; // glide 220→160 Hz
      return sin(2 * pi * freq * t) * 0.9 +
          sin(2 * pi * freq * 1.5 * t) * 0.1;
    },
    envelope: _percussive,
  ));

  // Triangle major arpeggio for completion (C-E-G).
  _writeWav('complete', _synthesize(
    durationMs: 700,
    samplerFn: (t, normT) {
      // 3 notes layered with offset starts
      double note(double freq, double start, double end) {
        if (normT < start || normT > end) return 0;
        final localT = (normT - start) / (end - start);
        final env = _bellEnv(localT);
        return sin(2 * pi * freq * t) * env;
      }
      return (note(523.25, 0.00, 0.50) + // C5
              note(659.25, 0.20, 0.70) + // E5
              note(783.99, 0.45, 1.00))  // G5
          /
          1.5;
    },
    envelope: _passthrough,
  ));

  // Soft chime for hints.
  _writeWav('hint', _synthesize(
    durationMs: 220,
    samplerFn: (t, normT) {
      return sin(2 * pi * 1200 * t) * 0.7 +
          sin(2 * pi * 1800 * t) * 0.3;
    },
    envelope: _percussive,
  ));

  stdout.writeln('Done. Generated 4 sounds into assets/sounds/');
}

Int16List _synthesize({
  required int durationMs,
  required double Function(double t, double normT) samplerFn,
  double Function(double normT)? envelope,
}) {
  final samples = (durationMs * _sampleRate / 1000).round();
  final data = Int16List(samples);
  final env = envelope ?? _quickAttackLongDecay;
  for (var i = 0; i < samples; i++) {
    final t = i / _sampleRate;
    final normT = i / samples;
    final raw = samplerFn(t, normT) * env(normT);
    data[i] = (raw * 22000).round().clamp(-32767, 32767);
  }
  return data;
}

double _quickAttackLongDecay(double t) {
  if (t < 0.03) return t / 0.03;
  return pow(1.0 - t, 0.7).toDouble();
}

double _percussive(double t) {
  if (t < 0.01) return t / 0.01;
  return pow(1.0 - t, 2.0).toDouble();
}

double _bellEnv(double t) {
  if (t < 0.05) return t / 0.05;
  return pow(1.0 - t, 1.5).toDouble();
}

double _passthrough(double t) => 1.0;

void _writeWav(String name, Int16List pcm) {
  final dataLen = pcm.length * 2;
  final fileLen = dataLen + 36;
  final b = BytesBuilder();
  void w32(int v) => b.add(
      [v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]);
  void w16(int v) => b.add([v & 0xff, (v >> 8) & 0xff]);

  b.add('RIFF'.codeUnits);
  w32(fileLen);
  b.add('WAVE'.codeUnits);
  b.add('fmt '.codeUnits);
  w32(16); // PCM subchunk size
  w16(1); // format = PCM
  w16(1); // channels = mono
  w32(_sampleRate);
  w32(_sampleRate * 2); // byte rate
  w16(2); // block align
  w16(16); // bits per sample
  b.add('data'.codeUnits);
  w32(dataLen);
  final raw = Uint8List(dataLen);
  for (var i = 0; i < pcm.length; i++) {
    raw[i * 2] = pcm[i] & 0xff;
    raw[i * 2 + 1] = (pcm[i] >> 8) & 0xff;
  }
  b.add(raw);
  File('assets/sounds/$name.wav').writeAsBytesSync(b.toBytes());
  stdout.writeln('  wrote $name.wav (${pcm.length} samples, ${dataLen}B)');
}
