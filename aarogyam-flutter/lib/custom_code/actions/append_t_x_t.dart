// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

Future<void> appendTXT(String text, String fileName) async {
  try {
    // Get the external storage directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw PlatformException(
        code: 'DIRECTORY_ERROR',
        message: 'Unable to access external storage directory.',
      );
    }

    // Create a file path
    String filePath = '${directory.path}/$fileName.txt';
    File file = File(filePath);

    // Append the text to the file, create it if it doesn't exist
    await file.writeAsString(text, mode: FileMode.append);

    print('Text appended successfully to $filePath');
  } catch (e) {
    print('Error saving file: $e');
    throw PlatformException(
      code: 'FILE_SAVE_ERROR',
      message: 'Failed to save file: $e',
    );
  }
}
