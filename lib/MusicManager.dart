import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

/// Singleton music manager — fixed version.
/// Usage:
///   await MusicManager.instance.init();
///   MusicManager.instance.play();
///   MusicManager.instance.stop();
///   MusicManager.instance.setVolume(0.5);
class MusicManager {
  MusicManager._();
  static final MusicManager instance = MusicManager._();

  AudioPlayer? _player;
  bool _initialised = false;
  bool _isPlaying = false;
  double _volume = 0.6;

  /// Call once from main() after Supabase.initialize().
  Future<void> init() async {
    if (_initialised) return;
    try {
      _player = AudioPlayer();
      await _player!.setAsset('assets/music/battle_theme.mp3');
      await _player!.setLoopMode(LoopMode.one);
      await _player!.setVolume(_volume);

      // Track playing state from the player's actual stream
      _player!.playingStream.listen((playing) {
        _isPlaying = playing;
      });

      _initialised = true;
    } catch (e) {
      debugPrint('MusicManager: could not load music — $e');
      // Don't crash the app if music fails — just mark as uninitialised
      _initialised = false;
      _player?.dispose();
      _player = null;
    }
  }

  Future<void> play() async {
    if (!_initialised || _player == null) return;
    if (_player!.playing) return;
    try {
      await _player!.play();
    } catch (e) {
      debugPrint('MusicManager: play error — $e');
    }
  }

  Future<void> stop() async {
    if (!_initialised || _player == null) return;
    try {
      await _player!.stop();
    } catch (e) {
      debugPrint('MusicManager: stop error — $e');
    }
  }

  Future<void> pause() async {
    if (!_initialised || _player == null) return;
    try {
      await _player!.pause();
    } catch (e) {
      debugPrint('MusicManager: pause error — $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (!_initialised || _player == null) return;
    try {
      await _player!.setVolume(_volume);
    } catch (e) {
      debugPrint('MusicManager: setVolume error — $e');
    }
  }

  /// Returns true only if actually playing right now
  bool get isPlaying => _player?.playing ?? false;

  bool get isInitialised => _initialised;

  void dispose() {
    _player?.dispose();
    _player = null;
    _initialised = false;
  }
}