export 'package:flutter/foundation.dart' show debugPrint;
// flutter_flow_util.dart — compatibility shim.
//
// The original flutter_flow/ directory was removed during the ST-1
// modernisation step. This file provides compatibility for all remaining
// code that still imports from here, mapping to new pure-Flutter equivalents.
//
// New code should import from '/core/core.dart' directly.

// ignore_for_file: unused_element, unused_import, duplicate_ignore

// ---------------------------------------------------------------------------
// Exports (must come before any declarations)
// ---------------------------------------------------------------------------
export 'dart:typed_data' show Uint8List;
export '/core/core.dart';
export 'package:flutter/material.dart';
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:go_router/go_router.dart';
export '/core/router/app_router.dart'
    show
        GoRouterExtensions,
        NavigationExtensions,
        GoRouterLocationExtension,
        AppStateNotifier,
        RootPageContext,
        routeObserver,
        appNavigatorKey;

// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '/app_state.dart';
import '/core/base_model.dart';
import '/core/debug/debug_types.dart';
import '/core/types/uploaded_file.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_animations.dart' show AnimationInfo;
import '/flutter_flow/upload_data.dart' show selectMedia, SelectedMedia, selectMediaWithSourceBottomSheet;


// ---------------------------------------------------------------------------
// createModel — FF helper to instantiate and initialize a model
// ---------------------------------------------------------------------------
T createModel<T extends BaseModel>(BuildContext context, T Function() creator) {
  final model = creator();
  model.init(context);
  return model;
}

// ---------------------------------------------------------------------------
// safeSetState — FF helper that calls setState only if mounted
// ---------------------------------------------------------------------------
extension SafeSetStateExtension on State {
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}

// ---------------------------------------------------------------------------
// FFLocalizations — shim that returns the key unchanged.
// Production i18n is handled via ARB / AppLocalizations.
// ---------------------------------------------------------------------------
class FFLocalizations {
  FFLocalizations._(this._locale);
  final Locale _locale;

  static FFLocalizations of(BuildContext context) =>
      FFLocalizations._(Localizations.localeOf(context));

  static Future<void> initialize() async {}
  static Locale? getStoredLocale() => null;
  static Future<void> storeLocale(String language) async {}

  Locale get locale => _locale;

  String getText(String key) => key;
  String getVariableText({String? enText = '', String? hiText, String? mrText}) {
    final code = _locale.languageCode;
    if (code == 'hi' && hiText != null) return hiText;
    if (code == 'mr' && mrText != null) return mrText;
    return enText ?? '';
  }
}

Locale createLocale(String language) => Locale(language);

// ---------------------------------------------------------------------------
// DebugModalRoute — delegates to real ModalRoute.of for routeObserver.subscribe
// ---------------------------------------------------------------------------
class DebugModalRoute {
  static ModalRoute? of(BuildContext context) => ModalRoute.of(context);
}


// ---------------------------------------------------------------------------
// wrapWithModel — wraps a child widget, passing through as-is
// ---------------------------------------------------------------------------
Widget wrapWithModel<T extends BaseModel>({
  required T model,
  required VoidCallback updateCallback,
  required Widget child,
  bool updateOnChange = false,
}) {
  if (updateOnChange) {
    model.addListener(updateCallback);
  }
  return child;
}

// ---------------------------------------------------------------------------
// divide() — FF helper for ListView dividers
// ---------------------------------------------------------------------------
extension ListDivideExtension<T extends Widget> on Iterable<T> {
  List<Widget> divide(Widget t) {
    final result = <Widget>[];
    for (final widget in this) {
      if (result.isNotEmpty) result.add(t);
      result.add(widget);
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// TextStyle.override — FF extension for easy text style customization
// ---------------------------------------------------------------------------
extension TextStyleOverride on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    bool useGoogleFonts = false,
  }) {
    final base = font ?? this;
    return base.copyWith(
      fontFamily: fontFamily ?? base.fontFamily,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
      shadows: shadows,
    );
  }
}

// ---------------------------------------------------------------------------
// FFAppState shim — returns the AppState singleton
// ---------------------------------------------------------------------------
// ignore: non_constant_identifier_names
AppState FFAppState() => AppState();

// ---------------------------------------------------------------------------
// FFButtonOptions / FFButtonWidget
// ---------------------------------------------------------------------------
class FFButtonOptions {
  const FFButtonOptions({
    this.width,
    this.height,
    this.padding,
    this.iconPadding,
    this.color,
    this.textStyle,
    this.elevation,
    this.borderSide,
    this.borderRadius,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconColor,
    this.iconSize,
    this.iconAlignment,
    this.hoverColor,
    this.hoverTextColor,
    this.hoverBorderSide,
  });
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? iconPadding;
  final Color? color;
  final TextStyle? textStyle;
  final double? elevation;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? splashColor;
  final Color? iconColor;
  final double? iconSize;
  final dynamic iconAlignment;
  final Color? hoverColor;
  final Color? hoverTextColor;
  final BorderSide? hoverBorderSide;
}

