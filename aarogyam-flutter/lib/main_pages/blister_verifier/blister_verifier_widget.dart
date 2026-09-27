import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/sqlite/sqlite_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'blister_verifier_model.dart';
export 'blister_verifier_model.dart';

class BlisterVerifierWidget extends StatefulWidget {
  const BlisterVerifierWidget({super.key});

  @override
  State<BlisterVerifierWidget> createState() => _BlisterVerifierWidgetState();
}

class _BlisterVerifierWidgetState extends State<BlisterVerifierWidget> {
  late BlisterVerifierModel _model;
  final ImagePicker _picker = ImagePicker();
  List<String> _medicationOptions = [
    'Metformin 500mg',
    'Amlodipine 5mg',
    'Paracetamol 650mg',
    'Pantoprazole 40mg',
    'Atorvastatin 10mg'
  ];

  @override
  void initState() {
    super.initState();
    _model = BlisterVerifierModel();
    _loadMedicationsFromSQLite();
  }

  Future<void> _loadMedicationsFromSQLite() async {
    try {
      final rows = await SQLiteManager.instance.readmedications();
      if (rows.isNotEmpty) {
        final titles = rows
            .map((r) => r.title)
            .where((t) => t != null && t.isNotEmpty)
            .cast<String>()
            .toSet()
            .toList();
        if (titles.isNotEmpty) {
          setState(() {
            _medicationOptions = titles;
            _model.expectedDrug = titles.first;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _pickImageAndVerify(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final b64 = base64Encode(bytes);

      setState(() {
        _model.uploadedImageBase64 = b64;
        _model.isLoading = true;
        _model.isVerified = null;
      });

      // Split expectedDrug into name and strength if combined
      String drugName = _model.expectedDrug;
      String strength = _model.expectedStrength;
      if (drugName.contains(' ')) {
        final parts = drugName.split(' ');
        drugName = parts.first;
        if (parts.length > 1) strength = parts.sublist(1).join(' ');
      }

      final response = await VerifyStripAPICall.call(
        imageBase64: b64,
        expectedDrug: drugName,
        expectedStrength: strength,
        language: _model.selectedLanguage,
      );

      if (mounted) {
        setState(() {
          _model.isLoading = false;
          _model.apiResult = response;
          if (response.succeeded) {
            _model.isVerified = VerifyStripAPICall.isVerified(response.jsonBody);
            _model.detectedText =
                VerifyStripAPICall.detectedText(response.jsonBody);
            _model.voiceAlert =
                VerifyStripAPICall.voiceAlert(response.jsonBody);
            _model.action = VerifyStripAPICall.action(response.jsonBody);
          } else {
            _model.isVerified = false;
            _model.detectedText = 'Packaging analysis failed.';
            _model.voiceAlert = 'कृपया फार्मासिस्ट से जांच करवाएं।';
            _model.action = 'BLOCK_CONSUMPTION';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _model.isLoading = false;
          _model.isVerified = false;
          _model.voiceAlert = 'Error verifying pill strip: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          'Step 5: Blister Strip Verifier',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instruction Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: theme.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Closed-Loop Proof-of-Consumption',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: theme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Point camera at your medicine strip before swallowing to verify dosage and prevent accidental mix-ups.',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: theme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Expected Drug Selector
              Text(
                'Scheduled Medication to Verify:',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.alternate),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _medicationOptions.contains(_model.expectedDrug)
                        ? _model.expectedDrug
                        : _medicationOptions.first,
                    items: _medicationOptions.map((drug) {
                      return DropdownMenuItem<String>(
                        value: drug,
                        child: Text(
                          drug,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _model.expectedDrug = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Language Selector
              Row(
                children: [
                  Text(
                    'Spoken Language: ',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: theme.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('हिंदी (Hindi)'),
                    selected: _model.selectedLanguage == 'hi',
                    onSelected: (s) =>
                        setState(() => _model.selectedLanguage = 'hi'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('मराठी (Marathi)'),
                    selected: _model.selectedLanguage == 'mr',
                    onSelected: (s) =>
                        setState(() => _model.selectedLanguage = 'mr'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Camera / Scan Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _model.isLoading
                          ? null
                          : () => _pickImageAndVerify(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Scan Blister Foil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _model.isLoading
                        ? null
                        : () => _pickImageAndVerify(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    tooltip: 'Upload packaging image',
                    style: IconButton.styleFrom(
                      backgroundColor: theme.secondaryBackground,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Loading State
              if (_model.isLoading) ...[
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'IBM Granite Vision 3.2 2B inspecting packaging foil...',
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Verification Result Cards
              if (_model.isVerified != null && !_model.isLoading) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _model.isVerified == true
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _model.isVerified == true
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _model.isVerified == true
                                ? Icons.check_circle_rounded
                                : Icons.dangerous_rounded,
                            size: 36,
                            color: _model.isVerified == true
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _model.isVerified == true
                                      ? 'VERIFIED: SAFE TO CONSUME'
                                      : 'WARNING: DO NOT CONSUME',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _model.isVerified == true
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFC62828),
                                  ),
                                ),
                                Text(
                                  _model.isVerified == true
                                      ? 'Packaging matches your scheduled dose'
                                      : 'Medicine does NOT match schedule!',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (_model.detectedText.isNotEmpty) ...[
                        Text(
                          'Text detected on packaging foil:',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          _model.detectedText,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // Vernacular Spoken Voice Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up_rounded,
                                color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _model.voiceAlert,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
