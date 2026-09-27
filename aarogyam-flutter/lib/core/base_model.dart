import 'package:flutter/material.dart';
import '/core/debug/debug_types.dart';

/// Pure Flutter Base ViewModel extending ChangeNotifier for page and component state.
abstract class BaseModel<T extends StatefulWidget> extends ChangeNotifier {
  T? _widget;
  T? get widget => _widget;

  BuildContext? _context;
  BuildContext? get context => _context;

  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // State and Debug properties
  // ---------------------------------------------------------------------------
  bool isRouteVisible = false;
  final Map<String, DebugDataField> debugGeneratorVariables = {};
  final Map<String, DebugDataField> debugBackendQueries = {};
  final Map<String, BaseModel> widgetBuilderComponents = {};

  BaseModel get rootModel => this;

  WidgetClassDebugData toWidgetClassDebugData() =>
      const WidgetClassDebugData();

  /// Called once when the model is first associated with a widget.
  void initState(BuildContext context);

  /// Internal init — ensures [initState] is called exactly once.
  void init(BuildContext context) {
    _context = context;
    if (context.widget is T) _widget = context.widget as T;
    if (!_isInitialized) {
      initState(context);
      _isInitialized = true;
    }
  }

  /// Runs [fn] and calls [notifyListeners] to trigger a rebuild.
  void safeSetState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  /// Called by child components to signal a state update.
  void onUpdate() => notifyListeners();

  /// Dispose only if not already disposed — safe to call multiple times.
  void maybeDispose() {
    try {
      dispose();
    } catch (_) {}
  }

  @override
  void dispose() {
    _widget = null;
    super.dispose();
  }
}
