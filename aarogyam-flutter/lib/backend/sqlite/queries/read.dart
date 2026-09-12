import '/backend/sqlite/queries/sqlite_row.dart';
import 'package:sqflite/sqflite.dart';

Future<List<T>> _readQuery<T>(
  Database database,
  String query,
  T Function(Map<String, dynamic>) create,
) =>
    database.rawQuery(query).then((r) => r.map((e) => create(e)).toList());

/// BEGIN READMEDICATIONS
Future<List<ReadmedicationsRow>> performReadmedications(
  Database database,
) {
  const query = '''
SELECT * FROM medications;
''';
  return _readQuery(database, query, (d) => ReadmedicationsRow(d));
}

class ReadmedicationsRow extends SqliteRow {
  ReadmedicationsRow(super.data);

  int? get id => data['id'] as int?;
  String? get title => data['title'] as String?;
  String? get message => data['message'] as String?;
  String? get hour => data['hour'] as String?;
  String? get minute => data['minute'] as String?;
  int get turnedon => data['turnedon'] as int;
}

/// END READMEDICATIONS
