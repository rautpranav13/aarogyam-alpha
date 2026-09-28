import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/dadi_ma_models.dart';
import '../models/medication_schedule.dart';
import 'vernacular_service.dart';

class DadiMaService extends ChangeNotifier {
  static final DadiMaService _instance = DadiMaService._internal();
  factory DadiMaService() => _instance;
  DadiMaService._internal();

  final List<DadiMaChatMessage> _messages = [];
  List<AyurvedicRemedy> _remedies = [];
  DadiMaDailyGuidance? _dailyGuidance;
  bool _isLoading = false;
  bool _isSlowSpeech = false;
  String? _currentlySpeakingMessageId;

  List<DadiMaChatMessage> get messages => List.unmodifiable(_messages);
  List<AyurvedicRemedy> get remedies => List.unmodifiable(_remedies);
  DadiMaDailyGuidance? get dailyGuidance => _dailyGuidance;
  bool get isLoading => _isLoading;
  bool get isSlowSpeech => _isSlowSpeech;
  String? get currentlySpeakingMessageId => _currentlySpeakingMessageId;

  String get _backendUrl {
    try {
      if (dotenv.isInitialized) {
        final url = dotenv.env['BACKEND_URL'];
        if (url != null && url.isNotEmpty) {
          return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
        }
      }
    } catch (_) {}
    return 'http://localhost:5001';
  }

