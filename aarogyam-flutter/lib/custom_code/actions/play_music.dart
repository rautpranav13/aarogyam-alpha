// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

Future<void> playMusic(
  String audioPath,
) async {
  try {
    // Check if the file exists.
    if (!File(audioPath).existsSync()) {
      throw Exception("Audio file not found at path: $audioPath");
    }

    // Initialize the audio player.
    final audioPlayer = AudioPlayer();

    // Play the audio file.
    await audioPlayer.play(DeviceFileSource(audioPath));
  } catch (e) {
    // Handle any errors that occur.
    debugPrint('Error playing audio: $e');
  }
}
