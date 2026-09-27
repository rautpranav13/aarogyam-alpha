import '/widgets/a_i_disclaimer/a_i_disclaimer_widget.dart';
import '/widgets/reminder/reminder_list_collapsed/reminder_list_collapsed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;

  @override
  void initState() {
    super.initState();
    _model = HomePageModel();
    _model.init(context);

    // Request notifications permission on page load.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Permission request — keeping the original intent intact without
      // depending on the deleted permissions_util.dart.
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _buildNavButton({
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme cs,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: cs.onSurface,
        foregroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final List<Widget> cards = [
      // Card 1: Reminder list
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('ReminderPage'),
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: cs.onSurface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Hero(
              tag: 'Expandable card',
              transitionOnUserGestures: true,
              child: Material(
                color: Colors.transparent,
                child: ReminderListCollapsedWidget(),
              ),
            ),
          ),
        ),
      ),
      // Card 2: Motivational image 1
      _buildImageCard(cs, 'assets/images/motiv3.jpg'),
      // Card 3: Motivational image 2
      _buildImageCard(cs, 'assets/images/motivation2.jpeg'),
      // Card 4: AI Disclaimer
      Material(
        color: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: cs.onSurface,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x74000000), Color(0x65000000)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.surface, width: 3),
                ),
                child: const AIDisclaimerWidget(),
              ),
            ),
          ),
        ),
      ),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 30, 12, 1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Notification/Reminder bell
                    IconButton.filled(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('ReminderPage'),
                      icon: FaIcon(
                        FontAwesomeIcons.bell,
                        size: 20,
                        color: cs.onSurface,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: cs.surfaceContainerHighest,
                      ),
                    ),
                    // Profile avatar
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed('ProfilePageCopy'),
                      child: Hero(
                        tag: 'ProfileImage',
                        transitionOnUserGestures: true,
                        child: Container(
                          width: 48,
                          height: 48,
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/images/Sanjivani.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Sanskrit headline
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 40, 12, 30),
                child: Text(
                  'आरोग्यम् धनसंपदा',
                  style: tt.displayMedium?.copyWith(
                    fontFamily: 'KCS',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Navigation buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(
                      icon: const Icon(Icons.document_scanner_outlined,
                          size: 15),
                      label: 'Scan Rx',
                      cs: cs,
                      onPressed: () =>
                          Navigator.of(context).pushNamed('ReportSanner'),
                    ),
                    _buildNavButton(
                      icon: const Icon(Icons.shield_outlined, size: 15),
                      label: 'Pill Verifier',
                      cs: cs,
                      onPressed: () =>
                          Navigator.of(context).pushNamed('BlisterVerifier'),
                    ),
                    _buildNavButton(
                      icon: const Icon(Icons.alarm_on, size: 16),
                      label: 'Reminders',
                      cs: cs,
                      onPressed: () =>
                          Navigator.of(context).pushNamed('ReminderPage'),
                    ),
                  ],
                ),
              ),
              // Swipeable card stack
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Stack(
                    children: [
                      // Background panel
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          height: 161,
                          color: cs.onSurface,
                        ),
                      ),
                      // Swipe hint
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Swipe the cards',
                                style: tt.bodyMedium?.copyWith(
                                  fontFamily: GoogleFonts.manrope().fontFamily,
                                  color: cs.surface,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.swipe_left,
                                  color: cs.surface, size: 24),
                            ],
                          ),
                        ),
                      ),
                      // Shadow cards behind
                      Align(
                        alignment: const Alignment(-0.03, -1.11),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 86),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: Container(
                              width: 277,
                              height: 223,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(-0.05, -1.04),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 12,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            child: Container(
                              width: 333,
                              height: 268,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEED0FE),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Card swiper
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: CardSwiper(
                          controller: _model.swipeableStackController,
                          cardsCount: cards.length,
                          cardBuilder: (context, index, _, __) => cards[index],
                          isLoop: true,
                          numberOfCardsDisplayed: 3,
                          scale: 0.9,
                          padding: EdgeInsets.zero,
                          backCardOffset: const Offset(0, 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(ColorScheme cs, String assetPath) {
    return Material(
      color: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: cs.onSurface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x74000000), Color(0x65000000)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.surface, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Image.asset(
                  assetPath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
