import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/reminder_empty/reminder_empty_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reminder_list_collapsed_model.dart';
export 'reminder_list_collapsed_model.dart';

class ReminderListCollapsedWidget extends StatefulWidget {
  const ReminderListCollapsedWidget({super.key});

  @override
  State<ReminderListCollapsedWidget> createState() =>
      _ReminderListCollapsedWidgetState();
}

class _ReminderListCollapsedWidgetState
    extends State<ReminderListCollapsedWidget> with RouteAware {
  late ReminderListCollapsedModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReminderListCollapsedModel());
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
    if (mounted) {
      setState(() => _model.isRouteVisible = true);
      debugLogWidgetClass(_model);
    }
  }

  @override
  void didPush() {
    if (mounted) {
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

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Daily Reminders',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  font: GoogleFonts.poppins(),
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  fontSize: 22.0,
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
            if (listViewReadmedicationsRowList.isEmpty) {
              return const Center(
                child: ReminderEmptyWidget(),
              );
            }
            _model.debugBackendQueries[
                    'listViewReadmedicationsRowList_ListView_ls054ybm${listViewReadmedicationsRowList.length > 100 ? ' (first 100)' : ''}'] =
                debugSerializeParam(
              listViewReadmedicationsRowList.take(100),
              ParamType.SqliteRow,
              isList: true,
              link:
                  'https://app.flutterflow.io/project/health-literacy-c97mzb?tab=uiBuilder&page=ReminderListCollapsed',
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
                return Container(
                  decoration: const BoxDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 36.0,
                              child: VerticalDivider(
                                thickness: 4.0,
                                color: FlutterFlowTheme.of(context).secondary,
                              ),
                            ),
                            Text(
                              valueOrDefault<String>(
                                listViewReadmedicationsRow.title,
                                'Medicines',
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
                          ].divide(const SizedBox(width: 4.0)),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              Icons.timer,
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              size: 24.0,
                            ),
                            Text(
                              valueOrDefault<String>(
                                '${listViewReadmedicationsRow.hour} ${listViewReadmedicationsRow.minute}',
                                'HH:MM',
                              ),
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
                          ].divide(const SizedBox(width: 2.0)),
                        ),
                      ],
                    ),
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
