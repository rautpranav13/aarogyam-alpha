import '/backend/api_requests/api_calls.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart' hide uploadData;
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/permissions_util.dart';
import 'profile_widget.dart' show ProfileWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  ApiCallResponse? get imageapiResponseinsights => _imageapiResponseinsights;

  @override
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  @override
  final Map<String, DebugDataField> debugBackendQueries = {};
  @override
  final Map<String, FlutterFlowModel> widgetBuilderComponents = {};
  @override
  void initState(BuildContext context) {
    debugLogWidgetClass(this);
  }

  @override
  void dispose() {}

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
        actionOutputs: {
          'recordedAudio': debugSerializeParam(
            recordedAudio,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=Profile',
            name: 'String',
            nullable: true,
          ),
          'recordedFilePath': debugSerializeParam(
            recordedFilePath,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=Profile',
            name: 'String',
            nullable: true,
          ),
          'rspeechText': debugSerializeParam(
            rspeechText,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=Profile',
            name: 'String',
            nullable: true,
          ),
          'responseWithoutHtml': debugSerializeParam(
            responseWithoutHtml,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=Profile',
            name: 'String',
            nullable: true,
          ),
          'ttsaudioPath': debugSerializeParam(
            ttsaudioPath,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=Profile',
            name: 'String',
            nullable: true,
          ),
          'imageapiResponseprescription': debugSerializeParam(
            imageapiResponseprescription,
            ParamType.ApiResponse,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=Profile',
            name: 'ApiCallResponse',
            nullable: true,
          ),
          'imageapiResponseinsights': debugSerializeParam(
            imageapiResponseinsights,
            ParamType.ApiResponse,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=Profile',
            name: 'ApiCallResponse',
            nullable: true,
          )
        },
        generatorVariables: debugGeneratorVariables,
        backendQueries: debugBackendQueries,
        componentStates: {
          ...widgetBuilderComponents.map(
            (key, value) => MapEntry(
              key,
              value.toWidgetClassDebugData(),
            ),
          ),
        }.withoutNulls,
        link:
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=Profile',
        searchReference: 'reference=OgdQcm9maWxlUAFaB1Byb2ZpbGU=',
        widgetClassName: 'Profile',
      );
}
