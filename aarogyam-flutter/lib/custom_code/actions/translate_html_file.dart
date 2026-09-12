// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// NOTE: The `translator` package has been removed from the project.
// Translation is a no-op stub — the output file is a copy of the input file.
// Re-implement with a supported translation API when translation is needed.

import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> translateHtmlFile(
    String inputFileName, String outputFileName) async {
  try {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      print('translateHtmlFile: could not find external storage directory');
      return;
    }

    final inputFile = File('${directory.path}/$inputFileName');
    if (!await inputFile.exists()) {
      print('translateHtmlFile: input file does not exist — $inputFileName');
      return;
    }

    // Stub: copy input to output unchanged (translation removed).
    final htmlContent = await inputFile.readAsString();
    final outputFile = File('${directory.path}/$outputFileName');
    await outputFile.writeAsString(htmlContent);

    print('translateHtmlFile: copied $inputFileName → $outputFileName (translation stub)');
  } catch (e) {
    print('translateHtmlFile error: $e');
  }
}
