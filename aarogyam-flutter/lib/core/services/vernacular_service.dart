import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_service.dart';
import 'dadi_ma_service.dart';
import '../models/medication_schedule.dart';

enum AppLanguage { hindi, marathi, english }

class VernacularService extends ChangeNotifier {
  static final VernacularService _instance = VernacularService._internal();
  factory VernacularService() => _instance;
  VernacularService._internal();

  AppLanguage _currentLanguage = AppLanguage.hindi;
  FlutterTts? _flutterTts;
  bool _isPlaying = false;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isPlaying => _isPlaying;

  String get langCode {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.marathi:
        return 'mr';
      case AppLanguage.english:
        return 'en';
    }
  }

  String get langDisplayName {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return 'हिंदी';
      case AppLanguage.marathi:
        return 'मराठी';
      case AppLanguage.english:
        return 'English';
    }
  }

  // ---------------------------------------------------------------------------
  // Comprehensive Trilingual Dictionary
  // ---------------------------------------------------------------------------
  static const Map<String, Map<AppLanguage, String>> _dict = {
    // App & Branding
    'appName': {
      AppLanguage.hindi: 'आरोग्यम्',
      AppLanguage.marathi: 'आरोग्यम्',
      AppLanguage.english: 'Aarogyam',
    },
    'appSubtitle': {
      AppLanguage.hindi: 'आरोग्य साथी (Guardian)',
      AppLanguage.marathi: 'आरोग्य मार्गदर्शक (Guardian)',
      AppLanguage.english: 'Aarogyam Guardian',
    },
    'emergencySos': {
      AppLanguage.hindi: 'आपातकालीन संपर्क (SOS)',
      AppLanguage.marathi: 'तातडीचा संपर्क (SOS)',
      AppLanguage.english: 'Emergency SOS',
    },
    'sosDialogTitle': {
      AppLanguage.hindi: '🚨 आपातकालीन चिकित्सा सहायता',
      AppLanguage.marathi: '🚨 तातडीची वैद्यकीय मदत',
      AppLanguage.english: '🚨 Emergency Medical Assistance',
    },
    'sosDialogDesc': {
      AppLanguage.hindi: 'क्या आप राष्ट्रीय आपातकालीन एम्बुलेंस सेवा (108) पर तुरंत कॉल करना चाहते हैं?',
      AppLanguage.marathi: 'तुम्हाला राष्ट्रीय रुग्णवाहिका सेवा (108) वर त्वरित कॉल करायचा आहे का?',
      AppLanguage.english: 'Do you want to immediately call the National Emergency Ambulance Service (108)?',
    },
    'call108': {
      AppLanguage.hindi: '📞 108 पर कॉल करें',
      AppLanguage.marathi: '📞 108 वर कॉल करा',
      AppLanguage.english: '📞 Call 108 Now',
    },
    'cancel': {
      AppLanguage.hindi: 'रद्द करें',
      AppLanguage.marathi: 'रद्द करा',
      AppLanguage.english: 'Cancel',
    },

    // Dadi-Ma Voice Guide & Companion
    'dadiMaVoiceGuide': {
      AppLanguage.hindi: 'दादी-माँ वॉयस गाइड (Voice Guide)',
      AppLanguage.marathi: 'दादी-माँ वॉयस गाइड (Voice Guide)',
      AppLanguage.english: 'Dadi-Ma Voice Guide',
    },
    'dadiMaGreeting': {
      AppLanguage.hindi: 'नमस्ते! मैं आपकी आरोग्य साथी (दादी-माँ) हूँ। समय पर दवा लें और स्वस्थ रहें।',
      AppLanguage.marathi: 'नमस्कार! मी तुमची आरोग्य मार्गदर्शक (दादी-माँ). वेळेवर औषध घ्या आणि निरोगी राहा.',
      AppLanguage.english: 'Hello! I am your Aarogyam voice guide. Take your medicines on time and stay healthy.',
    },
    'dadiMaAskButton': {
      AppLanguage.hindi: 'दादी-माँ से पूछें (Ask Dadi-Ma)',
      AppLanguage.marathi: 'आजीशी बोला (Ask Dadi-Ma)',
      AppLanguage.english: 'Ask Dadi-Ma',
    },
    'dadiMaCompanionTitle': {
      AppLanguage.hindi: 'दादी-माँ आरोग्य साथी',
      AppLanguage.marathi: 'दादी-माँ आरोग्य मार्गदर्शक',
      AppLanguage.english: 'Dadi-Ma Health Companion',
    },
    'dadiMaTabChat': {
      AppLanguage.hindi: 'बातचीत (Chat)',
      AppLanguage.marathi: 'संवाद (Chat)',
      AppLanguage.english: 'Chat & Voice',
    },
    'dadiMaTabRemedies': {
      AppLanguage.hindi: 'घरेलू नुस्खे (Remedies)',
      AppLanguage.marathi: 'घरगुती उपाय (Remedies)',
      AppLanguage.english: 'Home Remedies',
    },
    'dadiMaTabGuidance': {
      AppLanguage.hindi: 'दैनिक सलाह (Daily Advice)',
      AppLanguage.marathi: 'दैनिक सल्ला (Daily Advice)',
      AppLanguage.english: 'Daily Guidance',
    },
    'dadiMaAskHint': {
      AppLanguage.hindi: 'दादी-माँ से स्वास्थ्य या दवाओं के बारे में पूछें...',
      AppLanguage.marathi: 'आजीला आरोग्याबद्दल किंवा औषधांबद्दल काहीही विचारा...',
      AppLanguage.english: 'Ask Dadi-Ma about your medicines or health...',
    },
    'dadiMaChipMyMeds': {
      AppLanguage.hindi: 'मेरी अगली दवा क्या है?',
      AppLanguage.marathi: 'माझे पुढील औषध काय आहे?',
      AppLanguage.english: 'What is my next medicine?',
    },
    'dadiMaChipCough': {
      AppLanguage.hindi: 'खांसी-जुकाम का घरेलू नुस्खा',
      AppLanguage.marathi: 'सर्दी-खोकल्याचा घरगुती उपाय',
      AppLanguage.english: 'Cough & cold home remedy',
    },
    'dadiMaChipAcidity': {
      AppLanguage.hindi: 'एसिडिटी व पेट गैस का उपाय',
      AppLanguage.marathi: 'अ‍ॅसिडिटी व गॅसचा उपाय',
      AppLanguage.english: 'Acidity & gas relief remedy',
    },
    'dadiMaChipJointPain': {
      AppLanguage.hindi: 'घुटने व जोड़ों का दर्द',
      AppLanguage.marathi: 'सांधेदुखीचा उपाय',
      AppLanguage.english: 'Joint pain relief remedy',
    },
    'dadiMaChipBpDiet': {
      AppLanguage.hindi: 'बीपी में खान-पान का नियम',
      AppLanguage.marathi: 'उच्च रक्तदाब आहार सल्ला',
      AppLanguage.english: 'Blood pressure diet guidance',
    },
    'dadiMaChipSugarDiet': {
      AppLanguage.hindi: 'शुगर में क्या परहेज करें?',
      AppLanguage.marathi: 'मधुमेहात काय काळजी घ्यावी?',
      AppLanguage.english: 'Diabetes precautions & diet',
    },
    'dadiMaSlowSpeech': {
      AppLanguage.hindi: 'धीमी आवाज (Slow)',
      AppLanguage.marathi: 'हळू आवाज (Slow)',
      AppLanguage.english: 'Slow Voice (0.8x)',
    },
    'dadiMaIngredients': {
      AppLanguage.hindi: 'आवश्यक सामग्री:',
      AppLanguage.marathi: 'लागणारे साहित्य:',
      AppLanguage.english: 'Ingredients:',
    },
    'dadiMaPreparation': {
      AppLanguage.hindi: 'बनाने की विधि:',
      AppLanguage.marathi: 'बनवण्याची कृती:',
      AppLanguage.english: 'Preparation:',
    },
    'dadiMaPrecaution': {
      AppLanguage.hindi: 'सावधानी व परहेज:',
      AppLanguage.marathi: 'काळजी व पथ्य:',
      AppLanguage.english: 'Precautions:',
    },
    'dadiMaEmergencySOS': {
      AppLanguage.hindi: '🚨 आपातकालीन चेतावनी (Emergency Alert)',
      AppLanguage.marathi: '🚨 तातडीची सूचना (Emergency Alert)',
      AppLanguage.english: '🚨 Emergency Medical Alert',
    },
    'dadiMaExplainRxAction': {
      AppLanguage.hindi: 'दादी-माँ से पर्चा समझें (Explain Rx)',
      AppLanguage.marathi: 'आजीकडून प्रिस्क्रिप्शन समजून घ्या',
      AppLanguage.english: 'Explain with Dadi-Ma',
    },

    // Next Dose Card
    'nextDose': {
      AppLanguage.hindi: 'अगली खुराक',
      AppLanguage.marathi: 'पुढील डोस',
      AppLanguage.english: 'Next Dose',
    },
    'allDosesCompleted': {
      AppLanguage.hindi: 'आज का कोटा पूरा! (All Doses Done)',
      AppLanguage.marathi: 'आजचा कोटा पूर्ण! (All Doses Done)',
      AppLanguage.english: 'All Doses Completed for Today!',
    },
    'allDosesCompletedDesc': {
      AppLanguage.hindi: 'शाबाश! आपने आज की सभी दवाइयाँ समय पर ले ली हैं।',
      AppLanguage.marathi: 'छान! तुम्ही आजची सर्व औषधे वेळेवर घेतली आहेत.',
      AppLanguage.english: 'Great job! You have taken all scheduled medications for today.',
    },
    'markTaken': {
      AppLanguage.hindi: '✓ दवा ली (Taken)',
      AppLanguage.marathi: '✓ औषध घेतले (Taken)',
      AppLanguage.english: '✓ Mark Taken',
    },
    'verifyBlister': {
      AppLanguage.hindi: '🔍 पट्टी जांचें (Verify)',
      AppLanguage.marathi: '🔍 पट्टी तपासा (Verify)',
      AppLanguage.english: '🔍 Verify Strip',
    },

    // Adherence Ring Card
    'adherenceTitle': {
      AppLanguage.hindi: 'आज का दवा अनुपालन (Adherence)',
      AppLanguage.marathi: 'आजचे औषध पालन (Adherence)',
      AppLanguage.english: 'Today Medication Adherence',
    },
    'dayStreak': {
      AppLanguage.hindi: 'दिन स्ट्रीक 🔥',
      AppLanguage.marathi: 'दिवस स्ट्रीक 🔥',
      AppLanguage.english: 'day streak 🔥',
    },

    // Key Actions Grid
    'keyActionsHeader': {
      AppLanguage.hindi: 'मुख्य सुविधाएँ / Key Actions',
      AppLanguage.marathi: 'महत्त्वाच्या कृती / Key Actions',
      AppLanguage.english: 'Key Actions',
    },
    'actionScanRxTitle': {
      AppLanguage.hindi: 'पर्चा स्कैन करें',
      AppLanguage.marathi: 'प्रिस्क्रिप्शन स्कॅन करा',
      AppLanguage.english: 'Scan Prescription',
    },
    'actionScanRxSub': {
      AppLanguage.hindi: 'Scan Prescription',
      AppLanguage.marathi: 'Scan Prescription',
      AppLanguage.english: 'Digitize Doctor Rx',
    },
    'actionVerifyStripTitle': {
      AppLanguage.hindi: 'दवा पट्टी जांचें',
      AppLanguage.marathi: 'औषध पट्टी तपासा',
      AppLanguage.english: 'Verify Blister Strip',
    },
    'actionVerifyStripSub': {
      AppLanguage.hindi: 'Verify Blister Strip',
      AppLanguage.marathi: 'Verify Blister Strip',
      AppLanguage.english: 'Foil Safety Verifier',
    },
    'actionScheduleTitle': {
      AppLanguage.hindi: 'दवा समय सारणी',
      AppLanguage.marathi: 'औषध वेळापत्रक',
      AppLanguage.english: 'Daily Schedule',
    },
    'actionScheduleSub': {
      AppLanguage.hindi: 'Daily Schedule',
      AppLanguage.marathi: 'Daily Schedule',
      AppLanguage.english: 'Timetable & Logs',
    },
    'actionVoiceTitle': {
      AppLanguage.hindi: 'दादी-माँ आवाज़',
      AppLanguage.marathi: 'दादी-माँ आवाज',
      AppLanguage.english: 'Voice Assistant',
    },
    'actionVoiceSub': {
      AppLanguage.hindi: 'Voice Assistant',
      AppLanguage.marathi: 'Voice Assistant',
      AppLanguage.english: 'Vernacular Audio',
    },

    // Timeline
    'timelineHeader': {
      AppLanguage.hindi: 'आज की दवाइयाँ / Timeline',
      AppLanguage.marathi: 'आजची औषधे / Timeline',
      AppLanguage.english: 'Today Medications / Timeline',
    },
    'viewAll': {
      AppLanguage.hindi: 'सभी देखें',
      AppLanguage.marathi: 'सर्व पहा',
      AppLanguage.english: 'View All',
    },
    'noMedsScheduled': {
      AppLanguage.hindi: 'कोई दवा निर्धारित नहीं है',
      AppLanguage.marathi: 'कोणतेही औषध ठरवलेले नाही',
      AppLanguage.english: 'No medications scheduled for today',
    },
    'noMedsScheduledDesc': {
      AppLanguage.hindi: 'ऊपर दिए गए "पर्चा स्कैन करें" बटन से नया पर्चा जोड़ें।',
      AppLanguage.marathi: 'नवीन प्रिस्क्रिप्शन जोडण्यासाठी वरील "स्कॅन करा" बटण वापरा.',
      AppLanguage.english: 'Use "Scan Prescription" above to add new doctor prescriptions.',
    },
    'foilVerifiedBadge': {
      AppLanguage.hindi: '✓ फॉइल सत्यापित (Foil Verified)',
      AppLanguage.marathi: '✓ फॉइल पडताळलेले (Foil Verified)',
      AppLanguage.english: '✓ Foil Verified',
    },

    // Prescription Scanner (ReportScannerWidget)
    'rxScannerTitle': {
      AppLanguage.hindi: 'पर्चा स्कैनर (Prescription AI)',
      AppLanguage.marathi: 'प्रिस्क्रिप्शन स्कॅनर (Prescription AI)',
      AppLanguage.english: 'Prescription AI Scanner',
    },
    'rxHeroHeader': {
      AppLanguage.hindi: 'हस्तलिखित पर्चा स्कैन करें',
      AppLanguage.marathi: 'हस्तलिखित प्रिस्क्रिप्शन स्कॅन करा',
      AppLanguage.english: 'Scan Handwritten Prescription',
    },
    'rxHeroSub': {
      AppLanguage.hindi: 'डॉक्टर का पर्चा कैमरे से खींचें या गैलरी से चुनें। AI इसे तुरंत समझकर आपकी भाषा में समझाएगा।',
      AppLanguage.marathi: 'डॉक्टरांचे प्रिस्क्रिप्शन कॅमेऱ्याने किंवा गॅलरीतून निवडा. AI त्याचे तुमच्या भाषेत विश्लेषण करेल.',
      AppLanguage.english: 'Capture prescription via camera or gallery. AI digitizes doses and reads them aloud.',
    },
    'btnCamera': {
      AppLanguage.hindi: 'कैमरा (Camera)',
      AppLanguage.marathi: 'कॅमेरा (Camera)',
      AppLanguage.english: 'Camera',
    },
    'btnGallery': {
      AppLanguage.hindi: 'गैलरी (Gallery)',
      AppLanguage.marathi: 'गॅलरी (Gallery)',
      AppLanguage.english: 'Gallery',
    },
    'analyzingPrescription': {
      AppLanguage.hindi: 'IBM Granite AI पर्चा समझ रहा है...',
      AppLanguage.marathi: 'IBM Granite AI प्रिस्क्रिप्शन तपासत आहे...',
      AppLanguage.english: 'IBM Granite AI is digitizing prescription...',
    },
    'privacyBadgeTitle': {
      AppLanguage.hindi: 'निजता सुरक्षित (Privacy Protected)',
      AppLanguage.marathi: 'गोपनीयता सुरक्षित (Privacy Protected)',
      AppLanguage.english: 'Privacy Protected (Edge De-ID)',
    },
    'privacyBadgeDesc': {
      AppLanguage.hindi: 'मरीज का नाम व आधार नंबर ऑन-डिवाइस मास्क कर दिए गए हैं',
      AppLanguage.marathi: 'रुग्णाचे नाव व आधार क्रमांक डिव्हाइसवर मास्क केले आहेत',
      AppLanguage.english: 'Patient Aadhaar & Contact info masked on device',
    },
    'diagnosis': {
      AppLanguage.hindi: 'निदान (Diagnosis):',
      AppLanguage.marathi: 'निदान (Diagnosis):',
      AppLanguage.english: 'Diagnosis:',
    },
    'listenFullRx': {
      AppLanguage.hindi: 'दादी-माँ से पूरा पर्चा सुनें',
      AppLanguage.marathi: 'दादी-माँ कडून संपूर्ण प्रिस्क्रिप्शन ऐका',
      AppLanguage.english: 'Listen to Full Prescription with Dadi-Ma',
    },
    'medsInRx': {
      AppLanguage.hindi: 'पर्चे में पहचानी गई दवाइयाँ',
      AppLanguage.marathi: 'प्रिस्क्रिप्शनमधील औषधे',
      AppLanguage.english: 'Medications in Prescription',
    },
    'duration': {
      AppLanguage.hindi: 'अवधि:',
      AppLanguage.marathi: 'कालावधी:',
      AppLanguage.english: 'Duration:',
    },
    'days': {
      AppLanguage.hindi: 'दिन',
      AppLanguage.marathi: 'दिवस',
      AppLanguage.english: 'days',
    },
    'btnAddToSchedule': {
      AppLanguage.hindi: '✓ सभी दवाइयाँ शेड्यूल में जोड़ें',
      AppLanguage.marathi: '✓ सर्व औषधे वेळापत्रकात जोडा',
      AppLanguage.english: '✓ Add All to Schedule',
    },
    'rxAddedToast': {
      AppLanguage.hindi: '✓ पर्चे की दवाइयाँ आपकी समय सारणी में जोड़ दी गई हैं!',
      AppLanguage.marathi: '✓ औषधे तुमच्या वेळापत्रकात यशस्वीपणे जोडली गेली आहेत!',
      AppLanguage.english: '✓ Prescription medicines added to your schedule!',
    },

    // Blister Verifier (BlisterVerifierWidget)
    'blisterVerifierTitle': {
      AppLanguage.hindi: 'दवा पट्टी सत्यापन (Blister Verifier)',
      AppLanguage.marathi: 'औषध पट्टी पडताळणी (Blister Verifier)',
      AppLanguage.english: 'Blister Strip Verifier',
    },
    'targetMedicineLabel': {
      AppLanguage.hindi: 'जांची जाने वाली निर्धारित दवा (Target Medicine):',
      AppLanguage.marathi: 'तपासले जाणारे ठरवलेले औषध (Target Medicine):',
      AppLanguage.english: 'Target Prescribed Medicine:',
    },
    'blisterHeroHeader': {
      AppLanguage.hindi: 'दवा की पट्टी (Blister Pack) स्कैन करें',
      AppLanguage.marathi: 'औषधाची पट्टी (Blister Pack) स्कॅन करा',
      AppLanguage.english: 'Scan Medicine Blister Strip',
    },
    'blisterHeroSub': {
      AppLanguage.hindi: 'दवा की फॉइल पट्टी को कैमरे के सामने रखें। AI तुरंत ब्रांड, सॉल्ट नाम और एक्सपायरी डेट जांचेगा।',
      AppLanguage.marathi: 'औषधाची पट्टी कॅमेऱ्यासमोर धरा. AI ब्रँड, सॉल्ट आणि एक्सपायरी तारीख तपासेल.',
      AppLanguage.english: 'Hold blister strip in front of camera. AI checks drug name, strength & expiry date.',
    },
    'btnFoilPhoto': {
      AppLanguage.hindi: 'पट्टी फोटो खींचें',
      AppLanguage.marathi: 'पट्टीचा फोटो काढा',
      AppLanguage.english: 'Capture Foil Photo',
    },
    'btnFoilGallery': {
      AppLanguage.hindi: 'गैलरी से चुनें',
      AppLanguage.marathi: 'गॅलरीतून निवडा',
      AppLanguage.english: 'Select from Gallery',
    },
    'verifyingFoilText': {
      AppLanguage.hindi: 'दवा की पट्टी का सत्यापन चल रहा है...',
      AppLanguage.marathi: 'औषध पट्टीची पडताळणी सुरू आहे...',
      AppLanguage.english: 'Verifying foil strip with ML Kit & OCR...',
    },
    'confidenceScore': {
      AppLanguage.hindi: 'सटीकता स्कोर:',
      AppLanguage.marathi: 'अचूकता स्कोअर:',
      AppLanguage.english: 'Confidence Score:',
    },
    'btnMarkSafeDose': {
      AppLanguage.hindi: '✓ सुरक्षित दवा - खुराक पूरी दर्ज करें',
      AppLanguage.marathi: '✓ सुरक्षित औषध - डोस नोंदवा',
      AppLanguage.english: '✓ Safe Medicine - Mark Taken',
    },
    'doseMarkedSuccess': {
      AppLanguage.hindi: '✓ खुराक सुरक्षित रूप से पूरी दर्ज की गई!',
      AppLanguage.marathi: '✓ डोस यशस्वीपणे पूर्ण नोंदवला गेला!',
      AppLanguage.english: '✓ Dose marked as verified and taken!',
    },

    // Schedule Hub (ReminderPageWidget)
    'scheduleHubTitle': {
      AppLanguage.hindi: 'दवा समय सारणी (Schedule)',
      AppLanguage.marathi: 'औषध वेळापत्रक (Schedule)',
      AppLanguage.english: 'Medication Schedule',
    },
    'tabTodayDoses': {
      AppLanguage.hindi: 'आज की खुराकें',
      AppLanguage.marathi: 'आजचे डोस',
      AppLanguage.english: 'Today Doses',
    },
    'tabActiveMeds': {
      AppLanguage.hindi: 'सक्रिय दवाइयाँ',
      AppLanguage.marathi: 'सक्रिय औषधे',
      AppLanguage.english: 'Active Medicines',
    },
    'tabRxHistory': {
      AppLanguage.hindi: 'पर्चा इतिहास',
      AppLanguage.marathi: 'प्रिस्क्रिप्शन इतिहास',
      AppLanguage.english: 'Prescriptions',
    },
    'btnAddMedicine': {
      AppLanguage.hindi: 'दवा जोड़ें',
      AppLanguage.marathi: 'औषध जोडा',
      AppLanguage.english: 'Add Medicine',
    },
    'modalAddMedTitle': {
      AppLanguage.hindi: 'नई दवा जोड़ें (Add Medicine)',
      AppLanguage.marathi: 'नवीन औषध जोडा (Add Medicine)',
      AppLanguage.english: 'Add New Medicine',
    },
    'inputMedNameLabel': {
      AppLanguage.hindi: 'दवा का नाम (e.g. Paracetamol)',
      AppLanguage.marathi: 'औषधाचे नाव (e.g. Paracetamol)',
      AppLanguage.english: 'Medicine Name (e.g. Paracetamol)',
    },
    'inputDosageLabel': {
      AppLanguage.hindi: 'खुराक / मात्रा (e.g. 500mg 1 Tablet)',
      AppLanguage.marathi: 'डोस / प्रमाण (e.g. 500mg 1 Tablet)',
      AppLanguage.english: 'Dosage (e.g. 500mg 1 Tablet)',
    },
    'scheduleSlotsLabel': {
      AppLanguage.hindi: 'दवा लेने का समय (Schedule Slots):',
      AppLanguage.marathi: 'औषध घेण्याची वेळ (Schedule Slots):',
      AppLanguage.english: 'Schedule Slots:',
    },
    'slotMorningChip': {
      AppLanguage.hindi: '☀️ सुबह',
      AppLanguage.marathi: '☀️ सकाळ',
      AppLanguage.english: '☀️ Morning',
    },
    'slotAfternoonChip': {
      AppLanguage.hindi: '🌤️ दोपहर',
      AppLanguage.marathi: '🌤️ दुपार',
      AppLanguage.english: '🌤️ Noon',
    },
    'slotNightChip': {
      AppLanguage.hindi: '🌙 रात',
      AppLanguage.marathi: '🌙 रात्र',
      AppLanguage.english: '🌙 Night',
    },
    'foodRelationLabel': {
      AppLanguage.hindi: 'भोजन संबंध (Food Relation)',
      AppLanguage.marathi: 'जेवणाशी संबंध (Food Relation)',
      AppLanguage.english: 'Food Relation',
    },
    'foodAfterOption': {
      AppLanguage.hindi: '🍽️ भोजन के बाद (After Food)',
      AppLanguage.marathi: '🍽️ जेवणानंतर (After Food)',
      AppLanguage.english: '🍽️ After Food',
    },
    'foodBeforeOption': {
      AppLanguage.hindi: '🍽️ भोजन से पहले / खाली पेट (Before Food)',
      AppLanguage.marathi: '🍽️ जेवणापूर्वी / उपाशीपोटी (Before Food)',
      AppLanguage.english: '🍽️ Before Food (Empty Stomach)',
    },
    'foodWithOption': {
      AppLanguage.hindi: '🍽️ भोजन के साथ (With Food)',
      AppLanguage.marathi: '🍽️ जेवणासोबत (With Food)',
      AppLanguage.english: '🍽️ With Food',
    },
    'btnSaveSchedule': {
      AppLanguage.hindi: 'शेड्यूल में सुरक्षित करें',
      AppLanguage.marathi: 'वेळापत्रकात सेव्ह करा',
      AppLanguage.english: 'Save to Schedule',
    },
    'noActiveMeds': {
      AppLanguage.hindi: 'कोई सक्रिय दवा नहीं मिली',
      AppLanguage.marathi: 'कोणतेही सक्रिय औषध आढळले नाही',
      AppLanguage.english: 'No active medicines found',
    },
    'noRxHistory': {
      AppLanguage.hindi: 'कोई पर्चा इतिहास नहीं मिला',
      AppLanguage.marathi: 'कोणताही प्रिस्क्रिप्शन इतिहास नाही',
      AppLanguage.english: 'No prescription history found',
    },
    'medAddedSuccess': {
      AppLanguage.hindi: '✓ नई दवा समय सारणी में जोड़ दी गई है!',
      AppLanguage.marathi: '✓ नवीन औषध वेळापत्रकात जोडले गेले आहे!',
      AppLanguage.english: '✓ New medicine added to schedule!',
    },
    'validationFillName': {
      AppLanguage.hindi: 'कृपया दवा का नाम दर्ज करें',
      AppLanguage.marathi: 'कृपया औषधाचे नाव प्रविष्ट करा',
      AppLanguage.english: 'Please enter medicine name',
    },
  };

  /// Lookup localized string by key
  String t(String key) {
    final entry = _dict[key];
    if (entry != null) {
      return entry[_currentLanguage] ?? entry[AppLanguage.hindi] ?? key;
    }
    return key;
  }

  /// Translate slot name dynamically (Morning -> सुबह / सकाळ / Morning)
  String slotName(String slot) {
    final s = slot.toLowerCase();
    if (s.contains('morn') || s.contains('सुबह') || s.contains('सकाळ')) {
      switch (_currentLanguage) {
        case AppLanguage.hindi:
          return 'सुबह (Morning)';
        case AppLanguage.marathi:
          return 'सकाळ (Morning)';
        case AppLanguage.english:
          return 'Morning';
      }
    } else if (s.contains('afternoon') || s.contains('noon') || s.contains('दोपहर') || s.contains('दुपार')) {
      switch (_currentLanguage) {
        case AppLanguage.hindi:
          return 'दोपहर (Noon)';
        case AppLanguage.marathi:
          return 'दुपार (Noon)';
        case AppLanguage.english:
          return 'Afternoon';
      }
    } else if (s.contains('night') || s.contains('रात') || s.contains('रात्र')) {
      switch (_currentLanguage) {
        case AppLanguage.hindi:
          return 'रात (Night)';
        case AppLanguage.marathi:
          return 'रात्र (Night)';
        case AppLanguage.english:
          return 'Night';
      }
    }
    return slot;
  }

  /// Translate food relation dynamically (After Food -> भोजन के बाद / जेवणानंतर / After Food)
  String foodRelation(String relation) {
    final r = relation.toLowerCase();
    if (r.contains('before') || r.contains('खाली पेट') || r.contains('उपाशी')) {
      switch (_currentLanguage) {
        case AppLanguage.hindi:
          return 'भोजन से पहले (खाली पेट)';
        case AppLanguage.marathi:
          return 'जेवणापूर्वी (उपाशीपोटी)';
        case AppLanguage.english:
          return 'Before Food';
      }
    } else if (r.contains('with') || r.contains('साथ') || r.contains('सोबत')) {
      switch (_currentLanguage) {
        case AppLanguage.hindi:
          return 'भोजन के साथ';
        case AppLanguage.marathi:
          return 'जेवणासोबत';
        case AppLanguage.english:
          return 'With Food';
      }
    } else if (r.contains('breakfast') || r.contains('नाश्ता')) {
      switch (_currentLanguage) {
        case AppLanguage.hindi:
          return 'नाश्ते के बाद';
        case AppLanguage.marathi:
          return 'नाश्त्यानंतर';
        case AppLanguage.english:
          return 'After Breakfast';
      }
    } else {
      switch (_currentLanguage) {
        case AppLanguage.hindi:
          return 'भोजन के बाद';
        case AppLanguage.marathi:
          return 'जेवणानंतर';
        case AppLanguage.english:
          return 'After Food';
      }
    }
  }

  /// Get localized instruction for medicine
  String getMedicineInstruction(MedicineItem med) {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return med.instructionsHindi.isNotEmpty ? med.instructionsHindi : med.instructionsEnglish;
      case AppLanguage.marathi:
        return med.instructionsMarathi.isNotEmpty ? med.instructionsMarathi : med.instructionsHindi;
      case AppLanguage.english:
        return med.instructionsEnglish.isNotEmpty ? med.instructionsEnglish : med.instructionsHindi;
    }
  }

  /// Get localized summary for prescription
  String getPrescriptionSummary(PrescriptionRecord rx) {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return rx.vernacularSummaryHindi.isNotEmpty ? rx.vernacularSummaryHindi : rx.vernacularSummaryEnglish;
      case AppLanguage.marathi:
        return rx.vernacularSummaryMarathi.isNotEmpty ? rx.vernacularSummaryMarathi : rx.vernacularSummaryHindi;
      case AppLanguage.english:
        return rx.vernacularSummaryEnglish.isNotEmpty ? rx.vernacularSummaryEnglish : rx.vernacularSummaryHindi;
    }
  }

  /// Get localized message for blister verification
  String getVerificationMessage(BlisterVerificationResult result) {
    switch (_currentLanguage) {
      case AppLanguage.hindi:
        return result.vernacularMessageHindi;
      case AppLanguage.marathi:
        return result.vernacularMessageMarathi;
      case AppLanguage.english:
        return result.vernacularMessageEnglish;
    }
  }

  bool get _isTestEnvironment {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('aarogyam_language_code') ?? 'hi';
    if (savedCode == 'mr') {
      _currentLanguage = AppLanguage.marathi;
    } else if (savedCode == 'en') {
      _currentLanguage = AppLanguage.english;
    } else {
      _currentLanguage = AppLanguage.hindi;
    }

    if (_isTestEnvironment) {
      return;
    }

    await _initNativeTts();
  }

  Future<void> _initNativeTts() async {
    if (_isTestEnvironment) return;
    try {
      _flutterTts ??= FlutterTts();
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(1.0);
      await _flutterTts?.setSpeechRate(0.48);

      final ttsLocale = langCode == 'hi' ? 'hi-IN' : (langCode == 'mr' ? 'mr-IN' : 'en-IN');
      try {
        await _flutterTts?.setLanguage(ttsLocale);
      } catch (_) {}

      _flutterTts?.setStartHandler(() {
        _isPlaying = true;
        notifyListeners();
      });

      _flutterTts?.setCompletionHandler(() {
        _isPlaying = false;
        notifyListeners();
      });

      _flutterTts?.setErrorHandler((msg) {
        debugPrint('[VernacularService] FlutterTts error: $msg');
        _isPlaying = false;
        notifyListeners();
      });

      _flutterTts?.setCancelHandler(() {
        _isPlaying = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Native TTS init error: $e');
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aarogyam_language_code', langCode);

    try {
      DadiMaService().resetForLanguage(lang);
    } catch (_) {}

    if (!_isTestEnvironment) {
      try {
        await _initNativeTts();
        final ttsLocale = langCode == 'hi' ? 'hi-IN' : (langCode == 'mr' ? 'mr-IN' : 'en-IN');
        await _flutterTts?.setLanguage(ttsLocale);
      } catch (_) {}
    }

    notifyListeners();
  }

  /// Speak text via IBM Watson TTS with on-device Native TTS fallback
  Future<void> speakText(
    String text, {
    String? customLang,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    final targetLang = customLang ?? langCode;
    _isPlaying = true;
    notifyListeners();
    onStart?.call();

    if (_isTestEnvironment) {
      _isPlaying = false;
      notifyListeners();
      onComplete?.call();
      return;
    }

    // 1. Try IBM Watson TTS binary stream first
    bool playedViaWatson = false;
    try {
      playedViaWatson = await AudioService.instance.speakVernacularText(
        text,
        language: targetLang,
        onStart: () {
          _isPlaying = true;
          notifyListeners();
          onStart?.call();
        },
        onComplete: () {
          _isPlaying = false;
          notifyListeners();
          onComplete?.call();
        },
        onError: (err) {
          debugPrint('[VernacularService] Watson TTS failed, falling back to Native TTS.');
        },
      );
    } catch (e) {
      debugPrint('[VernacularService] Watson TTS error: $e');
      playedViaWatson = false;
    }

    // 2. Fall back to on-device Android/Flutter native TTS
    if (!playedViaWatson) {
      await _speakNative(
        text,
        targetLang,
        onComplete: onComplete,
      );
    }
  }

  Future<void> _speakNative(
    String text,
    String targetLang, {
    VoidCallback? onComplete,
  }) async {
    if (_isTestEnvironment) {
      _isPlaying = false;
      notifyListeners();
      onComplete?.call();
      return;
    }

    try {
      await _initNativeTts();

      // Configure speech rate (slower for elderly Dadi-Ma persona)
      final isSlow = DadiMaService().isSlowSpeech;
      final speechRate = isSlow ? 0.35 : 0.48;
      await _flutterTts?.setSpeechRate(speechRate);
      await _flutterTts?.setVolume(1.0);
      await _flutterTts?.setPitch(1.0);

      // Select proper locale with graceful fallback
      final ttsLocale = targetLang == 'hi' ? 'hi-IN' : (targetLang == 'mr' ? 'mr-IN' : 'en-IN');
      try {
        final isAvailable = await _flutterTts?.isLanguageAvailable(ttsLocale);
        if (isAvailable == 1 || isAvailable == true) {
          await _flutterTts?.setLanguage(ttsLocale);
        } else {
          if (targetLang == 'mr') {
            await _flutterTts?.setLanguage('hi-IN');
          } else {
            await _flutterTts?.setLanguage('en-IN');
          }
        }
      } catch (_) {
        await _flutterTts?.setLanguage('hi-IN');
      }

      _flutterTts?.setCompletionHandler(() {
        _isPlaying = false;
        notifyListeners();
        onComplete?.call();
      });

      _flutterTts?.setErrorHandler((msg) {
        debugPrint('[VernacularService] Native TTS Error: $msg');
        _isPlaying = false;
        notifyListeners();
        onComplete?.call();
      });

      _flutterTts?.setCancelHandler(() {
        _isPlaying = false;
        notifyListeners();
        onComplete?.call();
      });

      _isPlaying = true;
      notifyListeners();

      await _flutterTts?.speak(text);
    } catch (e) {
      debugPrint('[VernacularService] Native TTS invocation failed: $e');
      _isPlaying = false;
      notifyListeners();
      onComplete?.call();
    }
  }

  Future<void> stopSpeech() async {
    if (!_isTestEnvironment) {
      try {
        await AudioService.instance.stop();
        await _flutterTts?.stop();
      } catch (_) {}
    }
    _isPlaying = false;
    notifyListeners();
  }

  /// Dadi-Ma: Announce the upcoming dose aloud
  Future<void> speakNextDose(DoseLogEntry? dose) async {
    if (dose == null) {
      final msg = _currentLanguage == AppLanguage.hindi
          ? 'बहुत बढ़िया! आज की सभी दवाइयाँ पूरी हो चुकी हैं।'
          : (_currentLanguage == AppLanguage.marathi
              ? 'छान! आजची सर्व औषधे पूर्ण झाली आहेत.'
              : 'Great job! All scheduled medications for today have been completed.');
      await speakText(msg);
      return;
    }

    String msg;
    if (_currentLanguage == AppLanguage.hindi) {
      msg = 'आपकी अगली दवा ${dose.medicineName} है, समय ${dose.scheduledTime}। यह ${dose.foodRelation == "Before Food" ? "भोजन से पहले" : "भोजन के बाद"} लेनी है।';
    } else if (_currentLanguage == AppLanguage.marathi) {
      msg = 'तुमचे पुढील औषध ${dose.medicineName} आहे, वेळ ${dose.scheduledTime}. हे ${dose.foodRelation == "Before Food" ? "जेवणापूर्वी" : "जेवणानंतर"} घ्यायचे आहे.';
    } else {
      msg = 'Your next dose is ${dose.medicineName} at ${dose.scheduledTime}, ${dose.foodRelation}.';
    }

    await speakText(msg);
  }

  /// Dadi-Ma: Announce Blister Verification result aloud
  Future<void> speakVerificationResult(BlisterVerificationResult result) async {
    String msg;
    if (_currentLanguage == AppLanguage.hindi) {
      msg = result.vernacularMessageHindi;
    } else if (_currentLanguage == AppLanguage.marathi) {
      msg = result.vernacularMessageMarathi;
    } else {
      msg = result.vernacularMessageEnglish;
    }
    await speakText(msg);
  }

  /// Dadi-Ma: Read full prescription aloud
  Future<void> speakPrescription(PrescriptionRecord rx) async {
    String intro;
    if (_currentLanguage == AppLanguage.hindi) {
      intro = 'यह ${rx.doctorName} द्वारा दिया गया पर्चा है। इसमें कुल ${rx.medicines.length} दवाइयाँ हैं। ';
      for (int i = 0; i < rx.medicines.length; i++) {
        final m = rx.medicines[i];
        intro += 'दवा नंबर ${i + 1}: ${m.name}। ${m.instructionsHindi} ';
      }
    } else if (_currentLanguage == AppLanguage.marathi) {
      intro = 'हे ${rx.doctorName} यांनी दिलेले प्रिस्क्रिप्शन आहे. यात एकूण ${rx.medicines.length} औषधे आहेत. ';
      for (int i = 0; i < rx.medicines.length; i++) {
        final m = rx.medicines[i];
        intro += 'औषध क्रमांक ${i + 1}: ${m.name}. ${m.instructionsMarathi} ';
      }
    } else {
      intro = 'This is the prescription from ${rx.doctorName} with ${rx.medicines.length} medications. ';
      for (int i = 0; i < rx.medicines.length; i++) {
        final m = rx.medicines[i];
        intro += 'Medicine ${i + 1}: ${m.name}, ${m.dosage}. ${m.instructionsEnglish} ';
      }
    }
    await speakText(intro);
  }
}
