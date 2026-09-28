import '/core/base_model.dart';
import 'package:flutter/material.dart';
import 'dadi_ma_widget.dart' show DadiMaWidget;

class DadiMaModel extends BaseModel<DadiMaWidget> {
  final FocusNode unfocusNode = FocusNode();
  TextEditingController? textController;
  FocusNode? textFieldFocusNode;
  int selectedTabIndex = 0;
  String selectedCategoryFilter = '';

  @override
  void initState(BuildContext context) {
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    textController?.dispose();
    textFieldFocusNode?.dispose();
  }
}
