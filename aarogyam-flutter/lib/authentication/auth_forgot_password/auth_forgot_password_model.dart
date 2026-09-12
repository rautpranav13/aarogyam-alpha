import '/core/base_model.dart';
import 'auth_forgot_password_widget.dart' show AuthForgotPasswordWidget;
import 'package:flutter/material.dart';

class AuthForgotPasswordModel extends BaseModel<AuthForgotPasswordWidget> {
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;

  @override
  void initState(BuildContext context) {
    emailAddressTextController ??= TextEditingController();
    emailAddressFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
    super.dispose();
  }
}
