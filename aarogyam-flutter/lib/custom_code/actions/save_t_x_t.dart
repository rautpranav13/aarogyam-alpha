// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

Future<void> saveTXT(String text, String fileName) async {
  try {
    // Get the external storage directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw PlatformException(
        code: 'DIRECTORY_ERROR',
        message: 'Unable to access external storage directory.',
      );
    }

    // Create a unique file path if the file already exists
    String filePath = '${directory.path}/$fileName';
    File file = File(filePath);
    // int counter = 1;
    // while (file.existsSync()) {
    //   filePath = '${directory.path}/$fileName${counter}.txt';
    //   file = File(filePath);
    //   counter++;
    // }

    // Write the text to the file
    await file.writeAsString(text);

    debugPrint('File saved successfully at $filePath');
  } catch (e) {
    debugPrint('Error saving file: $e');
    throw PlatformException(
      code: 'FILE_SAVE_ERROR',
      message: 'Failed to save file: $e',
    );
  }
}
