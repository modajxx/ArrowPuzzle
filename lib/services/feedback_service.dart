import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_service.dart';

/// Wraps sound + haptic feedback. Reads [Settings] live so toggles take effect
/// immediately without a restart.
class FeedbackService {
  final Ref _ref;
  final bool _disabled;
  final Map<String, AudioPlayer> _players = {};

  /// Set `disabled: true` in tests or any environment without platform
  /// channels (audioplayers + HapticFeedback both require them).
  FeedbackService(this._ref, {bool disabled = false}) : _disabled = disabled; // ignore: prefer_initializing_formals

  Settings get _settings => _ref.read(settingsProvider);

  void tapEscape() {
    if (_disabled) return;
    if (_settings.hapticsEnabled) unawaited(HapticFeedback.lightImpact());
    if (_settings.soundEnabled) unawaited(_play('escape'));
  }

  void tapBlocked() {
    if (_disabled) return;
    if (_settings.hapticsEnabled) unawaited(HapticFeedback.heavyImpact());
    if (_settings.soundEnabled) unawaited(_play('blocked'));
  }

  void hint() {
    if (_disabled) return;
    if (_settings.hapticsEnabled) unawaited(HapticFeedback.selectionClick());
    if (_settings.soundEnabled) unawaited(_play('hint'));
  }

  void levelComplete() {
    if (_disabled) return;
    if (_settings.hapticsEnabled) unawaited(HapticFeedback.mediumImpact());
    if (_settings.soundEnabled) unawaited(_play('complete'));
  }

  Future<void> _play(String name) async {
    try {
      var p = _players[name];
      if (p == null) {
        p = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
        await p.setSource(AssetSource('sounds/$name.wav'));
        _players[name] = p;
      }
      await p.seek(Duration.zero);
      await p.resume();
    } catch (_) {
      // Audio is decorative — never break the game over a missing player.
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
    _players.clear();
  }
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  final service = FeedbackService(ref);
  ref.onDispose(service.dispose);
  return service;
});
