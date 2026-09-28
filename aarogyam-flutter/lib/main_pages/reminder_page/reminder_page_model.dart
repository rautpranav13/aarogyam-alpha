import '/core/base_model.dart';
import 'package:flutter/material.dart';
import 'reminder_page_widget.dart' show ReminderPageWidget;

class ReminderPageModel extends BaseModel<ReminderPageWidget> {
  int selectedTabIndex = 0;

  @override
  void initState(BuildContext context) {}
}
