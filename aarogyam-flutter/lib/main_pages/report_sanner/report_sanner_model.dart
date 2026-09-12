import '/backend/api_requests/api_calls.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart' hide uploadData;
import 'dart:math';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'report_sanner_widget.dart' show ReportSannerWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

  String? get ttsaudioPath => _ttsaudioPath;

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
        widgetParameters: {
          'filepath': debugSerializeParam(
            widget?.filepath,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReportSanner',
            searchReference:
                'reference=ShoKEgoIZmlsZXBhdGgSBmRoenVxeXIECAMgAVABWghmaWxlcGF0aA==',
            name: 'String',
            nullable: true,
          )
        }.withoutNulls,
        actionOutputs: {
          'imageapiResponseprescription': debugSerializeParam(
            imageapiResponseprescription,
            ParamType.ApiResponse,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReportSanner',
            name: 'ApiCallResponse',
            nullable: true,
          ),
          'imageapiResponseinsights': debugSerializeParam(
            imageapiResponseinsights,
            ParamType.ApiResponse,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReportSanner',
            name: 'ApiCallResponse',
            nullable: true,
          ),
          'imageapiResponseUserQ': debugSerializeParam(
            imageapiResponseUserQ,
            ParamType.ApiResponse,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReportSanner',
            name: 'ApiCallResponse',
            nullable: true,
          ),
          'responseWithoutHtml': debugSerializeParam(
            responseWithoutHtml,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReportSanner',
            name: 'String',
            nullable: true,
          ),
          'ttsaudioPath': debugSerializeParam(
            ttsaudioPath,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReportSanner',
            name: 'String',
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=ReportSanner',
        searchReference: 'reference=OgxSZXBvcnRTYW5uZXJQAVoMUmVwb3J0U2FubmVy',
        widgetClassName: 'ReportSanner',
      );
}
