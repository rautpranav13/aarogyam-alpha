import 'package:flutter/material.dart';
import '/core/base_model.dart';
import 'user_info_widget.dart' show UserInfoWidget;

class UserInfoModel extends BaseModel<UserInfoWidget> {
  String? dropDownValue;
  int? countControllerValue1; // age
  int? countControllerValue2; // height
  int? countControllerValue3; // weight

  @override
  void initState(BuildContext context) {}

}
