import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Production audio service for playing vernacular speech ("Dadi-Ma Mode")
/// Powered by IBM Watson Text-to-Speech gateway with fallback caching
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentlyPlayingText;

  bool get isPlaying => _isPlaying;
  String? get currentlyPlayingText => _currentlyPlayingText;

  String _getBackendUrl() {
    return dotenv.env['BACKEND_URL'] ??
        dotenv.env['LVM_API_URL'] ??
        'http://localhost:5001';
  }

  /// Synthesizes and plays vernacular text audio.
  /// Returns true if audio played via Watson TTS, false if fallback to Native TTS is needed.
  Future<bool> speakVernacularText(
    String text, {
    String language = 'hi',
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(dynamic error)? onError,
  }) async {
    try {
      final backendUrl = _getBackendUrl();
      final endpoint = Uri.parse('$backendUrl/api/vernacular-tts');

      final response = await http
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'text': text, 'language': language}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 &&
          response.headers['content-type']?.contains('audio') == true &&
          response.bodyBytes.isNotEmpty) {
        await _player.stop();
        _isPlaying = true;
        _currentlyPlayingText = text;
        onStart?.call();

        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        _player.onPlayerComplete.listen((_) {
          _isPlaying = false;
          _currentlyPlayingText = null;
          onComplete?.call();
        });

        await _player.play(DeviceFileSource(filePath));
        return true;
      } else {
        debugPrint(
            '[AudioService] TTS backend returned non-binary or mock response. Using native TTS.');
        _isPlaying = false;
        _currentlyPlayingText = null;
        return false;
      }
    } catch (e) {
      debugPrint('[AudioService] Playback error: $e');
      _isPlaying = false;
      _currentlyPlayingText = null;
      onError?.call(e);
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _currentlyPlayingText = null;
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
