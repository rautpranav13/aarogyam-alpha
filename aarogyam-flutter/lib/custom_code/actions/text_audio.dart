// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert'; // For utf8 and base64Encode
import 'dart:io'; // For File operations
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:path_provider/path_provider.dart'; // For file storage

Future<String?> textAudio(
    String apiKey, String url, String text, String fileName) async {
  try {
    // Get the external storage directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      print('Unable to access external storage directory.');
      return null;
    }

    // Define the target path
    final appDir = Directory('${directory.path}/speech');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    // Construct the full file path
    final filePath = '${appDir.path}/$fileName';

    // Prepare the API endpoint
    final endpoint = Uri.parse('$url/v1/synthesize?voice=en-US_MichaelV3Voice');

    // Encode API key for Basic Authentication
    final authHeader = 'Basic ${base64Encode(utf8.encode('apikey:$apiKey'))}';

    // Set request headers
    final headers = {
      'Authorization': authHeader,
      'Content-Type': 'application/json',
      'Accept': 'audio/mp3',
    };

    // Prepare the request body
    final body = '{"text":"$text"}';

    // Make the POST request
    final response = await http.post(endpoint, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Save the audio data to a file
      final audioFile = File(filePath);
      await audioFile.writeAsBytes(response.bodyBytes);
      print('Audio saved successfully at: $filePath');
      return filePath; // Return the file path
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      return null;
    }
  } catch (e) {
    print('Exception occurred: $e');
    return null;
  }
}
