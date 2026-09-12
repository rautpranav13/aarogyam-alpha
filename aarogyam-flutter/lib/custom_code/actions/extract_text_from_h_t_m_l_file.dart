// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart' as html_parser;

Future<String> extractTextFromHTMLFile(String filename) async {
  try {
    // Get the external storage directory.
    final directory = await getExternalStorageDirectory();

    if (directory == null) {
      throw Exception("External storage directory is not available.");
    }

    // Construct the file path for the text file.
    final filePath = '${directory.path}/$filename';

    // Check if the file exists.
    if (!File(filePath).existsSync()) {
      throw Exception("File not found at path: $filePath");
    }

    // Read the file content as a string.
    final htmlString = await File(filePath).readAsString();

    // Parse the HTML string.
    final document = html_parser.parse(htmlString);

    // Extract the plain text content.
    String plainText = document.body?.text ?? '';

    // Remove extra spaces and special characters.
    plainText = plainText
        .replaceAll(
            RegExp(r'\s+'), ' ') // Replace multiple spaces with a single space
        .replaceAll(RegExp(r'[^\w\s]'),
            '') // Remove non-alphanumeric characters (except spaces)
        .trim(); // Remove leading/trailing spaces

    return plainText;
  } catch (e) {
    throw Exception('Error extracting text from HTML file: $e');
  }
}
