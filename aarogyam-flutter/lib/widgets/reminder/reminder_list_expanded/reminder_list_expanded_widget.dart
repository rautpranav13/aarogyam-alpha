import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/switch_remainder/switch_remainder_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reminder_list_expanded_model.dart';
export 'reminder_list_expanded_model.dart';

class ReminderListExpandedWidget extends StatefulWidget {
  const ReminderListExpandedWidget({super.key});

  @override
  State<ReminderListExpandedWidget> createState() =>
      _ReminderListExpandedWidgetState();
}

class _ReminderListExpandedWidgetState extends State<ReminderListExpandedWidget>
    with RouteAware {
  late ReminderListExpandedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReminderListExpandedModel());
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            FFLocalizations.of(context).getText(
              'bicnjszb' /* Reminders */,
            ),
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  fontSize: 24.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        FutureBuilder<List<ReadmedicationsRow>>(
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
                    'listViewReadmedicationsRowList_ListView_a3bkcda1${listViewReadmedicationsRowList.length > 100 ? ' (first 100)' : ''}'] =
                debugSerializeParam(
              listViewReadmedicationsRowList.take(100),
              ParamType.SqliteRow,
              isList: true,
              link:
                  'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReminderListExpanded',
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
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 70.0,
                            child: VerticalDivider(
                              thickness: 4.0,
                              color: FlutterFlowTheme.of(context).secondary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12.0, 0.0, 0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valueOrDefault<String>(
                                    listViewReadmedicationsRow.title,
                                    'Medicine',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.raleway(),
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                        fontSize: 20.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                Text(
                                  valueOrDefault<String>(
                                    listViewReadmedicationsRow.message,
                                    'Description',
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        color: const Color(0xFF808080),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      '${listViewReadmedicationsRow.hour} ${listViewReadmedicationsRow.minute}',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.manrope(),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    Icon(
                                      Icons.timer,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      size: 24.0,
                                    ),
                                  ].divide(const SizedBox(width: 2.0)),
                                ),
                              ].divide(const SizedBox(height: 4.0)),
                            ),
                          ),
                        ].divide(const SizedBox(width: 4.0)),
                      ),
                      wrapWithModel(
                        model: _model.switchRemainderModels.getModel(
                          listViewReadmedicationsRow.id!.toString(),
                          listViewIndex,
                        ),
                        updateCallback: () => safeSetState(() {}),
                        child: Builder(builder: (_) {
                          return DebugFlutterFlowModelContext(
                            rootModel: _model.rootModel,
                            child: SwitchRemainderWidget(
                              key: Key(
                                'Keyfi2_${listViewReadmedicationsRow.id!.toString()}',
                              ),
                              id: listViewReadmedicationsRow.id!,
                              title: listViewReadmedicationsRow.title!,
                              message: listViewReadmedicationsRow.message,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ]
          .divide(const SizedBox(height: 12.0))
          .addToStart(const SizedBox(height: 8.0))
          .addToEnd(const SizedBox(height: 8.0)),
    );
  }
}
