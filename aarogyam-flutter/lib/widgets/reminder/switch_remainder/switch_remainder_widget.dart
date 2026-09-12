import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/set_reminder/set_reminder_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'switch_remainder_model.dart';
export 'switch_remainder_model.dart';

class SwitchRemainderWidget extends StatefulWidget {
  const SwitchRemainderWidget({
    super.key,
    required this.id,
    required this.title,
    this.message,
  });

  final int? id;
  final String? title;
  final String? message;

  @override
  State<SwitchRemainderWidget> createState() => _SwitchRemainderWidgetState();
}

class _SwitchRemainderWidgetState extends State<SwitchRemainderWidget>
    with RouteAware {
  late SwitchRemainderModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SwitchRemainderModel());

    _model.switchValue = false;
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = DebugModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
    debugLogGlobalProperty(context);
  }

  @override
  void didPopNext() {
    if (mounted && DebugFlutterFlowModelContext.maybeOf(context) == null) {
      setState(() => _model.isRouteVisible = true);
      debugLogWidgetClass(_model);
    }
  }

  @override
  void didPush() {
    if (mounted && DebugFlutterFlowModelContext.maybeOf(context) == null) {
      setState(() => _model.isRouteVisible = true);
      debugLogWidgetClass(_model);
    }
  }

  @override
  void didPop() {
    _model.isRouteVisible = false;
  }

  @override
  void didPushNext() {
    _model.isRouteVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    DebugFlutterFlowModelContext.maybeOf(context)
        ?.parentModelCallback
        ?.call(_model);

    return Builder(
      builder: (context) => Switch.adaptive(
        value: _model.switchValue!,
        onChanged: (newValue) async {
          safeSetState(() => _model.switchValue = newValue);
          if (newValue) {
            await showDialog(
              context: context,
              builder: (dialogContext) {
                return Dialog(
                  elevation: 0,
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  alignment: const AlignmentDirectional(0.0, 0.0)
                      .resolve(Directionality.of(context)),
                  child: SetReminderWidget(
                    title: widget.title,
                    description: widget.message,
                  ),
                );
              },
            );
          }
        },
        activeColor: FlutterFlowTheme.of(context).primaryBackground,
        activeTrackColor: const Color(0xFF86D1C7),
        inactiveTrackColor: FlutterFlowTheme.of(context).secondaryText,
        inactiveThumbColor: FlutterFlowTheme.of(context).secondaryBackground,
      ),
    );
  }
}
