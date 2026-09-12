// upload_data.dart — compatibility shim.
// Wraps image_picker and file_picker for FF-style file upload helpers.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '/core/types/uploaded_file.dart';

export '/core/types/uploaded_file.dart';

/// Media type filter
enum MediaType { image, video, any }

/// Dimensions helper
class MediaDimensions {
  const MediaDimensions({this.width, this.height});
  final double? width;
  final double? height;
}

/// SelectedMedia — represents a selected file before upload
class SelectedMedia {
  const SelectedMedia({
    required this.storagePath,
    required this.bytes,
    this.dimensions,
    this.blurHash,
  });
  final String storagePath;
  final Uint8List bytes;
  final MediaDimensions? dimensions;
  final String? blurHash;
}

/// Pick an image from gallery/camera, returning SelectedMedia list.
Future<List<SelectedMedia>?> selectMedia({
  BuildContext? context,
  bool isVideo = false,
  MediaType mediaType = MediaType.image,
  bool multiImage = false,
  String? storageFolderPath,
  bool allowPhoto = true,
  bool allowVideo = false,
  bool includeDimensions = false,
  bool includeBlurHash = false,
}) async {
  final picker = ImagePicker();
  final folder = storageFolderPath ?? 'uploads';
  if (multiImage) {
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return null;
    return Future.wait(files.map((f) async {
      final bytes = await f.readAsBytes();
      return SelectedMedia(storagePath: '$folder/${f.name}', bytes: bytes);
    }));
  } else {
    final file = isVideo || allowVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return [SelectedMedia(storagePath: '$folder/${file.name}', bytes: bytes)];
  }
}

/// selectMediaWithSourceBottomSheet — shows bottom sheet to choose source
Future<List<SelectedMedia>?> selectMediaWithSourceBottomSheet({
  BuildContext? context,
  bool isVideo = false,
  String? storageFolderPath,
  bool allowPhoto = true,
  bool allowVideo = false,
}) async {
  return selectMedia(
    context: context,
    isVideo: isVideo,
    storageFolderPath: storageFolderPath,
    allowPhoto: allowPhoto,
    allowVideo: allowVideo,
  );
}

/// Pick multiple files.
Future<List<FFUploadedFile>?> selectFiles({
  BuildContext? context,
  String? storageFolderPath,
  bool multiFile = false,
  List<String>? allowedExtensions,
}) async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: multiFile,
    type: allowedExtensions != null ? FileType.custom : FileType.any,
    allowedExtensions: allowedExtensions,
    withData: true,
  );
  if (result == null) return null;
  return result.files
      .map((f) => FFUploadedFile(
            name: f.name,
            bytes: f.bytes ?? Uint8List(0),
          ))
      .toList();
}

/// Upload stub — returns empty string.
Future<String> uploadData(
  String storagePath,
  Uint8List data,
) async =>
    '';
