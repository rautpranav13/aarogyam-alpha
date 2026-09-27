import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'report_sanner_widget.dart' show ReportSannerWidget;

class ReportSannerModel extends BaseModel<ReportSannerWidget> {
  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl = '';
  String? imageBase64;

  bool isPiiMaskingActive = true;
  String selectedLanguage = 'hi';
  bool isLoading = false;
  List<dynamic> extractedMedications = [];

  // Legacy fields for backward compatibility
  ApiCallResponse? imageapiResponseprescription;
  ApiCallResponse? imageapiResponseinsights;
  ApiCallResponse? imageapiResponseUserQ;
  String? responseWithoutHtml;
  String? ttsaudioPath;

  @override
  void initState(BuildContext context) {}
}
