import '/flutter_flow/flutter_flow_util.dart';
import 'response_page_widget.dart' show ResponsePageWidget;

class ResponsePageModel extends FlutterFlowModel<ResponsePageWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - extractMedicationDetails] action in Button widget.
  dynamic _medicationjson;
  set medicationjson(dynamic value) {
    _medicationjson = value;
    debugLogWidgetClass(this);
  }

  dynamic get medicationjson => _medicationjson;  @override
  void initState(BuildContext context) {
    debugLogWidgetClass(this);
  }
  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
