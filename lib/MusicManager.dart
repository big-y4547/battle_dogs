import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Singleton music manager.
/// Usage:
///   await MusicManager.instance.init();   // once in main()
///   MusicManager.instance.play();
///   MusicManager.instance.stop();
///   MusicManager.instance.setVolume(0.5);
class MusicManager {
  MusicManager._();
  static final MusicManager instance = MusicManager._();

  final AudioPlayer _player = AudioPlayer();
  bool _initialised = false;

  /// Call once from main() after Supabase.initialize().
  Future<void> init() async {
    if (_initialised) return;
    try {
      await _player.setAsset('assets/music/battle_theme.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.6);
      _initialised = true;
    } catch (e) {
      debugPrint('MusicManager: could not load music — $e');
    }
  }

  Future<void> play() async {
    if (!_initialised) return;
    if (_player.playing) return;
    await _player.play();
  }

  Future<void> stop() async {
    if (!_initialised) return;
    await _player.stop();
  }

  Future<void> pause() async {
    if (!_initialised) return;
    await _player.pause();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  bool get isPlaying => _player.playing;

  void dispose() {
    _player.dispose();
  }
}