import '/core/base_model.dart';
import 'auth_create_widget.dart' show AuthCreateWidget;
import 'package:flutter/material.dart';

class AuthCreateModel extends BaseModel<AuthCreateWidget> {
  FocusNode? displayNameFocusNode;
  TextEditingController? displayNameTextController;

  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  bool passwordVisibility = false;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    displayNameTextController ??= TextEditingController();
    displayNameFocusNode ??= FocusNode();
    emailAddressTextController ??= TextEditingController();
    emailAddressFocusNode ??= FocusNode();
    passwordTextController ??= TextEditingController();
    passwordFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    displayNameFocusNode?.dispose();
    displayNameTextController?.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
    super.dispose();
  }
}
