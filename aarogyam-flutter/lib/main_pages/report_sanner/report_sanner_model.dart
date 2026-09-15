import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'report_sanner_widget.dart' show ReportSannerWidget;

class ReportSannerModel extends FlutterFlowModel<ReportSannerWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading = false;
  FFUploadedFile uploadedLocalFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl = '';

  // Stores action output result for [Backend Call - API (processImageAPI)] action in Button widget.
  ApiCallResponse? _imageapiResponseprescription;
  set imageapiResponseprescription(ApiCallResponse? value) {
    _imageapiResponseprescription = value;
    debugLogWidgetClass(this);
  }

  ApiCallResponse? get imageapiResponseprescription =>
      _imageapiResponseprescription;

  // Stores action output result for [Backend Call - API (processImageAPI)] action in Button widget.
  ApiCallResponse? _imageapiResponseinsights;
  set imageapiResponseinsights(ApiCallResponse? value) {
    _imageapiResponseinsights = value;
    debugLogWidgetClass(this);
  }

  ApiCallResponse? get imageapiResponseinsights => _imageapiResponseinsights;

  // Stores action output result for [Backend Call - API (processImageAPI)] action in Button widget.
  ApiCallResponse? _imageapiResponseUserQ;
  set imageapiResponseUserQ(ApiCallResponse? value) {
    _imageapiResponseUserQ = value;
    debugLogWidgetClass(this);
  }

  ApiCallResponse? get imageapiResponseUserQ => _imageapiResponseUserQ;

  // Stores action output result for [Custom Action - extractTextFromHTMLFile] action in IconButton widget.
  String? _responseWithoutHtml;
  set responseWithoutHtml(String? value) {
    _responseWithoutHtml = value;
    debugLogWidgetClass(this);
  }

  String? get responseWithoutHtml => _responseWithoutHtml;

  // Stores action output result for [Custom Action - textAudio] action in IconButton widget.
  String? _ttsaudioPath;
  set ttsaudioPath(String? value) {
    _ttsaudioPath = value;
    debugLogWidgetClass(this);
  }

  String? get ttsaudioPath => _ttsaudioPath;  @override
  void initState(BuildContext context) {
    debugLogWidgetClass(this);
  }
  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
