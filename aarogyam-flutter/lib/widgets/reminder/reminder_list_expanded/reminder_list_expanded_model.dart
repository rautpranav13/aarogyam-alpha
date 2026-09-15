import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/switch_remainder/switch_remainder_widget.dart';
import 'reminder_list_expanded_widget.dart' show ReminderListExpandedWidget;

class ReminderListExpandedModel
    extends FlutterFlowModel<ReminderListExpandedWidget> {
  ///  State fields for stateful widgets in this component.

  // Models for switchRemainder dynamic component.
  late FlutterFlowDynamicModels<SwitchRemainderModel> switchRemainderModels;  @override
  void initState(BuildContext context) {
    switchRemainderModels =
        FlutterFlowDynamicModels(() => SwitchRemainderModel());
  }

  @override
  void dispose() {
    switchRemainderModels.dispose();
    super.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
