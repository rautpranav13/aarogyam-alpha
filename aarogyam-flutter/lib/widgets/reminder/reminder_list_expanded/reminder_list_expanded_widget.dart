import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/reminder/reminder_empty/reminder_empty_widget.dart';
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
            'Daily Medication Reminders',
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
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0),
                child: ReminderEmptyWidget(),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: listViewReadmedicationsRowList.length,
              itemBuilder: (context, listViewIndex) {
                final listViewReadmedicationsRow =
                    listViewReadmedicationsRowList[listViewIndex];
                final formattedHour =
                    (listViewReadmedicationsRow.hour ?? '08').padLeft(2, '0');
                final formattedMinute =
                    (listViewReadmedicationsRow.minute ?? '00').padLeft(2, '0');

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
                                        fontSize: 18.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
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
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Icon(
                                      Icons.access_time_filled_rounded,
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      size: 16.0,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      '$formattedHour:$formattedMinute',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.manrope(),
                                            color: FlutterFlowTheme.of(context)
                                                .primaryBackground,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shield_outlined,
                                color: Colors.greenAccent, size: 22),
                            tooltip: 'Verify Pill Foil',
                            onPressed: () {
                              context.pushNamed('BlisterVerifier');
                            },
                          ),
                          wrapWithModel(
                            model: _model.switchRemainderModels.getModel(
                              listViewReadmedicationsRow.id!.toString(),
                              listViewIndex,
                            ),
                            updateCallback: () => safeSetState(() {}),
                            child: SwitchRemainderWidget(
                              key: Key(
                                'Keyfi2_${listViewReadmedicationsRow.id!.toString()}',
                              ),
                              id: listViewReadmedicationsRow.id!,
                              title: listViewReadmedicationsRow.title!,
                              message: listViewReadmedicationsRow.message,
                            ),
                          ),
                        ],
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
