// permissions_util.dart — compatibility shim.
// Wraps permission_handler for FF-style permission helpers.

import 'package:permission_handler/permission_handler.dart';

export 'package:permission_handler/permission_handler.dart';

/// Request a permission and return whether it was granted.
Future<bool> requestPermission(Permission permission) async {
  final status = await permission.request();
  return status.isGranted;
}

/// Check if a permission is granted.
Future<bool> checkPermission(Permission permission) async {
  return (await permission.status).isGranted;
}
