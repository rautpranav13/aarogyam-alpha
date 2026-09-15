import '/flutter_flow/flutter_flow_util.dart';
import 'custom_query_widget.dart' show CustomQueryWidget;

class CustomQueryModel extends FlutterFlowModel<CustomQueryWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for titleTextfield widget.
  FocusNode? titleTextfieldFocusNode;
  TextEditingController? titleTextfieldTextController;
  String? Function(BuildContext, String?)?
      titleTextfieldTextControllerValidator;
  // State field(s) for queryTextfield widget.
  FocusNode? queryTextfieldFocusNode;
  TextEditingController? queryTextfieldTextController;
  String? Function(BuildContext, String?)?
      queryTextfieldTextControllerValidator;  @override
  void initState(BuildContext context) {
    debugLogWidgetClass(this);
  }

  @override
  void dispose() {
    titleTextfieldFocusNode?.dispose();
    titleTextfieldTextController?.dispose();

    queryTextfieldFocusNode?.dispose();
    queryTextfieldTextController?.dispose();
    super.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