  void toggleSlowSpeech() {
    _isSlowSpeech = !_isSlowSpeech;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_messages.isEmpty) {
      _addInitialWelcomeMessage(VernacularService().currentLanguage);
    }
    await fetchRemedies();
    await fetchDailyGuidance();
  }

  void _addInitialWelcomeMessage(AppLanguage lang) {
    String text;
    String speechText;
    if (lang == AppLanguage.marathi) {
      text = 'नमस्कार बाळा! मी तुमची आजी. वेळेवर औषधे घेणे आणि आरोग्याची काळजी घेणे हे माझे ध्येय आहे. मला तुमच्या औषधांविषयी किंवा घरगुती उपचारांविषयी काहीही विचारा.';
      speechText = text;
    } else if (lang == AppLanguage.english) {
      text = 'Hello my dear! I am your Dadi-Ma (Grandmother). I am here to help you understand your medicines and share gentle home care tips. How are you feeling today?';
      speechText = text;
    } else {
      text = 'नमस्ते बेटा! मैं तुम्हारी दादी-माँ हूँ। समय पर दवा लेना और स्वस्थ रहना ही सबसे बड़ा सुख है। तुम मुझसे अपनी दवाओं, परहेज या घरेलू नुस्खों के बारे में कुछ भी पूछ सकते हो।';
      speechText = text;
    }

    _messages.add(
      DadiMaChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        sender: DadiMaSender.dadiMa,
        timestamp: DateTime.now(),
        speechText: speechText,
      ),
    );
    notifyListeners();
  }

  void resetForLanguage(AppLanguage lang) {
    _messages.clear();
    _addInitialWelcomeMessage(lang);
    _remedies = _getLocalFallbackRemedies(lang);
    notifyListeners();
    fetchDailyGuidance();
    fetchRemedies();
  }

  /// Sends a message / question to Dadi-Ma
  Future<void> sendMessage(
    String query, {
    List<MedicineItem>? activeMedications,
    String? diagnosis,
  }) async {
    if (query.trim().isEmpty) return;

    final vernService = VernacularService();
    final langCode = vernService.langCode;

    // 1. Add user message
    final userMsg = DadiMaChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: query.trim(),
      sender: DadiMaSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    // 2. Prepare payload
    final medsPayload = activeMedications?.map((m) => {
          'name': m.name,
          'timing_24hr': [
            if (m.morning) m.morningTime,
            if (m.afternoon) m.afternoonTime,
            if (m.night) m.nightTime,
          ],
          'instructions': m.instructionsEnglish,
          'instructions_vernacular': langCode == 'mr'
              ? m.instructionsMarathi
              : m.instructionsHindi,
        }).toList() ?? [];

    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/dadi-ma/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'query': query,
              'language': langCode,
              'medications': medsPayload,
              'diagnosis': diagnosis ?? 'General Care',
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final isEmergency = data['is_emergency'] == true;
        final responseText = data['response_text'] as String? ?? '';
        final speechText = data['speech_text'] as String? ?? responseText;
        final emergencyWarning = data['emergency_warning'] as String?;
        final actionRequired = data['action_required'] as String? ?? 'NONE';

        final rawRemedies = data['remedies'] as List<dynamic>? ?? [];
        final parsedRemedies = rawRemedies
            .map((r) => AyurvedicRemedy.fromJson(r as Map<String, dynamic>))
            .toList();

        final botMsg = DadiMaChatMessage(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          text: responseText,
          sender: DadiMaSender.dadiMa,
          timestamp: DateTime.now(),
          speechText: speechText,
          isEmergency: isEmergency,
          emergencyWarning: emergencyWarning,
          remedies: parsedRemedies,
          actionRequired: actionRequired,
        );

        _messages.add(botMsg);
        _isLoading = false;
        notifyListeners();

        // Automatically speak response in warm vernacular voice
        await speakMessage(botMsg);
        return;
      }
    } catch (e) {
      debugPrint('Dadi-Ma network chat failed, using local offline engine: $e');
    }

    // 3. Robust Offline Fallback Engine
    final botMsg = _generateOfflineResponse(
      query,
      vernService.currentLanguage,
      activeMedications: activeMedications,
      diagnosis: diagnosis,
    );
    _messages.add(botMsg);
    _isLoading = false;
    notifyListeners();

    await speakMessage(botMsg);
  }

  /// Speaks message aloud using Watson TTS / Native TTS with slow speech support
  Future<void> speakMessage(DadiMaChatMessage message) async {
    final text = message.speechText ?? message.text;
    if (text.isEmpty) return;

    _currentlySpeakingMessageId = message.id;
    notifyListeners();

    final vernService = VernacularService();
    try {
      await vernService.speakText(
        text,
        onComplete: () {
          if (_currentlySpeakingMessageId == message.id) {
            _currentlySpeakingMessageId = null;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      debugPrint('[DadiMaService] Speak error: $e');
      if (_currentlySpeakingMessageId == message.id) {
        _currentlySpeakingMessageId = null;
        notifyListeners();
      }
    }
  }

  Future<void> stopSpeaking() async {
    await VernacularService().stopSpeech();
    _currentlySpeakingMessageId = null;
    notifyListeners();
  }

  /// Fetches curated Ayurvedic home remedies
  Future<void> fetchRemedies({String? query, String? category}) async {
    final langCode = VernacularService().langCode;
    try {
      final uri = Uri.parse('$_backendUrl/api/dadi-ma/remedies').replace(
        queryParameters: {
          'language': langCode,
          if (query != null && query.isNotEmpty) 'query': query,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final list = data['remedies'] as List<dynamic>? ?? [];
        _remedies = list
            .map((r) => AyurvedicRemedy.fromJson(r as Map<String, dynamic>))
            .toList();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Remedies fetch fallback to local database: $e');
    }

    // Fallback local remedies
    _remedies = _getLocalFallbackRemedies(VernacularService().currentLanguage);
    notifyListeners();
  }

  /// Fetches time-of-day dynamic guidance
  Future<void> fetchDailyGuidance() async {
    final langCode = VernacularService().langCode;
    final hour = DateTime.now().hour;
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/api/dadi-ma/daily-greeting'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'hour': hour, 'language': langCode}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null) {
          _dailyGuidance = DadiMaDailyGuidance.fromJson(data);
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('Daily guidance fallback to local generator: $e');
    }

    _dailyGuidance = _getLocalDailyGuidance(hour, VernacularService().currentLanguage);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // LOCAL OFFLINE FALLBACK GENERATION
  // ---------------------------------------------------------------------------
  DadiMaChatMessage _generateOfflineResponse(
    String query,
    AppLanguage lang, {
    List<MedicineItem>? activeMedications,
    String? diagnosis,
  }) {
    final q = query.toLowerCase();

    // Emergency check
    final isEm = q.contains('chest') ||
        q.contains('pain') && (q.contains('heart') || q.contains('severe')) ||
        q.contains('सीने') ||
        q.contains('छाती') ||
        q.contains('हार्ट') ||
        q.contains('सांस नहीं') ||
        q.contains('दम लागणे') ||
        q.contains('बेशुद्ध');

    if (isEm) {
      String warning;
      if (lang == AppLanguage.marathi) {
        warning = '⚠️ तातडीची सूचना: ही गंभीर लक्षणे असू शकतात. कृपया त्वरित जवळच्या डॉक्टरांशी किंवा १०८ रुग्णवाहिकेशी संपर्क साधा.';
      } else if (lang == AppLanguage.english) {
        warning = '⚠️ Emergency Alert: These symptoms may require immediate clinical attention. Please consult a doctor or call 108 emergency service immediately.';
      } else {
        warning = '⚠️ आपातकालीन चेतावनी: यह गंभीर लक्षण हो सकते हैं। कृपया तुरंत नजदीकी डॉक्टर से मिलें या १०८ एम्बुलेंस को कॉल करें।';
      }

      return DadiMaChatMessage(
        id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
        text: warning,
        sender: DadiMaSender.dadiMa,
        timestamp: DateTime.now(),
        speechText: warning,
        isEmergency: true,
        emergencyWarning: warning,
        actionRequired: 'CALL_108_OR_VISIT_DOCTOR',
      );
    }

    final localRemedies = _getLocalFallbackRemedies(lang);
    List<AyurvedicRemedy> matched = [];

    String reply;
    if (q.contains('cough') || q.contains('खांसी') || q.contains('खोकला') || q.contains('cold') || q.contains('जुकाम') || q.contains('सर्दी')) {
      matched = [localRemedies.firstWhere((r) => r.id == 'cough_cold')];
      if (lang == AppLanguage.marathi) {
        reply = 'काळजी करू नकोस बाळा! खोकला व सर्दीसाठी खाली दिलेला तुळस-आल्याचा काढा दिवसातून दोनदा घे आणि कोमट पाणी पी.';
      } else if (lang == AppLanguage.english) {
        reply = 'Do not worry my dear. For cold and cough, sip on warm Tulsi & Ginger tea and stay well rested.';
      } else {
        reply = 'घबराओ मत बेटा! जुकाम-खांसी के लिए नीचे दिया गया तुलसी-अदरक का काढ़ा पियो और ठंडी चीजों से परहेज रखो।';
      }
    } else if (q.contains('acid') || q.contains('gas') || q.contains('एसिडिटी') || q.contains('गैस') || q.contains('अपच')) {
      matched = [localRemedies.firstWhere((r) => r.id == 'acidity_indigestion')];
      if (lang == AppLanguage.marathi) {
        reply = 'पोटातील जळजळ आणि गॅससाठी बडीशेप आणि जिऱ्याचे पाणी खूप फायदेशीर आहे. जास्त तेलकट जेवण टाळ.';
      } else if (lang == AppLanguage.english) {
        reply = 'For acidity and gas, try roasted fennel and cumin water after meals, and avoid spicy foods.';
      } else {
        reply = 'पेट की गैस और एसिडिटी के लिए सौंफ और भुने जीरे का पानी लो। हल्का भोजन खाओ और पानी पीते रहो।';
      }
    } else if (q.contains('pain') || q.contains('दर्द') || q.contains('दुख') || q.contains('घुटने') || q.contains('सांधे')) {
      matched = [localRemedies.firstWhere((r) => r.id == 'joint_pain_muscle')];
      if (lang == AppLanguage.marathi) {
        reply = 'सांधेदुखी आणि बदनदुखीसाठी रात्री कोमट हळद-दूध घे आणि तळपायांना तेलाने मालिश कर.';
      } else if (lang == AppLanguage.english) {
        reply = 'For joint and body ache, drink warm golden turmeric milk before bedtime and massage joints gently.';
      } else {
        reply = 'जोड़ों और बदन के दर्द में गुनगुना हल्दी वाला दूध लो और रात को पैरों की मालिश करो।';
      }
    } else {
      matched = localRemedies.take(2).toList();
      final count = activeMedications?.length ?? 0;
      if (lang == AppLanguage.marathi) {
        final medPart = count > 0 ? 'तुझ्याकडे $count सक्रिय औषधे आहेत. ती वेळेवर घे.' : 'वेळेवर आहार आणि पाणी घे.';
        reply = 'मी तुझी आजी सदैव तुझ्या सोबत आहे. $medPart';
      } else if (lang == AppLanguage.english) {
        final medPart = count > 0 ? 'You have $count scheduled medications. Take them on time.' : 'Stay healthy, hydrated and well rested.';
        reply = 'Your Dadi-Ma is here for your well-being. $medPart';
      } else {
        final medPart = count > 0 ? 'तुम्हारी $count दवाइयाँ हैं, उन्हें नियम से समय पर लो।' : 'समय पर भोजन और पानी लेते रहो।';
        reply = 'मैं तुम्हारी दादी-माँ तुम्हारे साथ हूँ। $medPart';
      }
    }

    return DadiMaChatMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      text: reply,
      sender: DadiMaSender.dadiMa,
      timestamp: DateTime.now(),
      speechText: reply,
      remedies: matched,
    );
  }

  List<AyurvedicRemedy> _getLocalFallbackRemedies(AppLanguage lang) {
    if (lang == AppLanguage.marathi) {
      return const [
        AyurvedicRemedy(
          id: 'cough_cold',
          category: 'respiratory',
          title: 'तुळस, आले आणि मध काढा (सर्दी-खोकला)',
          description: 'खोकला आणि घशातील खवखव कमी करण्यासाठी आजीचा पारंपरिक काढा.',
          ingredients: ['५-६ ताज्या तुळशीची पाने', '१ लहान तुकडा आले', '१ चमचा मध', '१ कप पाणी'],
          preparation: 'पाण्यात तुळस व आले उकळा. कोमट झाल्यावर मध मिसळून हळूहळू प्या.',
          precaution: 'मधुमेहाच्या रुग्णांनी मधाचे प्रमाण कमी ठेवावे.',
        ),
        AyurvedicRemedy(
          id: 'acidity_indigestion',
          category: 'digestive',
          title: 'बडीशेप व भाजलेले जिरे पाणी (अ‍ॅसिडिटी व गॅस)',
          description: 'पोटातील जळजळ आणि गॅसपासून त्वरित आराम मिळवण्यासाठी उपाय.',
          ingredients: ['१ चमचा बडीशेप', 'अर्धा चमचा भाजलेले जिरे', '१ ग्लास पाणी'],
          preparation: 'जिरे व बडीशेप पाण्यात उकळून जेवणानंतर २० मिनिटांनी प्या.',
          precaution: 'जास्त तिखट व तेलकट पदार्थ टाळा.',
        ),
        AyurvedicRemedy(
          id: 'joint_pain_muscle',
          category: 'pain_relief',
          title: 'हळद-दूध व मेथी दाणे (सांधेदुखी व अंगदुखी)',
          description: 'नैसर्गिक दाहशामक गुणांमुळे सांधेदुखी आणि सूज कमी होते.',
          ingredients: ['१ कप कोमट दूध', 'अर्धा चमचा हळद', '१ चिमूट सुंठ'],
          preparation: 'दुधात हळद मिसळून रात्री झोपण्यापूर्वी प्या.',
          precaution: 'दूध न पचल्यास कोमट पाण्यात हळद घ्या.',
        ),
      ];
    } else if (lang == AppLanguage.english) {
      return const [
        AyurvedicRemedy(
          id: 'cough_cold',
          category: 'respiratory',
          title: 'Tulsi, Ginger & Honey Infusion (Cough & Cold)',
          description: 'Traditional soothing remedy for mild cough and throat irritation.',
          ingredients: ['5-6 Fresh Tulsi leaves', '1 small crushed ginger', '1 tsp Honey', '1 cup water'],
          preparation: 'Boil tulsi and ginger in water for 5 mins. Strain, add honey, and sip warm.',
          precaution: 'Diabetics should limit honey.',
        ),
        AyurvedicRemedy(
          id: 'acidity_indigestion',
          category: 'digestive',
          title: 'Fennel & Roasted Cumin Water (Acidity & Gas)',
          description: 'Calms stomach burning, bloating, and post-meal fullness.',
          ingredients: ['1 tsp Fennel seeds', '1/2 tsp roasted Cumin', '1 glass water'],
          preparation: 'Boil seeds in water for 3 mins. Strain and drink 20 mins after meals.',
          precaution: 'Avoid oily and spicy food.',
        ),
        AyurvedicRemedy(
          id: 'joint_pain_muscle',
          category: 'pain_relief',
          title: 'Golden Turmeric Milk & Fenugreek (Joint Care)',
          description: 'Potent natural anti-inflammatory comfort for mobility and aches.',
          ingredients: ['1 cup warm milk', '1/2 tsp Turmeric powder', 'Pinch of dry ginger'],
          preparation: 'Mix turmeric into warm milk and drink before bedtime.',
          precaution: 'Use warm water if lactose intolerant.',
        ),
      ];
    }

    // Default Hindi
    return const [
      AyurvedicRemedy(
        id: 'cough_cold',
        category: 'respiratory',
        title: 'तुलसी, अदरक और शहद का काढ़ा (खांसी-जुकाम)',
        description: 'खांसी और गले की खराश के लिए दादी-माँ का सबसे भरोसेमंद नुस्खा।',
        ingredients: ['5-6 ताजी तुलसी की पत्तियां', '1 छोटा टुकड़ा अदरक', '1 चम्मच शहद', '1 कप पानी'],
        preparation: 'पानी में तुलसी और अदरक उबालें। गुनगुना होने पर शहद मिलाकर धीरे-धीरे पिएं।',
        precaution: 'मधुमेह के मरीज शहद की मात्रा कम रखें।',
      ),
      AyurvedicRemedy(
        id: 'acidity_indigestion',
        category: 'digestive',
        title: 'सौंफ और भुना जीरा पानी (एसिडिटी और गैस)',
        description: 'पेट की जलन, गैस और भारीपन को तुरंत शांत करने वाला नुस्खा।',
        ingredients: ['1 चम्मच सौंफ', 'आधा चम्मच भुना जीरा', '1 गिलास पानी'],
        preparation: 'सौंफ और जीरे को पानी में उबालें और भोजन के 20 मिनट बाद पिएं।',
        precaution: 'तला-भुना खाना पूरी तरह बंद रखें।',
      ),
      AyurvedicRemedy(
        id: 'joint_pain_muscle',
        category: 'pain_relief',
        title: 'हल्दी-दूध और मेथी दाना (जोड़ों व बदन दर्द)',
        description: 'प्राकृतिक एंटी-इंफ्लेमेटरी गुण जोड़ों की जकड़न और दर्द दूर करते हैं।',
        ingredients: ['1 कप गुनगुना दूध', 'आधा छोटा चम्मच शुद्ध हल्दी', '1 चुटकी सोंठ'],
        preparation: 'दूध में हल्दी मिलाकर रात को सोने से पहले पिएं।',
        precaution: 'दूध न पचने पर गुनगुने पानी में हल्दी लें।',
      ),
    ];
  }

  DadiMaDailyGuidance _getLocalDailyGuidance(int hour, AppLanguage lang) {
    if (5 <= hour && hour < 12) {
      if (lang == AppLanguage.marathi) {
        return const DadiMaDailyGuidance(
          period: 'morning',
          title: 'शुभ सकाळ! 🌅',
          text: 'सकाळची उपाशीपोटी घ्यायची औषधे वेळेवर घ्या, चांगला पौष्टिक नाश्ता करा आणि भरपूर पाणी प्या.',
          audioText: 'शुभ सकाळ! सकाळची औषधे वेळेवर घ्या आणि नाश्ता करा.',
          language: 'mr',
        );
      } else if (lang == AppLanguage.english) {
        return const DadiMaDailyGuidance(
          period: 'morning',
          title: 'Good Morning! 🌅',
          text: 'Take your morning empty-stomach medications on time, eat a healthy breakfast, and stay well hydrated.',
          audioText: 'Good morning! Please take your scheduled morning medicines and have a healthy breakfast.',
          language: 'en',
        );
      }
      return const DadiMaDailyGuidance(
        period: 'morning',
        title: 'शुभ प्रभात! 🌅',
        text: 'सुबह खाली पेट वाली दवा समय पर लें, पौष्टिक नाश्ता करें और गुनगुना पानी पिएं।',
        audioText: 'शुभ प्रभात! सुबह की दवाइयाँ समय पर लें और नाश्ता करें। अपना ध्यान रखें!',
        language: 'hi',
      );
    } else if (12 <= hour && hour < 17) {
      if (lang == AppLanguage.marathi) {
        return const DadiMaDailyGuidance(
          period: 'afternoon',
          title: 'शुभ दुपार! ☀️',
          text: 'दुपारचे जेवण झाल्यानंतरची औषधे वेळेवर घ्या आणि थोडी विश्रांती घ्या.',
          audioText: 'दुपारचे जेवण झाल्यावर औषधे वेळेवर घ्या आणि आराम करा.',
          language: 'mr',
        );
      } else if (lang == AppLanguage.english) {
        return const DadiMaDailyGuidance(
          period: 'afternoon',
          title: 'Good Afternoon! ☀️',
          text: 'Take your post-lunch medications on time and take a short refreshing rest.',
          audioText: 'Good afternoon! Take your post-meal doses and rest for a while.',
          language: 'en',
        );
      }
      return const DadiMaDailyGuidance(
        period: 'afternoon',
        title: 'शुभ दोपहर! ☀️',
        text: 'दोपहर का भोजन करने के बाद वाली दवा समय पर लें और थोड़ा विश्राम करें।',
        audioText: 'दोपहर का भोजन करने के बाद दवा समय पर लें और आराम करें।',
        language: 'hi',
      );
    } else if (17 <= hour && hour < 21) {
      if (lang == AppLanguage.marathi) {
        return const DadiMaDailyGuidance(
          period: 'evening',
          title: 'शुभ संध्याकाळ! 🌇',
          text: 'संध्याकाळी थोडा हलका फेरफटका मारा आणि रात्रीच्या जेवणाची तयारी करा.',
          audioText: 'संध्याकाळ झाली आहे. थोडा फेरफटका मारा आणि रात्रीची औषधे लक्षात ठेवा.',
          language: 'mr',
        );
      } else if (lang == AppLanguage.english) {
        return const DadiMaDailyGuidance(
          period: 'evening',
          title: 'Good Evening! 🌇',
          text: 'Take a gentle evening walk, relax your mind, and prepare for your night doses.',
          audioText: 'Good evening! Relax and remember your scheduled night medicines.',
          language: 'en',
        );
      }
      return const DadiMaDailyGuidance(
        period: 'evening',
        title: 'शुभ संध्या! 🌇',
        text: 'शाम को थोड़ा टहलें, ताजी हवा लें और रात की दवा समय पर लेने के लिए तैयार रहें।',
        audioText: 'शुभ संध्या! शाम को थोड़ा टहलें और रात की दवा समय पर लें।',
        language: 'hi',
      );
    } else {
      if (lang == AppLanguage.marathi) {
        return const DadiMaDailyGuidance(
          period: 'night',
          title: 'शुभ रात्री! 🌙',
          text: 'रात्रीची सर्व औषधे घेतली आहेत ना? कोमट हळद-दूध प्या आणि शांत झोपा.',
          audioText: 'रात्र झाली आहे. औषधे वेळेवर घेतली ना? शांत झोपा, शुभ रात्री!',
          language: 'mr',
        );
      } else if (lang == AppLanguage.english) {
        return const DadiMaDailyGuidance(
          period: 'night',
          title: 'Good Night! 🌙',
          text: 'Ensure all your night medicines are taken. Have a warm soothing drink and get peaceful rest.',
          audioText: 'Bedtime! Take your night medicines and have a peaceful sleep.',
          language: 'en',
        );
      }
      return const DadiMaDailyGuidance(
        period: 'night',
        title: 'शुभ रात्रि! 🌙',
        text: 'रात की सभी दवाइयाँ ले ली हैं ना बेटा? गुनगुना हल्दी दूध पिएं और गहरी नींद लें।',
        audioText: 'रात की दवाइयाँ ले ली हों तो अब आराम से सो जाइए। शुभ रात्रि!',
        language: 'hi',
      );
    }
  }
}
