import '/core/base_model.dart';
import 'package:flutter/material.dart';
import 'report_sanner_widget.dart' show ReportSannerWidget;

class ReportSannerModel extends BaseModel<ReportSannerWidget> {
  String? imagePath;
  String? imageBase64;
  String? rawOcrText;
  bool isOcrProcessing = false;
  bool isDigitizing = false;
  String selectedLanguage = 'hi';
  bool piiMaskingEnabled = true;

  @override
  void initState(BuildContext context) {}
}
