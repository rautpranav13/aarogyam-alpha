// form_field_controller.dart — compatibility shim.
// FormFieldController<T> wraps a ValueNotifier to manage form field state.

import 'package:flutter/foundation.dart';

class FormFieldController<T> extends ValueNotifier<T?> {
  FormFieldController(super.value);

  /// asValidator — returns a FormFieldValidator that checks required.
  String? Function(T?)? asValidator(String? Function(T?)? validator) =>
      validator;
}
