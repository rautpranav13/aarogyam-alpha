// Automatic FlutterFlow imports
// Imports other custom actions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart' show parse;
import 'package:sqflite/sqflite.dart';

Future<void> updateMedicationsDatabase(String filename) async {
  try {
    // Step 1: Read the file from external storage
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/$filename');
    final contents = await file.readAsString();

    // Step 2: Parse the HTML content using the html package
    var document = parse(contents);
    var table =
        document.querySelector('table'); // Get the first <table> element

    if (table == null) {
      throw Exception("No table found in the provided HTML file.");
    }

    // Step 3: Find all rows in the table (skip header row)
    var rows = table.querySelectorAll('tr');

    // Step 4: Open the SQLite database (dbaarogyam.db is precompiled)
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      '$databasePath/dbaarogyam.db',
      version: 1,
    );

    // Step 5: Loop through rows, extract details, and update the database
    for (int i = 1; i < rows.length; i++) {
      var columns = rows[i].getElementsByTagName('td');
      if (columns.length == 4) {
        String title = columns[0].text.trim();
        String dosage = columns[1].text.trim();
        String time = columns[2].text.trim();
        String instructions = columns[3].text.trim();

        // Split time into hour and minute as strings
        var timeParts = time.split(':');
        String hour = timeParts[0].trim();
        String minute = timeParts.length > 1 ? timeParts[1].trim() : '00';

        // Combine title and dosage for the `title` field
        String combinedTitle = "$title + $dosage";

        // Log the details being processed
        print(
            'Processing row $i: Title=$combinedTitle, Hour=$hour, Minute=$minute, Message=$instructions');

        // Step 6: Execute the INSERT OR REPLACE query
        await database.rawInsert(
          '''
          INSERT OR REPLACE INTO medications (id, title, message, hour, minute, turnedon)
          VALUES (?, ?, ?, ?, ?, ?)
          ''',
          [
            i,
            combinedTitle,
            instructions,
            hour,
            minute,
            0
          ], // Store hour and minute as strings
        );

        // Log successful insertion or update
        print('Inserted/Updated row $i: $combinedTitle at $hour:$minute');
      } else {
        // Log skipped rows
        print(
            'Skipped row $i due to unexpected column count: ${columns.length}');
      }
    }

    print('All data successfully updated.');
  } catch (e) {
    // Log errors
    print('Error updating medications database: $e');
  }
}
