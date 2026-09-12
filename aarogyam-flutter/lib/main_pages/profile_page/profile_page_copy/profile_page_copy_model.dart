import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/widgets/user_info/user_info_widget.dart';
import 'dart:math';
import 'dart:ui';
import 'profile_page_copy_widget.dart' show ProfilePageCopyWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProfilePageCopyModel extends FlutterFlowModel<ProfilePageCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for UserInfo component.
  late UserInfoModel userInfoModel;

  @override
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  @override
  final Map<String, DebugDataField> debugBackendQueries = {};
  @override
  final Map<String, FlutterFlowModel> widgetBuilderComponents = {};
  @override
  void initState(BuildContext context) {
    userInfoModel = createModel(context, () => UserInfoModel());

    debugLogWidgetClass(this);
  }

  @override
  void dispose() {
    userInfoModel.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
        generatorVariables: debugGeneratorVariables,
        backendQueries: debugBackendQueries,
        componentStates: {
          'userInfoModel (UserInfo)': userInfoModel.toWidgetClassDebugData(),
          ...widgetBuilderComponents.map(
            (key, value) => MapEntry(
              key,
              value.toWidgetClassDebugData(),
            ),
          ),
        }.withoutNulls,
        link:
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=ProfilePageCopy',
        searchReference:
            'reference=Og9Qcm9maWxlUGFnZUNvcHlQAVoPUHJvZmlsZVBhZ2VDb3B5',
        widgetClassName: 'ProfilePageCopy',
      );
}
