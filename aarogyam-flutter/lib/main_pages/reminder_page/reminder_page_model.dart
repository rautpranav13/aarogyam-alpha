import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/reminder_list_expanded/reminder_list_expanded_widget.dart';
import 'reminder_page_widget.dart' show ReminderPageWidget;

class ReminderPageModel extends BaseModel<ReminderPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for ReminderListExpanded component.
  late ReminderListExpandedModel reminderListExpandedModel;  @override
  void initState(BuildContext context) {
    reminderListExpandedModel =
        createModel(context, () => ReminderListExpandedModel());

    debugLogWidgetClass(this);
  }

  @override
  void dispose() {
    reminderListExpandedModel.dispose();
    super.dispose();
  }

  @override
  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();
}
