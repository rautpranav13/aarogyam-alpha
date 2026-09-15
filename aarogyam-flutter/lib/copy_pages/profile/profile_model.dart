import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'profile_widget.dart' show ProfileWidget;
import 'package:record/record.dart';

class ProfileModel extends FlutterFlowModel<ProfileWidget> {
  ///  State fields for stateful widgets in this page.

  AudioRecorder? audioRecorder;
  String? recordedAudio;
  Uint8List? recordedFileBytes;
  // Stores action output result for [Custom Action - downloadRecordedAudio] action in IconButton widget.
  String? _recordedFilePath;
  set recordedFilePath(String? value) {
    _recordedFilePath = value;
    debugLogWidgetClass(this);
  }

  String? get recordedFilePath => _recordedFilePath;

  // Stores action output result for [Custom Action - transcribeAudio] action in IconButton widget.
  String? _rspeechText;
  set rspeechText(String? value) {
    _rspeechText = value;
    debugLogWidgetClass(this);
  }

  String? get rspeechText => _rspeechText;

  // Stores action output result for [Custom Action - extractTextFromHTML] action in IconButton widget.
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

  String? get ttsaudioPath => _ttsaudioPath;

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

  ApiCallResponse? get imageapiResponseinsights => _imageapiResponseinsights;  @override
  void initState(BuildContext context) {
    debugLogWidgetClass(this);
  }
  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
