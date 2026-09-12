import 'package:sqflite/sqflite.dart';

/// BEGIN UPDATEREMAINDER
Future performUpdateremainder(
  Database database, {
  int? id,
  String? title,
  String? message,
  int? hour,
  int? minute,
}) {
  final query = '''
INSERT OR REPLACE INTO medications (id, title, message, hour, minute)
VALUES ($id, $title, $message, $hour, $minute);
''';
  return database.rawQuery(query);
}

/// END UPDATEREMAINDER

/// BEGIN UPDATETURNEDON
Future performUpdateturnedon(
  Database database, {
  int? id,
  bool? caseonoff,
}) {
  final query = '''
UPDATE medications
SET turnedon = CASE WHEN $caseonoff THEN 1 ELSE 0 END
WHERE id = $id;
''';
  return database.rawQuery(query);
}

/// END UPDATETURNEDON

/// BEGIN INSERTREMINDER
Future performInsertReminder(
  Database database, {
  int? id,
  String? title,
  String? message,
  String? hour,
  String? minute,
}) {
  final query = '''
INSERT INTO medications (id, title, message, hour, minute)
VALUES ($id, $title, $message, $hour, $minute);
''';
  return database.rawQuery(query);
}

/// END INSERTREMINDER
