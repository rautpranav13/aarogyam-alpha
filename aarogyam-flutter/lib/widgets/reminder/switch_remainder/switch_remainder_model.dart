import '/flutter_flow/flutter_flow_util.dart';
import 'switch_remainder_widget.dart' show SwitchRemainderWidget;

class SwitchRemainderModel extends BaseModel<SwitchRemainderWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Switch widget.
  bool? _switchValue;
  set switchValue(bool? value) {
    _switchValue = value;
    debugLogWidgetClass(this);
  }

  bool? get switchValue => _switchValue;  @override
  void initState(BuildContext context) {}
  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
