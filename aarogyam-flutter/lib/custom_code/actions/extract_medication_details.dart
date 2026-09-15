// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart' show parse;
import 'dart:convert';

Future<dynamic> extractMedicationDetails(String filename) async {
  try {
    // Step 1: Read the file from external storage
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/$filename');
    final contents = await file.readAsString();

    // Step 2: Parse the HTML content and locate the table
    var document = parse(contents);
    var table =
        document.querySelector('table'); // Get the first <table> element

    if (table == null) {
      throw Exception("No table found in the provided HTML file.");
    }

    // Step 3: Find all rows in the table (skip header row)
    var rows = table.querySelectorAll('tr');
    List<Map<String, dynamic>> medications = [];

    // Step 4: Loop through rows and extract details
    for (int i = 1; i < rows.length; i++) {
      var columns = rows[i].getElementsByTagName('td');
      if (columns.length == 4) {
        String title = columns[0].text.trim();
        String dosage = columns[1].text.trim();
        String time = columns[2].text.trim();
        String instructions = columns[3].text.trim();

        // Split time into hour and minute
        var timeParts = time.split(':');
        String hour = timeParts[0].trim();
        String minute = timeParts.length > 1 ? timeParts[1].trim() : '00';

        // Step 5: Add the extracted data into the list as JSON
        medications.add({
          'id': i,
          'title': "$title + $dosage",
          'message': instructions,
          'hour': hour,
          'minute': minute,
        });
      }
    }

    // Convert the list of medication details to a JSON string
    debugPrint(jsonEncode(medications));
    return jsonEncode(medications);
  } catch (e) {
    debugPrint('Error reading or parsing file: $e');
    return jsonEncode([]);
  }
}
