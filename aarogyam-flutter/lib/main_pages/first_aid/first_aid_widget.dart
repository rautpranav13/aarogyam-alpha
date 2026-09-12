import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'first_aid_model.dart';
export 'first_aid_model.dart';

class FirstAidWidget extends StatefulWidget {
  const FirstAidWidget({super.key});

  @override
  State<FirstAidWidget> createState() => _FirstAidWidgetState();
}

class _FirstAidWidgetState extends State<FirstAidWidget> with RouteAware {
  late FirstAidModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FirstAidModel());
  }

  @override
  void dispose() {
    _model.dispose();

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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            FFLocalizations.of(context).getText(
              '22sm0hyg' /* First Aid */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.outfit(),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: const custom_widgets.HtmlContentWidget(
                width: double.infinity,
                height: double.infinity,
                htmlContent:
                    '<body>\\n<h2 style=\'color: blue;\'>Prescribed Medications<h2>\\n<ul>\\n  <li><b>Paracetamol (500 mg)<b>: Take 1 tablet <b>twice a day</b> for <b>5 days</b>.</li>\\n  <li><b>Cefpodoxime (200 mg)</b>: Take 1 tablet <b>three times a day</b> for <b>7 days</b>.</li>\\n  <li><b>Ranitidine (150 mg)</b>: Take 1 tablet <b>before meals</b> for <b>3 days</b>.</li>\\n  <li><b>Multivitamin Syrup</b>: 5 mL <b>once daily</b> for <b>10 days</b>.</li>\\n</ul>\\n<h2 style=\'color: blue;\'>Additional Notes</h2>\\n<p>Drink plenty of water and avoid spicy foods during the course of medication.</p>\\n</body>',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
