import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dbpageee_model.dart';
export 'dbpageee_model.dart';

class DbpageeeWidget extends StatefulWidget {
  const DbpageeeWidget({super.key});

  @override
  State<DbpageeeWidget> createState() => _DbpageeeWidgetState();
}

class _DbpageeeWidgetState extends State<DbpageeeWidget> with RouteAware {
  late DbpageeeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DbpageeeModel());
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
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: false,
          title: Text(
            FFLocalizations.of(context).getText(
              'u0p6bc8a' /* Page Title */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.poppins(),
                  color: FlutterFlowTheme.of(context).primaryText,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: FutureBuilder<List<ReadmedicationsRow>>(
            future: SQLiteManager.instance.readmedications(),
            builder: (context, snapshot) {
              // Customize what your widget looks like when it's loading.
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }
              final listViewReadmedicationsRowList = snapshot.data!;

              _model.debugBackendQueries[
                      'listViewReadmedicationsRowList_ListView_jfqr0618${listViewReadmedicationsRowList.length > 100 ? ' (first 100)' : ''}'] =
                  debugSerializeParam(
                listViewReadmedicationsRowList.take(100),
                ParamType.SqliteRow,
                isList: true,
                link:
                    'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=dbpageee',
                name: 'readmedications',
                nullable: false,
              );
              debugLogWidgetClass(_model);

              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: listViewReadmedicationsRowList.length,
                itemBuilder: (context, listViewIndex) {
                  final listViewReadmedicationsRow =
                      listViewReadmedicationsRowList[listViewIndex];
                  return Text(
                    valueOrDefault<String>(
                      listViewReadmedicationsRow.title,
                      'titlllleeee',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(),
                          letterSpacing: 0.0,
                        ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