class FFButtonWidget extends StatelessWidget {
  const FFButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    required this.options,
    this.icon,
    this.iconData,
    this.showLoadingIndicator = true,
  });
  final VoidCallback? onPressed;
  final String text;
  final FFButtonOptions options;
  final Widget? icon;
  final IconData? iconData;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    Widget label = Text(text, style: options.textStyle);
    if (icon != null || iconData != null) {
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? Icon(iconData, size: options.iconSize ?? 20, color: options.iconColor),
          const SizedBox(width: 8),
          Text(text, style: options.textStyle),
        ],
      );
    }
    return SizedBox(
      width: options.width,
      height: options.height ?? 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: options.color,
          elevation: options.elevation,
          padding: options.padding,
          shape: options.borderRadius != null
              ? RoundedRectangleBorder(
                  borderRadius: options.borderRadius!,
                  side: options.borderSide ?? BorderSide.none,
                )
              : null,
          disabledBackgroundColor: options.disabledColor,
          disabledForegroundColor: options.disabledTextColor,
        ),
        child: label,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// valueOrDefault — returns value if non-null/non-empty, else defaultValue
// ---------------------------------------------------------------------------
T valueOrDefault<T>(T? value, T defaultValue) =>
    (value is String && (value as String).isEmpty) || value == null
        ? defaultValue
        : value;

// ---------------------------------------------------------------------------
// DateTime.secondsSinceEpoch
// ---------------------------------------------------------------------------
extension DateTimeExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;
}

// ---------------------------------------------------------------------------
// Permission constants
// ---------------------------------------------------------------------------
const Permission notificationsPermission = Permission.notification;
const Permission microphonePermission = Permission.microphone;

// ---------------------------------------------------------------------------
// FlutterFlowDynamicModels — dynamic sub-model collection
// ---------------------------------------------------------------------------
class FlutterFlowDynamicModels<T extends BaseModel> {
  FlutterFlowDynamicModels(this._creator);
  final T Function() _creator;
  final Map<String, T> _models = {};

  T getModel(String uid, int index) =>
      _models.putIfAbsent(uid, _creator);

  T? get(String uid) => _models[uid];

  void dispose() {
    for (final m in _models.values) {
      m.dispose();
    }
    _models.clear();
  }
}

// ---------------------------------------------------------------------------
// validateFileFormat — stub
// ---------------------------------------------------------------------------
bool validateFileFormat(String filePath, BuildContext context) => true;

// ---------------------------------------------------------------------------
// animateOnActionTrigger — flutter_animate stub extension
// ---------------------------------------------------------------------------
extension AnimateOnActionTriggerExtension on Widget {
  Widget animateOnActionTrigger(
    AnimationInfo? info, {
    bool hasBeenTriggered = false,
  }) =>
      this;
}

// ---------------------------------------------------------------------------
// setDarkModeSetting — theme mode toggle
// ---------------------------------------------------------------------------
Future<void> setDarkModeSetting(BuildContext context, ThemeMode mode) async {
  AppTheme.saveThemeMode(mode);
}

// ---------------------------------------------------------------------------
// startAudioRecording / stopAudioRecording — stubs for legacy profile page
// ---------------------------------------------------------------------------
Future<void> startAudioRecording(
  BuildContext context, {
  dynamic audioRecorder,
  dynamic onRecordingComplete,
  String? audioName,
}) async {}

Future<String?> stopAudioRecording({
  dynamic audioRecorder,
  String? audioName,
  void Function(String?, Uint8List?)? onRecordingComplete,
}) async {
  onRecordingComplete?.call(null, null);
  return null;
}

// ---------------------------------------------------------------------------
// addToEnd / addToStart — chainable list append/prepend
// ---------------------------------------------------------------------------
extension ListAddExtension<T> on List<T> {
  List<T> addToEnd(T element) {
    add(element);
    return this;
  }

  List<T> addToStart(T element) {
    insert(0, element);
    return this;
  }
}


// ---------------------------------------------------------------------------
// asValidator — extension on Function? to use as a FormFieldValidator
// ---------------------------------------------------------------------------
typedef ValidatorFn<T> = String? Function(T?);

extension FunctionValidatorExtension<T> on ValidatorFn<T>? {
  ValidatorFn<T>? asValidator(BuildContext context) => this;
}

// Also on generic Function for FF-generated code that uses `Function?`
extension GenericFunctionValidatorExtension on Function {
  String? Function(String?)? asValidator(BuildContext context) =>
      (value) => this(value) as String?;
}

// ---------------------------------------------------------------------------
// toDynamicWidgetClassDebugData — stub for FlutterFlowDynamicModels
// ---------------------------------------------------------------------------
extension FlutterFlowDynamicModelsDebugExtension<T extends BaseModel>
    on FlutterFlowDynamicModels<T> {
  Map<String, dynamic> toDynamicWidgetClassDebugData() => {};
}


// ---------------------------------------------------------------------------
// serializeParam — stub for FF route serialization
// ---------------------------------------------------------------------------
String? serializeParam(dynamic param, dynamic paramType, {bool isList = false}) =>
    param?.toString();

