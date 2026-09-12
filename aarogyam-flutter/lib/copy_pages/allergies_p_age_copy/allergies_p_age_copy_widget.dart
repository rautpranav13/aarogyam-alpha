import '/flutter_flow/flutter_flow_checkbox_group.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'allergies_p_age_copy_model.dart';
export 'allergies_p_age_copy_model.dart';

class AllergiesPAgeCopyWidget extends StatefulWidget {
  const AllergiesPAgeCopyWidget({super.key});

  @override
  State<AllergiesPAgeCopyWidget> createState() =>
      _AllergiesPAgeCopyWidgetState();
}

class _AllergiesPAgeCopyWidgetState extends State<AllergiesPAgeCopyWidget>
    with RouteAware {
  late AllergiesPAgeCopyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllergiesPAgeCopyModel());

    _model.expandableExpandableController1 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController2 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController3 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController4 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController5 =
        ExpandableController(initialExpanded: false);
    _model.expandableExpandableController6 =
        ExpandableController(initialExpanded: false);
    _model.textController ??= TextEditingController()
      ..addListener(() {
        debugLogWidgetClass(_model);
      });
    _model.textFieldFocusNode ??= FocusNode();
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
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 30.0, 12.0, 12.0),
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText(
                        'p3ero826' /* Allergies */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.manrope(),
                            fontSize: 20.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      FFLocalizations.of(context).getText(
                        '8xkno1py' /* Let us know what triggers your... */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.manrope(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                    child: Text(
                      FFLocalizations.of(context).getText(
                        'dggjq2m4' /* Select Your Allergies */,
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.manrope(),
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            color: const Color(0x00000000),
                            child: ExpandableNotifier(
                              controller:
                                  _model.expandableExpandableController1,
                              child: ExpandablePanel(
                                header: Text(
                                  FFLocalizations.of(context).getText(
                                    'v38f2nih' /* Food Allergies */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.outfit(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                collapsed: Text(
                                  FFLocalizations.of(context).getText(
                                    '32fnl9t7' /* [Selected Alleriges] */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                expanded: FlutterFlowCheckboxGroup(
                                  options: [
                                    FFLocalizations.of(context).getText(
                                      'lckcwbrq' /* Peanuts */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'ndhgw9gx' /* Tree nuts (e.g., almonds, waln... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'u8572t5m' /* Milk (lactose intolerance or d... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'zitjaeqn' /* Eggs */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      '9f3k3u8l' /* Shellfish (e.g., shrimp, crab,... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'ne3277lo' /* Fish (e.g., salmon, tuna) */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'mbso4yei' /* Soy */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'ezjzc1tx' /* Wheat (gluten intolerance or a... */,
                                    )
                                  ],
                                  onChanged: (val) => safeSetState(
                                      () => _model.checkboxGroupValues1 = val),
                                  controller:
                                      _model.checkboxGroupValueController1 ??=
                                          FormFieldController<List<String>>(
                                    [],
                                  )..addListener(() {
                                              debugLogWidgetClass(_model);
                                            }),
                                  activeColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  checkColor: Colors.white,
                                  checkboxBorderColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                  checkboxBorderRadius:
                                      BorderRadius.circular(4.0),
                                  initialized:
                                      _model.checkboxGroupValues1 != null,
                                ),
                                theme: const ExpandableThemeData(
                                  tapHeaderToExpand: true,
                                  tapBodyToExpand: true,
                                  tapBodyToCollapse: true,
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  hasIcon: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            color: const Color(0x00000000),
                            child: ExpandableNotifier(
                              controller:
                                  _model.expandableExpandableController2,
                              child: ExpandablePanel(
                                header: Text(
                                  FFLocalizations.of(context).getText(
                                    'e6jku5u6' /* Environmeental Allergies */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.outfit(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                collapsed: Text(
                                  FFLocalizations.of(context).getText(
                                    '3wtjyht2' /* [Selected Alleriges] */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                expanded: FlutterFlowCheckboxGroup(
                                  options: [
                                    FFLocalizations.of(context).getText(
                                      'pfja91d3' /* Pollen (grass, trees, or flowe... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      '155n6fyi' /* Dust mites */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'txv6vfqy' /* Mold spores */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'piih6ugj' /* Animal dander (cats, dogs, etc... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'ciqr4w5a' /* Cockroach droppings */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'ykbi4k03' /* Latex */,
                                    )
                                  ],
                                  onChanged: (val) => safeSetState(
                                      () => _model.checkboxGroupValues2 = val),
                                  controller:
                                      _model.checkboxGroupValueController2 ??=
                                          FormFieldController<List<String>>(
                                    [],
                                  )..addListener(() {
                                              debugLogWidgetClass(_model);
                                            }),
                                  activeColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  checkColor: Colors.white,
                                  checkboxBorderColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                  checkboxBorderRadius:
                                      BorderRadius.circular(4.0),
                                  initialized:
                                      _model.checkboxGroupValues2 != null,
                                ),
                                theme: const ExpandableThemeData(
                                  tapHeaderToExpand: true,
                                  tapBodyToExpand: true,
                                  tapBodyToCollapse: true,
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  hasIcon: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).tertiary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            color: const Color(0x00000000),
                            child: ExpandableNotifier(
                              controller:
                                  _model.expandableExpandableController3,
                              child: ExpandablePanel(
                                header: Text(
                                  FFLocalizations.of(context).getText(
                                    'o5ur31ps' /* Medication Allergies */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.outfit(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                collapsed: Text(
                                  FFLocalizations.of(context).getText(
                                    '19kwv7zf' /* [Selected Alleriges] */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                expanded: FlutterFlowCheckboxGroup(
                                  options: [
                                    FFLocalizations.of(context).getText(
                                      '65dmvxxs' /* Penicillin or other antibiotic... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      '24jpkobg' /* Aspirin */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'vbwfek1v' /* Ibuprofen */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'teg6j9xe' /* Sulfa drugs */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'qm8juium' /* Anesthesia (e.g., lidocaine) */,
                                    )
                                  ],
                                  onChanged: (val) => safeSetState(
                                      () => _model.checkboxGroupValues3 = val),
                                  controller:
                                      _model.checkboxGroupValueController3 ??=
                                          FormFieldController<List<String>>(
                                    [],
                                  )..addListener(() {
                                              debugLogWidgetClass(_model);
                                            }),
                                  activeColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  checkColor: Colors.white,
                                  checkboxBorderColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                  unselectedTextStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.manrope(),
                                            letterSpacing: 0.0,
                                          ),
                                  checkboxBorderRadius:
                                      BorderRadius.circular(4.0),
                                  initialized:
                                      _model.checkboxGroupValues3 != null,
                                ),
                                theme: const ExpandableThemeData(
                                  tapHeaderToExpand: true,
                                  tapBodyToExpand: true,
                                  tapBodyToCollapse: true,
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  hasIcon: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            color: const Color(0x00000000),
                            child: ExpandableNotifier(
                              controller:
                                  _model.expandableExpandableController4,
                              child: ExpandablePanel(
                                header: Text(
                                  FFLocalizations.of(context).getText(
                                    '8r8aq1p8' /* Insect Allergies */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .override(
                                        font: GoogleFonts.outfit(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                collapsed: Text(
                                  FFLocalizations.of(context).getText(
                                    '0ti7rae8' /* [Selected Alleriges] */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                expanded: FlutterFlowCheckboxGroup(
                                  options: [
                                    FFLocalizations.of(context).getText(
                                      'z0qtrvm8' /* Bee stings */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'bthlz2pr' /* Wasp stings */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'q727hoou' /* Mosquito bites */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'uaa5av8o' /* Fire ant bites */,
                                    )
                                  ],
                                  onChanged: (val) => safeSetState(
                                      () => _model.checkboxGroupValues4 = val),
                                  controller:
                                      _model.checkboxGroupValueController4 ??=
                                          FormFieldController<List<String>>(
                                    [],
                                  )..addListener(() {
                                              debugLogWidgetClass(_model);
                                            }),
                                  activeColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  checkColor: Colors.white,
                                  checkboxBorderColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                  unselectedTextStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.manrope(),
                                            letterSpacing: 0.0,
                                          ),
                                  checkboxBorderRadius:
                                      BorderRadius.circular(4.0),
                                  initialized:
                                      _model.checkboxGroupValues4 != null,
                                ),
                                theme: const ExpandableThemeData(
                                  tapHeaderToExpand: true,
                                  tapBodyToExpand: true,
                                  tapBodyToCollapse: true,
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  hasIcon: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            color: const Color(0x00000000),
                            child: ExpandableNotifier(
                              controller:
                                  _model.expandableExpandableController5,
                              child: ExpandablePanel(
                                header: Opacity(
                                  opacity: 0.7,
                                  child: Text(
                                    FFLocalizations.of(context).getText(
                                      'tisj05ed' /* Chemical and Skin Allergies */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                                collapsed: Text(
                                  FFLocalizations.of(context).getText(
                                    'ylxqtten' /* [Selected Alleriges] */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                expanded: FlutterFlowCheckboxGroup(
                                  options: [
                                    FFLocalizations.of(context).getText(
                                      'py7e0jma' /* Perfumes or fragrances */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'ondmfbjp' /* Soaps or detergents */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'sys8yrwz' /* Nickel (in jewelry or clothing... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'ydvubvhx' /* Hair dyes or cosmetics */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'b7juo046' /* Cleaning products */,
                                    )
                                  ],
                                  onChanged: (val) => safeSetState(
                                      () => _model.checkboxGroupValues5 = val),
                                  controller:
                                      _model.checkboxGroupValueController5 ??=
                                          FormFieldController<List<String>>(
                                    [],
                                  )..addListener(() {
                                              debugLogWidgetClass(_model);
                                            }),
                                  activeColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  checkColor: Colors.white,
                                  checkboxBorderColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                  unselectedTextStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.manrope(),
                                            letterSpacing: 0.0,
                                          ),
                                  checkboxBorderRadius:
                                      BorderRadius.circular(4.0),
                                  initialized:
                                      _model.checkboxGroupValues5 != null,
                                ),
                                theme: const ExpandableThemeData(
                                  tapHeaderToExpand: true,
                                  tapBodyToExpand: true,
                                  tapBodyToCollapse: true,
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  hasIcon: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).tertiary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            color: const Color(0x00000000),
                            child: ExpandableNotifier(
                              controller:
                                  _model.expandableExpandableController6,
                              child: ExpandablePanel(
                                header: Opacity(
                                  opacity: 0.7,
                                  child: Text(
                                    FFLocalizations.of(context).getText(
                                      'vr30sbxb' /* Rare or Less Common Allergies */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                                collapsed: Text(
                                  FFLocalizations.of(context).getText(
                                    'pz43we6w' /* [Selected Alleriges] */,
                                  ),
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                expanded: FlutterFlowCheckboxGroup(
                                  options: [
                                    FFLocalizations.of(context).getText(
                                      'gjvdd6mz' /* Sunlight (photosensitivity) */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'mbefpbxf' /* Cold temperatures (cold urtica... */,
                                    ),
                                    FFLocalizations.of(context).getText(
                                      'b33uqgir' /* Water (aquagenic urticaria) */,
                                    )
                                  ],
                                  onChanged: (val) => safeSetState(
                                      () => _model.checkboxGroupValues6 = val),
                                  controller:
                                      _model.checkboxGroupValueController6 ??=
                                          FormFieldController<List<String>>(
                                    [],
                                  )..addListener(() {
                                              debugLogWidgetClass(_model);
                                            }),
                                  activeColor:
                                      FlutterFlowTheme.of(context).alternate,
                                  checkColor: Colors.white,
                                  checkboxBorderColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                  textStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.manrope(),
                                        color: Colors.black,
                                        letterSpacing: 0.0,
                                      ),
                                  unselectedTextStyle:
                                      FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.manrope(),
                                            letterSpacing: 0.0,
                                          ),
                                  checkboxBorderRadius:
                                      BorderRadius.circular(4.0),
                                  initialized:
                                      _model.checkboxGroupValues6 != null,
                                ),
                                theme: const ExpandableThemeData(
                                  tapHeaderToExpand: true,
                                  tapBodyToExpand: true,
                                  tapBodyToCollapse: true,
                                  headerAlignment:
                                      ExpandablePanelHeaderAlignment.center,
                                  hasIcon: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(1.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FFButtonWidget(
                        onPressed: () {
                          print('Button pressed ...');
                        },
                        text: FFLocalizations.of(context).getText(
                          'wl8lcb2e' /* Save */,
                        ),
                        icon: const Icon(
                          Icons.done,
                          size: 15.0,
                        ),
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconAlignment: IconAlignment.end,
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.manrope(),
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FFLocalizations.of(context).getText(
                              '3vqc5haw' /* Other... */,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.manrope(),
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                          ),
                          TextFormField(
                            controller: _model.textController,
                            focusNode: _model.textFieldFocusNode,
                            autofocus: false,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.manrope(),
                                    letterSpacing: 0.0,
                                  ),
                              hintText: FFLocalizations.of(context).getText(
                                'w7rl9kry' /* Specify  your allergy here... */,
                              ),
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.manrope(),
                                    letterSpacing: 0.0,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.manrope(),
                                  letterSpacing: 0.0,
                                ),
                            cursorColor:
                                FlutterFlowTheme.of(context).primaryText,
                            validator: _model.textControllerValidator
                                !.asValidator(context),
                          ),
                        ].divide(const SizedBox(height: 4.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ].divide(const SizedBox(height: 10.0)),
          ),
        ),
      ),
    );
  }
}
