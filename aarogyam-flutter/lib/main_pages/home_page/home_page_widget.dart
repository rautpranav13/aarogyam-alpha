import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/medication_schedule.dart';
import '../../core/services/medication_storage_service.dart';
import '../../core/services/vernacular_service.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../theme/app_colors.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _triggerEmergencySos(BuildContext context, VernacularService vern) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emergency, color: AppColors.error, size: 30),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                vern.t('sosDialogTitle'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vern.t('sosDialogDesc'),
              style: GoogleFonts.manrope(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.errorLight,
                child: Icon(Icons.local_hospital, color: AppColors.error),
              ),
              title: Text(
                vern.t('call108'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text('108 (Emergency Ambulance)'),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse('tel:108');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              vern.t('cancel'),
              style: GoogleFonts.manrope(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medStorage = Provider.of<MedicationStorageService>(context);
    final vernService = Provider.of<VernacularService>(context);

    final nextDose = medStorage.nextDose;
    final todayLogs = medStorage.todayDoseLogs;
    final completedCount = medStorage.completedDosesCount;
    final totalCount = medStorage.totalDosesToday;
    final adherencePercent = totalCount > 0 ? (completedCount / totalCount) : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              vernService.t('appName'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher Dropdown
          PopupMenuButton<AppLanguage>(
            tooltip: 'Language',
            initialValue: vernService.currentLanguage,
            onSelected: (AppLanguage newLang) {
              vernService.setLanguage(newLang);
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AppLanguage.hindi,
                child: Text('हिंदी (Hindi)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const PopupMenuItem(
                value: AppLanguage.marathi,
                child: Text('मराठी (Marathi)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const PopupMenuItem(
                value: AppLanguage.english,
                child: Text('English', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vernService.currentLanguage == AppLanguage.marathi
                        ? 'मराठी'
                        : (vernService.currentLanguage == AppLanguage.hindi ? 'हिंदी' : 'English'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Profile & Settings Button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Profile',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
            ),
            onPressed: () => context.pushNamed('ProfilePageCopy'),
          ),
          const SizedBox(width: 2),
          // SOS Emergency Button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Emergency SOS',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sos, color: AppColors.error, size: 20),
            ),
            onPressed: () => _triggerEmergencySos(context, vernService),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dadi-Ma Vernacular Voice Banner & Greeting
              _buildDadiMaGreetingCard(context, vernService, nextDose),
              const SizedBox(height: 16),

              // 2. Hero Next Dose Card
              _buildNextDoseCard(context, nextDose, medStorage, vernService),
              const SizedBox(height: 16),

              // 3. Adherence Score & Streak
              _buildAdherenceCard(completedCount, totalCount, adherencePercent, vernService),
              const SizedBox(height: 20),

              // 4. Primary 4-Action Grid
              Text(
                vernService.t('keyActionsHeader'),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionGrid(context, vernService, nextDose),
              const SizedBox(height: 24),

              // 5. Today's Medication Timeline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      vernService.t('timelineHeader'),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.pushNamed('ReminderPage'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            vernService.t('viewAll'),
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (todayLogs.isEmpty)
                _buildEmptyStateCard(vernService)
              else
                ...todayLogs.map((dose) => _buildDoseItemCard(context, dose, medStorage, vernService)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDadiMaGreetingCard(BuildContext context, VernacularService vern, DoseLogEntry? nextDose) {
    return InkWell(
      onTap: () => context.pushNamed('DadiMa'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryAccent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.elderly_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vern.t('dadiMaVoiceGuide'),
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vern.t('dadiMaGreeting'),
                        style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: vern.isPlaying ? 'Stop' : 'Listen',
                  icon: Icon(
                    vern.isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  onPressed: () {
                    if (vern.isPlaying) {
                      vern.stopSpeech();
                    } else {
                      vern.speakNextDose(nextDose);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        vern.t('dadiMaAskButton'),
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextDoseCard(BuildContext context, DoseLogEntry? dose, MedicationStorageService storage, VernacularService vern) {
    if (dose == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vern.t('allDosesCompleted'),
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vern.t('allDosesCompletedDesc'),
                    style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${vern.t('nextDose')} • ${vern.slotName(dose.scheduledSlot)} (${dose.scheduledTime})',
                      style: GoogleFonts.manrope(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.volume_up, color: Colors.white, size: 22),
                onPressed: () => vern.speakNextDose(dose),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dose.medicineName,
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dose.dosage,
                  style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '🍽️ ${vern.foodRelation(dose.foodRelation)}',
                style: GoogleFonts.manrope(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Mark Taken Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => storage.markDoseTaken(dose.id),
                  icon: const Icon(Icons.check, size: 18, color: AppColors.primary),
                  label: Text(
                    vern.t('markTaken'),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Verify Foil Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed('BlisterVerifier'),
                  icon: const Icon(Icons.qr_code_scanner, size: 18, color: Colors.white),
                  label: Text(
                    vern.t('verifyBlister'),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(int completed, int total, double rate, VernacularService vern) {
    String subText;
    if (vern.currentLanguage == AppLanguage.marathi) {
      subText = '$total पैकी $completed डोस पूर्ण • 7-${vern.t('dayStreak')}';
    } else if (vern.currentLanguage == AppLanguage.english) {
      subText = '$completed of $total doses completed • 7-${vern.t('dayStreak')}';
    } else {
      subText = '$total में से $completed खुराकें पूरी की गईं • 7-${vern.t('dayStreak')}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: rate,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceAlt,
                  color: rate >= 0.8 ? AppColors.success : (rate >= 0.5 ? AppColors.warning : AppColors.error),
                ),
              ),
              Text(
                '${(rate * 100).toInt()}%',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vern.t('adherenceTitle'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, VernacularService vern, DoseLogEntry? nextDose) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: [
        _buildActionTile(
          context: context,
          title: vern.t('actionScanRxTitle'),
          subtitle: vern.t('actionScanRxSub'),
          desc: 'IBM Granite Vision AI',
          icon: Icons.document_scanner_rounded,
          color: AppColors.primary,
          lightColor: AppColors.primaryLight,
          onTap: () => context.pushNamed('ReportSanner'),
        ),
        _buildActionTile(
          context: context,
          title: vern.t('actionVerifyStripTitle'),
          subtitle: vern.t('actionVerifyStripSub'),
          desc: 'ML Kit + Foil Matcher',
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF1565C0),
          lightColor: const Color(0xFFE3F2FD),
          onTap: () => context.pushNamed('BlisterVerifier'),
        ),
        _buildActionTile(
          context: context,
          title: vern.t('actionScheduleTitle'),
          subtitle: vern.t('actionScheduleSub'),
          desc: 'Timers & Dose Logs',
          icon: Icons.alarm_on_rounded,
          color: const Color(0xFFE65100),
          lightColor: const Color(0xFFFFF3E0),
          onTap: () => context.pushNamed('ReminderPage'),
        ),
        _buildActionTile(
          context: context,
          title: vern.t('actionVoiceTitle'),
          subtitle: vern.t('actionVoiceSub'),
          desc: 'Vernacular Audio Readout',
          icon: Icons.hearing_rounded,
          color: const Color(0xFF6A1B9A),
          lightColor: const Color(0xFFF3E5F5),
          onTap: () => vern.speakNextDose(nextDose),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String desc,
    required IconData icon,
    required Color color,
    required Color lightColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.manrope(fontSize: 10, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoseItemCard(BuildContext context, DoseLogEntry dose, MedicationStorageService storage, VernacularService vern) {
    final isTaken = dose.status == DoseStatus.taken;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTaken ? AppColors.surfaceAlt.withValues(alpha: 0.5) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTaken ? AppColors.success.withValues(alpha: 0.3) : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          // Checkbox Toggle
          Checkbox(
            value: isTaken,
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (val) {
              if (val == true) {
                storage.markDoseTaken(dose.id);
              } else {
                storage.resetDoseStatus(dose.id);
              }
            },
          ),
          const SizedBox(width: 8),
          // Medicine Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dose.medicineName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                          color: isTaken ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getSlotColor(dose.scheduledSlot).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${vern.slotName(dose.scheduledSlot)} • ${dose.scheduledTime}',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getSlotColor(dose.scheduledSlot),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${dose.dosage} • ${vern.foodRelation(dose.foodRelation)}',
                      style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (dose.verifiedViaFoil) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: AppColors.success, size: 14),
                      Text(
                        ' ${vern.t('foilVerifiedBadge')}',
                        style: GoogleFonts.manrope(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 20, color: AppColors.primary),
            onPressed: () => vern.speakText('${dose.medicineName}, ${dose.dosage}, ${vern.foodRelation(dose.foodRelation)}'),
          ),
        ],
      ),
    );
  }

  Color _getSlotColor(String slot) {
    final s = slot.toLowerCase();
    if (s.contains('morn') || s.contains('सुबह') || s.contains('सकाळ')) {
      return AppColors.pillMorning;
    } else if (s.contains('afternoon') || s.contains('noon') || s.contains('दोपहर') || s.contains('दुपार')) {
      return AppColors.pillAfternoon;
    } else if (s.contains('night') || s.contains('रात') || s.contains('रात्र')) {
      return AppColors.pillNight;
    }
    return AppColors.primary;
  }

  Widget _buildEmptyStateCard(VernacularService vern) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.medication_liquid_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              vern.t('noMedsScheduled'),
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              vern.t('noMedsScheduledDesc'),
              style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
