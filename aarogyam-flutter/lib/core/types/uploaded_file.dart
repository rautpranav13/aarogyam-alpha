import 'dart:typed_data';

/// Wraps an uploaded file's bytes and name.
/// Migrated from flutter_flow/uploaded_file.dart.
class FFUploadedFile {
  const FFUploadedFile({
    this.name,
    this.bytes,
    this.height,
    this.width,
    this.blurHash,
  });

  final String? name;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final String? blurHash;

  @override
  String toString() =>
      'FFUploadedFile(name: $name, bytes: ${bytes?.length} bytes)';

  @override
  bool operator ==(Object other) =>
      other is FFUploadedFile &&
      other.name == name &&
      other.bytes == bytes;

  @override
  int get hashCode => Object.hash(name, bytes);
}
