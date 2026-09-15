import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/firebase_storage/storage.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart' hide uploadData;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'report_sanner_model.dart';
export 'report_sanner_model.dart';

class ReportSannerWidget extends StatefulWidget {
  const ReportSannerWidget({
    super.key,
    required this.filepath,
  });

  final String? filepath;

  @override
  State<ReportSannerWidget> createState() => _ReportSannerWidgetState();
}

class _ReportSannerWidgetState extends State<ReportSannerWidget>
    with TickerProviderStateMixin, RouteAware {
  late ReportSannerModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReportSannerModel());

    animationsMap.addAll({
      'containerOnActionTriggerAnimation': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: true,
        effectsBuilder: () => [
          ShimmerEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 1130.0.ms,
            color: FlutterFlowTheme.of(context).primary,
            angle: 0.524,
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );
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
    context.read<AppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.0, -1.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(12.0, 30.0, 12.0, 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FlutterFlowIconButton(
                          borderRadius: 30.0,
                          buttonSize: 60.0,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          icon: Icon(
                            Icons.arrow_back,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            context.safePop();
                          },
                        ),
                      ].divide(const SizedBox(width: 6.0)),
                    ),
                  ),
                  Stack(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {},
                        child: Material(
                          color: Colors.transparent,
                          elevation: 8.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Container(
                            width: 365.0,
                            height: 275.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: Image.network(
                                  'https://images.unsplash.com/photo-1588345921523-c2dcdb7f1dcd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwyMXx8d2hpdGV8ZW58MHx8fHwxNzM3NTA4ODEyfDA&ixlib=rb-4.0.3&q=80&w=1080',
                                ).image,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FlutterFlowIconButton(
                                    borderRadius: 40.0,
                                    buttonSize: 80.0,
                                    fillColor: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      size: 32.0,
                                    ),
                                    showLoadingIndicator: true,
                                    onPressed: () async {
                                      final selectedMedia =
                                          await selectMediaWithSourceBottomSheet(
                                        context: context,
                                        allowPhoto: true,
                                      );
                                      if (selectedMedia != null &&
                                          selectedMedia.every((m) =>
                                              validateFileFormat(
                                                  m.storagePath, context))) {
                                        safeSetState(() =>
                                            _model.isDataUploading = true);
                                        var selectedUploadedFiles =
                                            <FFUploadedFile>[];

                                        var downloadUrls = <String>[];
                                        try {
                                          selectedUploadedFiles = selectedMedia
                                              .map((m) => FFUploadedFile(
                                                    name: m.storagePath
                                                        .split('/')
                                                        .last,
                                                    bytes: m.bytes,
                                                    height:
                                                        m.dimensions?.height,
                                                    width: m.dimensions?.width,
                                                    blurHash: m.blurHash,
                                                  ))
                                              .toList();

                                          downloadUrls = (await Future.wait(
                                            selectedMedia.map(
                                              (m) async => await uploadData(
                                                  m.storagePath, m.bytes),
                                            ),
                                          ))
                                              .where((u) => u != null)
                                              .map((u) => u!)
                                              .toList();
                                        } finally {
                                          _model.isDataUploading = false;
                                        }
                                        if (selectedUploadedFiles.length ==
                                                selectedMedia.length &&
                                            downloadUrls.length ==
                                                selectedMedia.length) {
                                          safeSetState(() {
                                            _model.uploadedLocalFile =
                                                selectedUploadedFiles.first;
                                            _model.uploadedFileUrl =
                                                downloadUrls.first;
                                          });
                                        } else {
                                          safeSetState(() {});
                                          return;
                                        }
                                      }
                                    },
                                  ),
                                ),
                                Text(
                                  FFLocalizations.of(context).getText(
                                    '7r6dgml9' /* Upload Image Here */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        fontSize: 16.0,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ].divide(const SizedBox(height: 16.0)),
                            ),
                          ),
                        ),
                      ),
                      if (valueOrDefault<bool>(
                        _model.uploadedFileUrl != '',
                        false,
                      ))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            _model.uploadedFileUrl,
                            width: 364.0,
                            height: 276.0,
                            fit: BoxFit.cover,
                            alignment: const Alignment(0.0, 0.0),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    FFLocalizations.of(context).getText(
                      'afqcxs9q' /* What are you looking for? */,
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(),
                          letterSpacing: 0.0,
                        ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FFButtonWidget(
                        onPressed: () async {
                          await Future.wait([
                            Future(() async {
                              _model.imageapiResponseprescription =
                                  await ProcessImageAPICall.call(
                                imageUrl: _model.uploadedFileUrl,
                                userQuery:
                                    'Only extract medicines from the prescription and return an accurate HTML table: <table><tr><th>Medicines</th><th>Dosage</th><th>Exact Time</th><th>Specific Instructions</th></tr><tr><td>Paracetamol</td><td>500mg</td><td>20:00</td><td>Take with food</td></tr></table>; calculate Exact Time in strict 24-hour format by yourself. (e.g., 08:30, 20:30), use standard values if unspecified, and ensure the table is correctly formatted in single line html for mobile-friendly display without extra characters or formatting errors. Do not add anything except table, your response should start with <table> and end with </table>.',
                              );

                              if (!context.mounted) return;
                              if ((_model.imageapiResponseprescription
                                      ?.succeeded ??
                                  true)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      (_model.imageapiResponseprescription
                                                  ?.statusCode ??
                                              200)
                                          .toString(),
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                                await actions.saveTXT(
                                  ProcessImageAPICall.imageAPIresponse(
                                    (_model.imageapiResponseprescription
                                            ?.jsonBody ??
                                        ''),
                                  ).toString(),
                                  'prescription.txt',
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      (_model.imageapiResponseprescription
                                                  ?.statusCode ??
                                              200)
                                          .toString(),
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                              }

                              safeSetState(() {});
                            }),
                            Future(() async {
                              FFAppState().whatClicked = 1;
                              FFAppState().update(() {});
                            }),
                          ]);
                          if (!context.mounted) return;
                          var confirmDialogResponse = await showDialog<bool>(
                                context: context,
                                builder: (alertDialogContext) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Prescription Scanned Successfully!'),
                                    content: const Text(
                                        'Do you want to schedule automatic reminders?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                            alertDialogContext, false),
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                            alertDialogContext, true),
                                        child: const Text('Sure'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;
                          if (confirmDialogResponse) {
                            await actions.updateMedicationsDatabase(
                              'prescription.txt',
                            );
                            await actions.immediateNotification(
                              0,
                              'Reminders are set. 🔔',
                              'You will be notified for the medications you enable in Home Page.',
                            );
                          } else {
                            await actions.immediateNotification(
                              0,
                              'Reminders are not set. 🔕',
                              'You will not be notified for any medication.',
                            );
                          }

                          safeSetState(() {});
                        },
                        text: FFLocalizations.of(context).getText(
                          'nbf28v7c' /* Prescription Analysis */,
                        ),
                        icon: FaIcon(
                          FontAwesomeIcons.pills,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          size: 20.0,
                        ),
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: valueOrDefault<Color>(
                            FFAppState().whatClicked == 1
                                ? FlutterFlowTheme.of(context).primaryBackground
                                : FlutterFlowTheme.of(context).primaryText,
                            FlutterFlowTheme.of(context).primaryText,
                          ),
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.manrope(),
                                color: valueOrDefault<Color>(
                                  FFAppState().whatClicked == 1
                                      ? FlutterFlowTheme.of(context).primaryText
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                letterSpacing: 0.0,
                              ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primaryText,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                          hoverColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          hoverBorderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primaryText,
                            width: 2.0,
                          ),
                          hoverTextColor:
                              FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      FFButtonWidget(
                        onPressed: () async {
                          await Future.wait([
                            Future(() async {
                              _model.imageapiResponseinsights =
                                  await ProcessImageAPICall.call(
                                imageUrl: _model.uploadedFileUrl,
                                userQuery:
                                    'Extract and summarize the key details present in the image with significant observations.',
                              );

                              if (!context.mounted) return;
                              if ((_model.imageapiResponseinsights?.succeeded ??
                                  true)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      (_model.imageapiResponseinsights
                                                  ?.statusCode ??
                                              200)
                                          .toString(),
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                                await actions.saveTXT(
                                  ProcessImageAPICall.imageAPIresponse(
                                    (_model.imageapiResponseinsights
                                            ?.jsonBody ??
                                        ''),
                                  ).toString(),
                                  'insights.txt',
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      (_model.imageapiResponseinsights
                                                  ?.statusCode ??
                                              200)
                                          .toString(),
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                              }

                              safeSetState(() {});
                            }),
                            Future(() async {
                              FFAppState().whatClicked = 2;
                              FFAppState().update(() {});
                              if (animationsMap[
                                      'containerOnActionTriggerAnimation'] !=
                                  null) {
                                animationsMap[
                                        'containerOnActionTriggerAnimation']!
                                    .controller
                                  ?..reset()
                                  ..repeat();
                              }
                            }),
                          ]);
                          if (animationsMap[
                                  'containerOnActionTriggerAnimation'] !=
                              null) {
                            animationsMap['containerOnActionTriggerAnimation']!
                                .controller
                                ?.reset();
                          }

                          FFAppState().update(() {});

                          safeSetState(() {});
                        },
                        text: FFLocalizations.of(context).getText(
                          '7m9cszhf' /* Report Insights */,
                        ),
                        icon: Icon(
                          Icons.document_scanner,
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          size: 20.0,
                        ),
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: valueOrDefault<Color>(
                            FFAppState().whatClicked == 2
                                ? FlutterFlowTheme.of(context).primaryBackground
                                : FlutterFlowTheme.of(context).primaryText,
                            FlutterFlowTheme.of(context).primaryText,
                          ),
                          textStyle: FlutterFlowTheme.of(context)
                              .titleSmall
                              .override(
                                font: GoogleFonts.manrope(),
                                color: valueOrDefault<Color>(
                                  FFAppState().whatClicked == 2
                                      ? FlutterFlowTheme.of(context).primaryText
                                      : FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                  FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                letterSpacing: 0.0,
                              ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primaryText,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(24.0),
                          hoverColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          hoverBorderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).primaryText,
                            width: 2.0,
                          ),
                          hoverTextColor:
                              FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                    ]
                        .divide(const SizedBox(width: 10.0))
                        .addToStart(const SizedBox(width: 12.0))
                        .addToEnd(const SizedBox(width: 12.0)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (valueOrDefault<bool>(
                        FFAppState().userTitle == '',
                        true,
                      ))
                        FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed('CustomQuery');
                          },
                          text: FFLocalizations.of(context).getText(
                            'he2h6ahn' /* Set your own query */,
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.pills,
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            size: 20.0,
                          ),
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: valueOrDefault<Color>(
                              FFAppState().whatClicked == 3
                                  ? FlutterFlowTheme.of(context)
                                      .primaryBackground
                                  : FlutterFlowTheme.of(context).primaryText,
                              FlutterFlowTheme.of(context).primaryText,
                            ),
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.manrope(),
                                  color: valueOrDefault<Color>(
                                    FFAppState().whatClicked == 3
                                        ? FlutterFlowTheme.of(context)
                                            .primaryText
                                        : FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                    FlutterFlowTheme.of(context)
                                        .primaryBackground,
                                  ),
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primaryText,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                            hoverColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            hoverBorderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primaryText,
                              width: 2.0,
                            ),
                            hoverTextColor:
                                FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                      if (FFAppState().userTitle != '')
                        FFButtonWidget(
                          onPressed: () async {
                            await Future.wait([
                              Future(() async {
                                _model.imageapiResponseUserQ =
                                    await ProcessImageAPICall.call(
                                  imageUrl: _model.uploadedFileUrl,
                                  userQuery: FFAppState().userQuery,
                                );

                                if (!context.mounted) return;
                                if ((_model.imageapiResponseUserQ?.succeeded ??
                                    true)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        (_model.imageapiResponseUserQ
                                                    ?.statusCode ??
                                                200)
                                            .toString(),
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                  await actions.saveTXT(
                                    ProcessImageAPICall.imageAPIresponse(
                                      (_model.imageapiResponseUserQ?.jsonBody ??
                                          ''),
                                    ).toString(),
                                    'insights.txt',
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        (_model.imageapiResponseUserQ
                                                    ?.statusCode ??
                                                200)
                                            .toString(),
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 4000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .secondary,
                                    ),
                                  );
                                }

                                safeSetState(() {});
                              }),
                              Future(() async {
                                FFAppState().whatClicked = 2;
                                FFAppState().update(() {});
                                if (animationsMap[
                                        'containerOnActionTriggerAnimation'] !=
                                    null) {
                                  animationsMap[
                                          'containerOnActionTriggerAnimation']!
                                      .controller
                                    ?..reset()
                                    ..repeat();
                                }
                              }),
                            ]);
                            if (animationsMap[
                                    'containerOnActionTriggerAnimation'] !=
                                null) {
                              animationsMap[
                                      'containerOnActionTriggerAnimation']!
                                  .controller
                                  ?.stop();
                            }

                            safeSetState(() {});
                          },
                          text: FFAppState().userTitle,
                          icon: Icon(
                            Icons.document_scanner,
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            size: 20.0,
                          ),
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primaryText,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.manrope(),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primaryText,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(24.0),
                            hoverColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            hoverBorderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primaryText,
                              width: 2.0,
                            ),
                            hoverTextColor:
                                FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                    ]
                        .divide(const SizedBox(width: 10.0))
                        .addToStart(const SizedBox(width: 12.0))
                        .addToEnd(const SizedBox(width: 12.0)),
                  ),
                  if (FFAppState().whatClicked != 0)
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                          ),
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                width: 365.0,
                                height: 500.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Visibility(
                                  visible: (FFAppState().whatClicked == 1) ||
                                      (FFAppState().whatClicked == 2) ||
                                      (FFAppState().whatClicked == 3),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: custom_widgets.HtmlWidget3(
                                      width: double.infinity,
                                      height: double.infinity,
                                      txtFileName: FFAppState().isTranslate
                                          ? 'translate.txt'
                                          : ((int? var1) {
                                              return var1 == 1
                                                  ? 'prescription.txt'
                                                  : var1 == 2
                                                      ? 'insights.txt'
                                                      : '';
                                            }(FFAppState().whatClicked)),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground,
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            24.0, 0.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: const AlignmentDirectional(
                                                  -1.0, 1.0),
                                              child: FlutterFlowIconButton(
                                                borderRadius: 25.0,
                                                buttonSize: 50.0,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                icon: const Icon(
                                                  Icons.volume_up,
                                                  color: Colors.white,
                                                  size: 24.0,
                                                ),
                                                onPressed: () async {
                                                  _model.responseWithoutHtml =
                                                      await actions
                                                          .extractTextFromHTMLFile(
                                                    (int var1) {
                                                      return var1 == 1
                                                          ? 'prescription.txt'
                                                          : var1 == 2
                                                              ? 'insights.txt'
                                                              : '';
                                                    }(FFAppState().whatClicked),
                                                  );
                                                  _model.ttsaudioPath =
                                                      await actions.textAudio(
                                                    dotenv.env['WATSON_TTS_API_KEY'] ?? '',
                                                    'https://api.eu-gb.text-to-speech.watson.cloud.ibm.com/instances/dc7f65b4-3f3b-464d-9d31-cfeefe0f6d3d',
                                                    _model.responseWithoutHtml!,
                                                    'speech.mp3',
                                                  );
                                                  await actions.playMusic(
                                                    _model.ttsaudioPath!,
                                                  );

                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                            Align(
                                              alignment: const AlignmentDirectional(
                                                  -1.0, 1.0),
                                              child: FlutterFlowIconButton(
                                                borderRadius: 25.0,
                                                buttonSize: 50.0,
                                                fillColor:
                                                    FlutterFlowTheme.of(context)
                                                        .primaryText,
                                                icon: const Icon(
                                                  Icons.translate_rounded,
                                                  color: Colors.white,
                                                  size: 24.0,
                                                ),
                                                onPressed: () async {
                                                  await actions
                                                      .translateHtmlFile(
                                                    (int? var1) {
                                                      return var1 == 1
                                                          ? 'prescription.txt'
                                                          : var1 == 2
                                                              ? 'insights.txt'
                                                              : '';
                                                    }(FFAppState().whatClicked),
                                                    'translate.txt',
                                                  );
                                                  FFAppState().isTranslate =
                                                      true;
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ].divide(const SizedBox(width: 16.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animateOnActionTrigger(
                          animationsMap['containerOnActionTriggerAnimation']!,
                        ),
                      ),
                    ),
                ]
                    .divide(const SizedBox(height: 30.0))
                    .addToEnd(const SizedBox(height: 30.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
