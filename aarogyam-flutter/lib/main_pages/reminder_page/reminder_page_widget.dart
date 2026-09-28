import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/models/medication_schedule.dart';
import '/core/services/medication_storage_service.dart';
import '/core/services/vernacular_service.dart';
import '/theme/app_colors.dart';
import 'reminder_page_model.dart';
export 'reminder_page_model.dart';

class ReminderPageWidget extends StatefulWidget {
  const ReminderPageWidget({super.key});

  @override
  State<ReminderPageWidget> createState() => _ReminderPageWidgetState();
}

class _ReminderPageWidgetState extends State<ReminderPageWidget> with SingleTickerProviderStateMixin {
  late ReminderPageModel _model;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _model = ReminderPageModel();
    _model.initState(context);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _showAddMedicineDialog(BuildContext context, VernacularService vernService) {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController(text: '500 mg');
    bool morning = true;
    bool afternoon = false;
    bool night = true;
    String foodRelation = 'After Food';
    int duration = 14;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vernService.t('modalAddMedTitle'),
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: vernService.t('inputMedNameLabel'),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: doseCtrl,
                      decoration: InputDecoration(
                        labelText: vernService.t('inputDosageLabel'),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vernService.t('scheduleSlotsLabel'),
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilterChip(
                          label: Text(vernService.t('slotMorningChip')),
                          selected: morning,
                          onSelected: (val) => setDialogState(() => morning = val),
                          selectedColor: AppColors.pillMorning.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(vernService.t('slotAfternoonChip')),
                          selected: afternoon,
                          onSelected: (val) => setDialogState(() => afternoon = val),
                          selectedColor: AppColors.pillAfternoon.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text(vernService.t('slotNightChip')),
                          selected: night,
                          onSelected: (val) => setDialogState(() => night = val),
                          selectedColor: AppColors.pillNight.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: foodRelation,
                      decoration: InputDecoration(
                        labelText: vernService.t('foodRelationLabel'),
                        filled: true,
                        fillColor: AppColors.surfaceAlt,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: [
                        DropdownMenuItem(value: 'After Food', child: Text(vernService.t('foodAfterOption'))),
                        DropdownMenuItem(value: 'Before Food', child: Text(vernService.t('foodBeforeOption'))),
                        DropdownMenuItem(value: 'With Food', child: Text(vernService.t('foodWithOption'))),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => foodRelation = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final newMed = MedicineItem(
                            id: 'med_custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            dosage: doseCtrl.text.trim(),
                            morning: morning,
                            afternoon: afternoon,
                            night: night,
                            foodRelation: foodRelation,
                            durationDays: duration,
                            instructionsHindi: '$foodRelation पानी के साथ लें।',
                            instructionsMarathi: '$foodRelation पाण्यासोबत घ्या.',
                            instructionsEnglish: 'Take $foodRelation with water.',
                          );
                          Provider.of<MedicationStorageService>(context, listen: false).addMedicine(newMed);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.success,
                              content: Text(vernService.t('medAddedSuccess')),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          vernService.t('btnSaveSchedule'),
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final medStorage = Provider.of<MedicationStorageService>(context);
    final vernService = Provider.of<VernacularService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          vernService.t('scheduleHubTitle'),
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            tooltip: 'Language Toggle',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vernService.langDisplayName,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            onPressed: () {
              final next = vernService.currentLanguage == AppLanguage.hindi
                  ? AppLanguage.marathi
                  : (vernService.currentLanguage == AppLanguage.marathi ? AppLanguage.english : AppLanguage.hindi);
              vernService.setLanguage(next);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: vernService.t('tabTodayDoses')),
            Tab(text: vernService.t('tabActiveMeds')),
            Tab(text: vernService.t('tabRxHistory')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddMedicineDialog(context, vernService),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          vernService.t('btnAddMedicine'),
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Today's Dose Logs
          _buildTodayDosesTab(medStorage, vernService),

          // Tab 2: Active Medicines
          _buildActiveMedicinesTab(medStorage, vernService),

          // Tab 3: Prescriptions History
          _buildPrescriptionsTab(medStorage, vernService),
        ],
      ),
    );
  }

  Widget _buildTodayDosesTab(MedicationStorageService storage, VernacularService vern) {
    final logs = storage.todayDoseLogs;
    if (logs.isEmpty) {
      return Center(
        child: Text(
          vern.t('noMedsScheduled'),
          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: logs.length,
      itemBuilder: (ctx, i) {
        final dose = logs[i];
        final isTaken = dose.status == DoseStatus.taken;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isTaken ? AppColors.surfaceAlt.withValues(alpha: 0.6) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isTaken ? AppColors.success.withValues(alpha: 0.3) : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dose.medicineName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        decoration: isTaken ? TextDecoration.lineThrough : null,
                        color: isTaken ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dose.dosage} • ${vern.slotName(dose.scheduledSlot)} (${dose.scheduledTime}) • ${vern.foodRelation(dose.foodRelation)}',
                      style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (dose.verifiedViaFoil) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.verified, color: AppColors.success, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            vern.t('foilVerifiedBadge'),
                            style: GoogleFonts.manrope(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.primary, size: 22),
                onPressed: () => vern.speakText('${dose.medicineName}, ${vern.slotName(dose.scheduledSlot)}, ${vern.foodRelation(dose.foodRelation)}'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveMedicinesTab(MedicationStorageService storage, VernacularService vern) {
    final meds = storage.medicines;
    if (meds.isEmpty) {
      return Center(
        child: Text(
          vern.t('noActiveMeds'),
          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: meds.length,
      itemBuilder: (ctx, i) {
        final med = meds[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: med.pillColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      med.name,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    onPressed: () => storage.removeMedicine(med.id),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${med.dosage} • ${med.frequency} • ${vern.foodRelation(med.foodRelation)}',
                style: GoogleFonts.manrope(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                vern.getMedicineInstruction(med),
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.primaryDark, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsTab(MedicationStorageService storage, VernacularService vern) {
    final rxList = storage.prescriptions;
    if (rxList.isEmpty) {
      return Center(
        child: Text(
          vern.t('noRxHistory'),
          style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: rxList.length,
      itemBuilder: (ctx, i) {
        final rx = rxList[i];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.medical_services, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rx.doctorName,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          rx.clinicHospital,
                          style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: AppColors.primary),
                    onPressed: () => vern.speakPrescription(rx),
                  ),
                ],
              ),
              const Divider(height: 18, color: AppColors.divider),
              Text(
                '${vern.t('diagnosis')} ${rx.diagnosis}',
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                '${vern.t('medsInRx')} (${rx.medicines.length}): ${rx.medicines.map((m) => m.name).join(", ")}',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}
