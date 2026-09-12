import '/core/base_model.dart';
import 'auth_login_widget.dart' show AuthLoginWidget;
import 'package:flutter/material.dart';

class AuthLoginModel extends BaseModel<AuthLoginWidget> {
  // State fields
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  bool passwordVisibility = false;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    emailAddressTextController ??= TextEditingController();
    emailAddressFocusNode ??= FocusNode();
    passwordTextController ??= TextEditingController();
    passwordFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
    super.dispose();
  }
}
