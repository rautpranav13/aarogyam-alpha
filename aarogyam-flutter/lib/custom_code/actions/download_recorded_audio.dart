// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';

/// Returns [audioPath] if the file exists on disk, otherwise [null].
///
/// The `record` package already saves audio as m4a/aac which IBM Watson STT
/// accepts with `audio/mp4` content-type, so no ffmpeg conversion is needed.
Future<String?> downloadRecordedAudio(String? audioPath) async {
  if (audioPath == null || audioPath.isEmpty) {
    print('downloadRecordedAudio: audioPath is null or empty');
    return null;
  }

  final file = File(audioPath);
  if (!await file.exists()) {
    print('downloadRecordedAudio: file not found at $audioPath');
    return null;
  }

  return audioPath;
}
