import '/widgets/reminder/reminder_list_collapsed/reminder_list_collapsed_widget.dart';
import '/widgets/reminder/reminder_list_expanded/reminder_list_expanded_widget.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_home_model.dart';
export 'auth_home_model.dart';

class AuthHomeWidget extends StatefulWidget {
  const AuthHomeWidget({super.key});

  @override
  State<AuthHomeWidget> createState() => _AuthHomeWidgetState();
}

class _AuthHomeWidgetState extends State<AuthHomeWidget> {
  late AuthHomeModel _model;
  late ExpandableController _expandableController;

  @override
  void initState() {
    super.initState();
    _model = AuthHomeModel();
    _model.init(context);
    _expandableController = ExpandableController(initialExpanded: false);
  }

  @override
  void dispose() {
    _expandableController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surfaceContainerHighest,
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.maps_home_work_rounded,
                  color: cs.primary,
                  size: 90,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Home',
                    textAlign: TextAlign.center,
                    style: tt.headlineSmall?.copyWith(
                      fontFamily: GoogleFonts.outfit().fontFamily,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    'You can delete this and create your own home page.',
                    textAlign: TextAlign.center,
                    style: tt.labelLarge?.copyWith(
                      fontFamily: GoogleFonts.manrope().fontFamily,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ExpandableNotifier(
                    controller: _expandableController,
                    child: ExpandablePanel(
                      header: const SizedBox.shrink(),
                      collapsed: const SizedBox(
                        height: 200,
                        child: ReminderListCollapsedWidget(),
                      ),
                      expanded: const SizedBox(
                        height: 200,
                        child: ReminderListExpandedWidget(),
                      ),
                      theme: const ExpandableThemeData(
                        tapHeaderToExpand: false,
                        tapBodyToExpand: true,
                        tapBodyToCollapse: true,
                        headerAlignment: ExpandablePanelHeaderAlignment.center,
                        hasIcon: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
