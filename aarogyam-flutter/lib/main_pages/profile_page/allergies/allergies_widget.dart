import '/flutter_flow/flutter_flow_checkbox_group.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'allergies_model.dart';
export 'allergies_model.dart';

class AllergiesWidget extends StatefulWidget {
  const AllergiesWidget({super.key});

  @override
  State<AllergiesWidget> createState() => _AllergiesWidgetState();
}

class _AllergiesWidgetState extends State<AllergiesWidget> with RouteAware {
  late AllergiesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AllergiesModel());

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
          child: MasonryGridView.builder(
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            itemCount: 9,
            itemBuilder: (context, index) {
              return [
                () => Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12.0, 30.0, 12.0, 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 30.0,
                            buttonSize: 60.0,
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            icon: Icon(
                              Icons.arrow_back,
                              color: FlutterFlowTheme.of(context).primaryText,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              context.safePop();
                            },
                          ),
                          Container(
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: const AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        FFLocalizations.of(context).getText(
                                          'v4cvorwt' /* Allergies */,
                                        ),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.manrope(),
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(width: 6.0)),
                      ),
                    ),
                () => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(),
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
                                      'v4it3cs8' /* Food Allergies */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  collapsed: Container(),
                                  expanded: FlutterFlowCheckboxGroup(
                                    options: [
                                      FFLocalizations.of(context).getText(
                                        'xitz7pac' /* Peanuts */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '37n9p1o8' /* Tree nuts (e.g., almonds, waln... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '7izmft2n' /* Milk (lactose intolerance or d... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'qwldzxs0' /* Eggs */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'hjr8gu65' /* Shellfish (e.g., shrimp, crab,... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'nxg05p9w' /* Fish (e.g., salmon, tuna) */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '36jtdw0y' /* Soy */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'jqoiqi58' /* Wheat (gluten intolerance or a... */,
                                      )
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.checkboxGroupValues1 = val),
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
                () => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
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
                                      'xcfte37b' /* Environmental Allergies */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  collapsed: Container(),
                                  expanded: FlutterFlowCheckboxGroup(
                                    options: [
                                      FFLocalizations.of(context).getText(
                                        'uqs4gk20' /* Pollen (grass, trees, or flowe... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'gu9iyur9' /* Dust mites */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '6keaylqw' /* Mold spores */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'bjxvernh' /* Animal dander (cats, dogs, etc... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '9bzu7qmj' /* Cockroach droppings */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'vvabksjy' /* Latex */,
                                      )
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.checkboxGroupValues2 = val),
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
                () => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).tertiary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(),
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
                                      '64z8bhud' /* Medication Allergies */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  collapsed: Container(),
                                  expanded: FlutterFlowCheckboxGroup(
                                    options: [
                                      FFLocalizations.of(context).getText(
                                        'qdc6xo57' /* Penicillin or other antibiotic... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'a0sjqk93' /* Aspirin */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '8q12e1nz' /* Ibuprofen */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'jj1guz3s' /* Sulfa drugs */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'eif9fchm' /* Anesthesia (e.g., lidocaine) */,
                                      )
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.checkboxGroupValues3 = val),
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
                () => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(),
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
                                      'hfdspp28' /* Insect Allergies */,
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(),
                                          color: Colors.black,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                  collapsed: Container(),
                                  expanded: FlutterFlowCheckboxGroup(
                                    options: [
                                      FFLocalizations.of(context).getText(
                                        'usb32aa0' /* Bee stings */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'ykntkkju' /* Wasp stings */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'qrb48q63' /* Mosquito bites */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '2vo7do12' /* Fire ant bites */,
                                      )
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.checkboxGroupValues4 = val),
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
                () => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(),
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
                                        'rut7wupc' /* Chemical and Skin Allergies */,
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
                                  collapsed: Container(),
                                  expanded: FlutterFlowCheckboxGroup(
                                    options: [
                                      FFLocalizations.of(context).getText(
                                        '8h8cqv82' /* Perfumes or fragrances */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        '14h9zxpt' /* Soaps or detergents */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'cm02jy6i' /* Nickel (in jewelry or clothing... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'awbn2z6g' /* Hair dyes or cosmetics */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'bh2supoy' /* Cleaning products */,
                                      )
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.checkboxGroupValues5 = val),
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
                () => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).tertiary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(),
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
                                        'luilux78' /* Rare or Less Common Allergies */,
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
                                  collapsed: Container(),
                                  expanded: FlutterFlowCheckboxGroup(
                                    options: [
                                      FFLocalizations.of(context).getText(
                                        '9vzp42f0' /* Sunlight (photosensitivity) */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'iigpgbl4' /* Cold temperatures (cold urtica... */,
                                      ),
                                      FFLocalizations.of(context).getText(
                                        'p629h6qb' /* Water (aquagenic urticaria) */,
                                      )
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.checkboxGroupValues6 = val),
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
                () => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primary,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FFLocalizations.of(context).getText(
                                  '7b9jl64z' /* Other... */,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.manrope(),
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              SizedBox(
                                width: 350.0,
                                child: TextFormField(
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
                                    hintText:
                                        FFLocalizations.of(context).getText(
                                      'epom6kvc' /* Specify  your allergy here... */,
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
                                        color:
                                            FlutterFlowTheme.of(context).error,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            FlutterFlowTheme.of(context).error,
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
                              ),
                            ].divide(const SizedBox(height: 4.0)),
                          ),
                        ),
                      ),
                    ),
                () => Align(
                      alignment: const AlignmentDirectional(1.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: FFButtonWidget(
                          onPressed: () {
                            debugPrint('Button pressed ...');
                          },
                          text: FFLocalizations.of(context).getText(
                            'mim19fdt' /* Save */,
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
                            color: FlutterFlowTheme.of(context).primaryText,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  font: GoogleFonts.manrope(),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                      ),
                    ),
              ][index]();
            },
          ),
        ),
      ),
    );
  }
}
