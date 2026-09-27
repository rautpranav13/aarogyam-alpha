import 'package:flutter/material.dart';
import '/core/base_model.dart';
import '/backend/api_requests/api_calls.dart';

class BlisterVerifierModel extends BaseModel {
  String? uploadedImageBase64;
  String? uploadedImageUrl;
  String expectedDrug = 'Metformin';
  String expectedStrength = '500mg';
  String selectedLanguage = 'hi';

  bool isLoading = false;
  ApiCallResponse? apiResult;
  bool? isVerified;
  String detectedText = '';
  String voiceAlert = '';
  String action = '';

  @override
  void initState(BuildContext context) {}
}
