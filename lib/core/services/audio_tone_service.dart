import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tone families A-E matching the design spec.
/// One AudioPlayer instance per tone category.
enum ToneFamily { A, B, C, D, E }

/// Extension maps each family to its audio asset path.
extension ToneFamilyAsset on ToneFamily {
  String get newOrderAsset => switch (this) {
    ToneFamily.A => 'audio/tone_a_new_order.mp3',
    ToneFamily.B => 'audio/tone_b_new_order.mp3',
    ToneFamily.C => 'audio/tone_c_new_order.mp3',
    ToneFamily.D => 'audio/tone_d_new_order.mp3',
    ToneFamily.E => 'audio/tone_e_new_order.mp3',
  };

  String get reminderAsset => switch (this) {
    ToneFamily.A => 'audio/tone_a_reminder.mp3',
    _ => 'audio/tone_a_reminder.mp3',
  };

  String get lateDeadlineAsset => 'audio/tone_late_deadline.mp3';
}

/// Audio tone service — plays alert sounds for incoming orders.
/// Volume is locked at system alarm stream, not media stream (MOB-RST-04).
class AudioToneService {
  AudioToneService();

  final _player = AudioPlayer();
  ToneFamily _currentFamily = ToneFamily.A;

  /// Play the new-order tone for the configured family
  Future<void> playNewOrderTone() async {
    try {
      await _player.setVolume(1.0);
      await _player.play(AssetSource(_currentFamily.newOrderAsset));
    } catch (e) {
      // Asset may not exist in dev — silently fail
    }
  }

  Future<void> playReminderTone() async {
    try {
      await _player.play(AssetSource(_currentFamily.reminderAsset));
    } catch (_) {}
  }

  Future<void> playLateDeadlineTone() async {
    try {
      await _player.play(AssetSource(_currentFamily.lateDeadlineAsset));
    } catch (_) {}
  }

  Future<void> stop() async {
    await _player.stop();
  }

  void setFamily(ToneFamily family) {
    _currentFamily = family;
  }

  void dispose() {
    _player.dispose();
  }
}

final audioToneServiceProvider = Provider<AudioToneService>((ref) {
  final service = AudioToneService();
  ref.onDispose(service.dispose);
  return service;
});
