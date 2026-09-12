import '/flutter_flow/flutter_flow_checkbox_group.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'allergies_p_age_copy_widget.dart' show AllergiesPAgeCopyWidget;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AllergiesPAgeCopyModel extends FlutterFlowModel<AllergiesPAgeCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController1;

  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController1;
  List<String>? get checkboxGroupValues1 =>
      checkboxGroupValueController1?.value;
  set checkboxGroupValues1(List<String>? v) =>
      checkboxGroupValueController1?.value = v;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController2;

  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController2;
  List<String>? get checkboxGroupValues2 =>
      checkboxGroupValueController2?.value;
  set checkboxGroupValues2(List<String>? v) =>
      checkboxGroupValueController2?.value = v;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController3;

  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController3;
  List<String>? get checkboxGroupValues3 =>
      checkboxGroupValueController3?.value;
  set checkboxGroupValues3(List<String>? v) =>
      checkboxGroupValueController3?.value = v;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController4;

  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController4;
  List<String>? get checkboxGroupValues4 =>
      checkboxGroupValueController4?.value;
  set checkboxGroupValues4(List<String>? v) =>
      checkboxGroupValueController4?.value = v;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController5;

  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController5;
  List<String>? get checkboxGroupValues5 =>
      checkboxGroupValueController5?.value;
  set checkboxGroupValues5(List<String>? v) =>
      checkboxGroupValueController5?.value = v;

  // State field(s) for Expandable widget.
  late ExpandableController expandableExpandableController6;

  // State field(s) for CheckboxGroup widget.
  FormFieldController<List<String>>? checkboxGroupValueController6;
  List<String>? get checkboxGroupValues6 =>
      checkboxGroupValueController6?.value;
  set checkboxGroupValues6(List<String>? v) =>
      checkboxGroupValueController6?.value = v;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

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
  void dispose() {
    expandableExpandableController1.dispose();
    expandableExpandableController2.dispose();
    expandableExpandableController3.dispose();
    expandableExpandableController4.dispose();
    expandableExpandableController5.dispose();
    expandableExpandableController6.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() => WidgetClassDebugData(
        widgetStates: {
          'checkboxGroupValues1': debugSerializeParam(
            checkboxGroupValues1,
            ParamType.String,
            isList: true,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=AllergiesPAgeCopy',
            name: 'String',
            nullable: true,
          ),
          'checkboxGroupValues2': debugSerializeParam(
            checkboxGroupValues2,
            ParamType.String,
            isList: true,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=AllergiesPAgeCopy',
            name: 'String',
            nullable: true,
          ),
          'checkboxGroupValues3': debugSerializeParam(
            checkboxGroupValues3,
            ParamType.String,
            isList: true,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=AllergiesPAgeCopy',
            name: 'String',
            nullable: true,
          ),
          'checkboxGroupValues4': debugSerializeParam(
            checkboxGroupValues4,
            ParamType.String,
            isList: true,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=AllergiesPAgeCopy',
            name: 'String',
            nullable: true,
          ),
          'checkboxGroupValues5': debugSerializeParam(
            checkboxGroupValues5,
            ParamType.String,
            isList: true,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=AllergiesPAgeCopy',
            name: 'String',
            nullable: true,
          ),
          'checkboxGroupValues6': debugSerializeParam(
            checkboxGroupValues6,
            ParamType.String,
            isList: true,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=AllergiesPAgeCopy',
            name: 'String',
            nullable: true,
          ),
          'textFieldText': debugSerializeParam(
            textController?.text,
            ParamType.String,
            link:
                'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=AllergiesPAgeCopy',
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
            'https://app.flutterflow.io/project/health-literacy-c97mzb/tab=uiBuilder&page=AllergiesPAgeCopy',
        searchReference:
            'reference=OhFBbGxlcmdpZXNQQWdlQ29weVABWhFBbGxlcmdpZXNQQWdlQ29weQ==',
        widgetClassName: 'AllergiesPAgeCopy',
      );
}
