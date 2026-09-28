import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/dadi_ma_models.dart';
import '../../core/services/dadi_ma_service.dart';
import '../../core/services/medication_storage_service.dart';
import '../../core/services/vernacular_service.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../theme/app_colors.dart';
import 'dadi_ma_model.dart';
export 'dadi_ma_model.dart';

class DadiMaWidget extends StatefulWidget {
  const DadiMaWidget({super.key});

  @override
  State<DadiMaWidget> createState() => _DadiMaWidgetState();
}

class _DadiMaWidgetState extends State<DadiMaWidget>
    with SingleTickerProviderStateMixin {
  late DadiMaModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DadiMaModel());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_model.selectedTabIndex != _tabController.index) {
        setState(() {
          _model.selectedTabIndex = _tabController.index;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dadiService = Provider.of<DadiMaService>(context, listen: false);
      dadiService.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(
    DadiMaService dadiService,
    MedicationStorageService medStorage,
  ) async {
    final query = _model.textController?.text.trim() ?? '';
    if (query.isEmpty) return;

    _model.textController?.clear();
    _scrollToBottom();

    await dadiService.sendMessage(
      query,
      activeMedications: medStorage.medicines,
      diagnosis: medStorage.prescriptions.isNotEmpty
          ? medStorage.prescriptions.first.diagnosis
          : null,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final dadiService = Provider.of<DadiMaService>(context);
    final vernService = Provider.of<VernacularService>(context);
    final medStorage = Provider.of<MedicationStorageService>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF9FAF7),
        appBar: _buildAppBar(context, vernService, dadiService),
        body: SafeArea(
          child: Column(
            children: [
              _buildTabBar(vernService),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 0: Interactive Chat & Voice
                    _buildChatTab(context, dadiService, vernService, medStorage),
                    // Tab 1: Ayurvedic Remedies Catalog
                    _buildRemediesTab(context, dadiService, vernService),
                    // Tab 2: Daily Guidance & Advice
                    _buildGuidanceTab(context, dadiService, vernService, medStorage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    VernacularService vern,
    DadiMaService dadiService,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: dadiService.currentlySpeakingMessageId != null
                    ? AppColors.primary
                    : AppColors.primaryLight,
                width: 2.5,
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Icon(
                dadiService.currentlySpeakingMessageId != null
                    ? Icons.record_voice_over_rounded
                    : Icons.elderly_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vern.t('dadiMaCompanionTitle'),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  vern.langDisplayName,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Language switcher chip
        PopupMenuButton<AppLanguage>(
          initialValue: vern.currentLanguage,
          icon: const Icon(Icons.translate_rounded, color: AppColors.primary, size: 22),
          onSelected: (AppLanguage newLang) {
            vern.setLanguage(newLang);
            dadiService.resetForLanguage(newLang);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: AppLanguage.hindi, child: Text('हिंदी (Hindi)')),
            const PopupMenuItem(value: AppLanguage.marathi, child: Text('मराठी (Marathi)')),
            const PopupMenuItem(value: AppLanguage.english, child: Text('English')),
          ],
        ),
        // Slow speech toggle
        IconButton(
          tooltip: vern.t('dadiMaSlowSpeech'),
          icon: Icon(
            dadiService.isSlowSpeech ? Icons.speed_rounded : Icons.slow_motion_video_rounded,
            color: dadiService.isSlowSpeech ? AppColors.warning : AppColors.textSecondary,
            size: 22,
          ),
          onPressed: () => dadiService.toggleSlowSpeech(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTabBar(VernacularService vern) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.manrope(fontSize: 12),
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        tabs: [
          Tab(text: vern.t('dadiMaTabChat'), icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18)),
          Tab(text: vern.t('dadiMaTabRemedies'), icon: const Icon(Icons.spa_outlined, size: 18)),
          Tab(text: vern.t('dadiMaTabGuidance'), icon: const Icon(Icons.wb_sunny_outlined, size: 18)),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 0: INTERACTIVE CHAT & VOICE
  // ===========================================================================
  Widget _buildChatTab(
    BuildContext context,
    DadiMaService dadiService,
    VernacularService vern,
    MedicationStorageService medStorage,
  ) {
    return Column(
      children: [
        // Messages List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: dadiService.messages.length + (dadiService.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == dadiService.messages.length) {
                return _buildLoadingBubble();
              }
              final msg = dadiService.messages[index];
              return _buildMessageItem(context, msg, dadiService, vern);
            },
          ),
        ),

        // Quick Suggestion Chips
        _buildQuickChips(dadiService, vern, medStorage),

        // Input Bar
        _buildInputBar(context, dadiService, vern, medStorage),
      ],
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    DadiMaChatMessage msg,
    DadiMaService dadiService,
    VernacularService vern,
  ) {
    final isUser = msg.sender == DadiMaSender.user;
    final isSpeaking = dadiService.currentlySpeakingMessageId == msg.id;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // Dadi-Ma Message
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency SOS Card if flagged
            if (msg.isEmergency) _buildEmergencyCard(context, msg, vern),

            // Main Answer Bubble
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: isSpeaking
                      ? AppColors.primary
                      : const Color(0xFFE0E0E0),
                  width: isSpeaking ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.elderly_rounded, color: AppColors.primaryDark, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vern.t('dadiMaVoiceGuide'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Spacer(),
                      // Speak / Stop speech button
                      InkWell(
                        onTap: () {
                          if (isSpeaking) {
                            dadiService.stopSpeaking();
                          } else {
                            dadiService.speakMessage(msg);
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSpeaking ? AppColors.primary : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                                size: 16,
                                color: isSpeaking ? Colors.white : AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSpeaking ? 'Stop' : 'Listen',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSpeaking ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    msg.text,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            // Embedded Remedies Cards
            if (msg.remedies.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...msg.remedies.map((remedy) => _buildEmbeddedRemedyCard(remedy, vern)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context,
    DadiMaChatMessage msg,
    VernacularService vern,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, color: AppColors.error, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vern.t('dadiMaEmergencySOS'),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            msg.emergencyWarning ?? msg.text,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: const Color(0xFFB71C1C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
            label: Text(
              vern.t('call108'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () async {
              final uri = Uri.parse('tel:108');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedRemedyCard(AyurvedicRemedy remedy, VernacularService vern) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFAED581)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: Color(0xFF558B2F), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  remedy.title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF33691E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            remedy.description,
            style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            vern.t('dadiMaIngredients'),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF33691E),
            ),
          ),
          ...remedy.ingredients.map(
            (ing) => Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: Text(
                '• $ing',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            vern.t('dadiMaPreparation'),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF33691E),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 2),
            child: Text(
              remedy.preparation,
              style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
          if (remedy.precaution.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              vern.t('dadiMaPrecaution'),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: Text(
                remedy.precaution,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: const Color(0xFFE65100),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'दादी-माँ सोच रही हैं...',
              style: GoogleFonts.manrope(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChips(
    DadiMaService dadiService,
    VernacularService vern,
    MedicationStorageService medStorage,
  ) {
    final chips = [
      vern.t('dadiMaChipMyMeds'),
      vern.t('dadiMaChipCough'),
      vern.t('dadiMaChipAcidity'),
      vern.t('dadiMaChipJointPain'),
      vern.t('dadiMaChipBpDiet'),
      vern.t('dadiMaChipSugarDiet'),
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = chips[index];
          return ActionChip(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFC8E6C9)),
            label: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            onPressed: () {
              _model.textController?.text = label;
              _handleSend(dadiService, medStorage);
            },
          );
        },
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    DadiMaService dadiService,
    VernacularService vern,
    MedicationStorageService medStorage,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _model.textController,
              focusNode: _model.textFieldFocusNode,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.manrope(fontSize: 14),
              decoration: InputDecoration(
                hintText: vern.t('dadiMaAskHint'),
                hintStyle: GoogleFonts.manrope(fontSize: 13, color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: const Color(0xFFF1F3F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _handleSend(dadiService, medStorage),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _handleSend(dadiService, medStorage),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: AYURVEDIC REMEDIES CATALOG
  // ===========================================================================
  Widget _buildRemediesTab(
    BuildContext context,
    DadiMaService dadiService,
    VernacularService vern,
  ) {
    final remedies = dadiService.remedies;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          vern.t('dadiMaTabRemedies'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'घरगुती व सुरक्षित आयुर्वेदिक उपाय जे पिढ्यानपिढ्या वापरले जात आहेत.',
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        if (remedies.isEmpty)
          const Center(child: CircularProgressIndicator(color: AppColors.primary))
        else
          ...remedies.map((r) => _buildCatalogRemedyItem(r, vern)),
      ],
    );
  }

  Widget _buildCatalogRemedyItem(AyurvedicRemedy remedy, VernacularService vern) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.spa_rounded, color: Color(0xFF2E7D32)),
        ),
        title: Text(
          remedy.title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          remedy.description,
          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF2E7D32), size: 22),
          tooltip: 'Listen to Remedy',
          onPressed: () {
            final textToSpeak = '${remedy.title}। ${remedy.description}। ${remedy.preparation}';
            vern.speakText(textToSpeak);
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  vern.t('dadiMaIngredients'),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                ...remedy.ingredients.map(
                  (ing) => Text('• $ing', style: GoogleFonts.manrope(fontSize: 13)),
                ),
                const SizedBox(height: 10),
                Text(
                  vern.t('dadiMaPreparation'),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remedy.preparation,
                  style: GoogleFonts.manrope(fontSize: 13, height: 1.4),
                ),
                if (remedy.precaution.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    vern.t('dadiMaPrecaution'),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remedy.precaution,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFFE65100),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: DAILY GUIDANCE & ADVICE
  // ===========================================================================
  Widget _buildGuidanceTab(
    BuildContext context,
    DadiMaService dadiService,
    VernacularService vern,
    MedicationStorageService medStorage,
  ) {
    final guidance = dadiService.dailyGuidance;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (guidance != null)
          Container(
            padding: const EdgeInsets.all(20),
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
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      guidance.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 28),
                      onPressed: () {
                        vern.speakText(guidance.audioText);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  guidance.text,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Active Medicines Overview
        Text(
          vern.t('tabActiveMeds'),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        if (medStorage.medicines.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              'कोणतेही सक्रिय औषध आढळले नाही. नवीन प्रिस्क्रिप्शन स्कॅन करा.',
              style: GoogleFonts.manrope(fontSize: 13, color: AppColors.textSecondary),
            ),
          )
        else
          ...medStorage.medicines.map(
            (med) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medication_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${med.frequency} • ${vern.foodRelation(med.foodRelation)}',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
