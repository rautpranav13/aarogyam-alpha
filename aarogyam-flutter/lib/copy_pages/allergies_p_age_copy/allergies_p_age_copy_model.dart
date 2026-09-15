import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'allergies_p_age_copy_widget.dart' show AllergiesPAgeCopyWidget;
import 'package:expandable/expandable.dart';

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
  String? Function(BuildContext, String?)? textControllerValidator;  @override
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
    super.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
