import '/core/base_model.dart';
import 'package:flutter/material.dart';
import 'blister_verifier_widget.dart' show BlisterVerifierWidget;

class BlisterVerifierModel extends BaseModel<BlisterVerifierWidget> {
  String? imagePath;
  String? imageBase64;
  String? rawOcrText;
  bool isScanning = false;

  @override
  void initState(BuildContext context) {}
}
