"""
Aarogyam: Dadi-Ma Intelligence Engine
Production-grade conversational and clinical guidance system embodying "Dadi-Ma" (दादी माँ / आजी)
Powered by IBM Granite, Watson Speech, and clinically validated Ayurvedic home-care guidelines.
"""

import logging
import re
from typing import Dict, Any, List, Optional, Tuple

logger = logging.getLogger("aarogyam_backend.dadi_ma")

# ==============================================================================
# 1. EMERGENCY RED FLAG KEYWORDS & TRIAGE
# ==============================================================================
EMERGENCY_PATTERNS = {
    "hi": [
        r"(?:सीने|छाती|दिल).*(?:दर्द|दौरा|जलन|दबाव)",
        r"हार्ट\s*अटैक",
        r"सांस.*(?:नहीं\s*आ|फूल|रुक|तकलीफ|घुट)",
        r"बेहोश",
        r"खून.*(?:उल्टी|थूक|बह)",
        r"पक्षाघात|लकवा",
        r"अचानक.*चक्कर.*गिर",
        r"अत्यधिक.*रक्तस्राव"
    ],
    "mr": [
        r"(?:छाती|हृदय).*(?:दुख|कळा|दाब|अटॅक)",
        r"हार्ट\s*अटॅक",
        r"श्वास.*(?:त्रास|घुटमळ|रुक|कमी|दम)",
        r"बेशुद्ध",
        r"रक्ताची\s*उलटी",
        r"पक्षाघात|तोंड\s*वाकडे",
        r"अचानक.*चक्कर",
        r"अति\s*रक्तस्राव"
    ],
    "en": [
        r"chest.*(?:pain|pressure|tightness|heaviness)",
        r"heart\s*attack",
        r"(?:shortness|difficulty|trouble|can't).*breath",
        r"breath.*(?:short|trouble|gasp)",
        r"unconscious|fainting|passed\s*out",
        r"vomit.*blood|cough.*blood",
        r"stroke|facial\s*droop|paralysis",
        r"severe.*bleeding|seizure"
    ]
}

def check_emergency_red_flags(query: str, lang: str = "hi") -> Tuple[bool, Optional[str]]:
    """Checks if user query contains life-threatening red-flag symptoms using regex patterns."""
    query_clean = query.strip()
    
    patterns = EMERGENCY_PATTERNS.get(lang, EMERGENCY_PATTERNS["en"]) + EMERGENCY_PATTERNS["en"]
    for pat in patterns:
        if re.search(pat, query_clean, re.IGNORECASE):
            if lang == "mr":
                warning = "⚠️ तातडीची सूचना: ही गंभीर लक्षणे असू शकतात. कृपया त्वरित जवळच्या डॉक्टरांशी किंवा १०८ रुग्णवाहिकेशी संपर्क साधा."
            elif lang == "hi":
                warning = "⚠️ आपातकालीन चेतावनी: यह गंभीर लक्षण हो सकते हैं। कृपया तुरंत नजदीकी डॉक्टर से मिलें या १०८ एम्बुलेंस को कॉल करें।"
            else:
                warning = "⚠️ Emergency Alert: These symptoms may require immediate clinical attention. Please consult a doctor immediately or call emergency 108."
            return True, warning
            
    return False, None



# ==============================================================================
# 2. CURATED AYURVEDIC HOME-CARE & REMEDY KNOWLEDGE BASE
# Clinically safe, traditional Indian grandmother remedies with food interactions
# ==============================================================================
REMEDY_CATALOG: List[Dict[str, Any]] = [
    {
        "id": "cough_cold",
        "category": "respiratory",
        "tags": ["cough", "cold", "sore_throat", "खांसी", "जुकाम", "खोकला", "सर्दी", "घसा"],
        "title": {
            "hi": "तुलसी, अदरक और शहद का काढ़ा (खांसी-जुकाम)",
            "mr": "तुळस, आले आणि मध यांचा काढा (खोकला व सर्दी)",
            "en": "Tulsi, Ginger & Honey Infusion (Cough & Cold)"
        },
        "description": {
            "hi": "खांसी और गले की खराश के लिए दादी-माँ का सबसे भरोसेमंद नुस्खा।",
            "mr": "खोकला आणि घशातील खवखव कमी करण्यासाठी आजीचा पारंपरिक काढा.",
            "en": "Time-tested soothing grandmother remedy for mild dry cough and throat irritation."
        },
        "ingredients": {
            "hi": ["5-6 ताजी तुलसी की पत्तियां", "1 छोटा टुकड़ा अदरक (कुटा हुआ)", "1 चम्मच शुद्ध शहद", "1 कप गुनगुना पानी"],
            "mr": ["५-६ ताज्या तुळशीची पाने", "१ लहान तुकडा आले (ठेचलेले)", "१ चमचा मध", "१ कप कोमट पाणी"],
            "en": ["5-6 Fresh Tulsi leaves", "1 small piece crushed ginger", "1 tsp pure honey", "1 cup warm water"]
        },
        "preparation": {
            "hi": "पानी में तुलसी और अदरक डालकर 5 मिनट उबालें। गुनगुना होने पर शहद मिलाकर धीरे-धीरे पिएं।",
            "mr": "पाण्यात तुळस आणि आले घालून ५ मिनिटे उकळा. कोमट झाल्यावर मध मिसळून हळूहळू प्या.",
            "en": "Boil tulsi and crushed ginger in water for 5 minutes. Strain, cool to warm, stir in honey and sip slowly."
        },
        "precaution": {
            "hi": "मधुमेह (शुगर) के मरीज शहद की मात्रा बहुत कम रखें। 3 दिन से अधिक तेज बुखार हो तो डॉक्टर से मिलें।",
            "mr": "मधुमेहाच्या रुग्णांनी मधाचे प्रमाण कमी ठेवावे. ३ दिवसांपेक्षा जास्त ताप असल्यास डॉक्टरांना दाखवा.",
            "en": "Diabetic patients should use minimal honey. If fever persists over 3 days, consult a physician."
        }
    },
    {
        "id": "acidity_indigestion",
        "category": "digestive",
        "tags": ["acidity", "indigestion", "gas", "bloating", "एसिडिटी", "गैस", "अपच", "बद्धकोष्ठता", "अ‍ॅसिडिटी"],
        "title": {
            "hi": "सौंफ और भुना जीरा पानी (एसिडिटी और गैस)",
            "mr": "बडीशेप आणि भाजलेले जिरे पाणी (अ‍ॅसिडिटी आणि गॅस)",
            "en": "Fennel & Roasted Cumin Water (Acidity & Gas)"
        },
        "description": {
            "hi": "पेट की जलन, गैस और भारीपन को तुरंत शांत करने वाला नुस्खा।",
            "mr": "पोटातील जळजळ आणि गॅसपासून त्वरित आराम मिळवण्यासाठी गुणकारी उपाय.",
            "en": "Calms stomach burning, bloating, and post-meal heaviness naturally."
        },
        "ingredients": {
            "hi": ["1 चम्मच सौंफ", "आधा चम्मच भुना जीरा", "1 गिलास पानी", "चुटकी भर काला नमक"],
            "mr": ["१ चमचा बडीशेप", "अर्धा चमचा भाजलेले जिरे", "१ ग्लास पाणी", "किंचित काळे मीठ"],
            "en": ["1 tsp Fennel seeds (Saunf)", "1/2 tsp roasted Cumin (Jeera)", "1 glass water", "Pinch of black salt"]
        },
        "preparation": {
            "hi": "सौंफ और जीरे को पानी में रात भर भिगोएं या 3 मिनट उबालें। छानकर भोजन के 20 मिनट बाद पिएं।",
            "mr": "बडीशेप आणि जिरे रात्रभर पाण्यात भिजवा किंवा ३ मिनिटे उकळा. जेवणानंतर २० मिनिटांनी प्या.",
            "en": "Soak seeds overnight or boil for 3 minutes. Strain and drink 20 minutes after lunch or dinner."
        },
        "precaution": {
            "hi": "अगर आपको अल्सर है तो गर्म मसाले और तला-भुना खाना बिल्कुल बंद रखें।",
            "mr": "अल्सरचा त्रास असल्यास जास्त तिखट व तेलकट पदार्थ पूर्णपणे टाळा.",
            "en": "Avoid spicy or oily foods if experiencing acute gastric pain."
        }
    },
    {
        "id": "joint_pain_muscle",
        "category": "pain_relief",
        "tags": ["joint_pain", "knee_pain", "arthritis", "bodyache", "घुटनों का दर्द", "जोड़ों का दर्द", "संधिवात", "सांधेदुखी", "पाठदुखी"],
        "title": {
            "hi": "हल्दी-दूध और मेथी दाना (जोड़ों व बदन दर्द)",
            "mr": "हळद-दूध आणि मेथी दाणे (सांधेदुखी व अंगदुखी)",
            "en": "Golden Turmeric Milk & Fenugreek (Joint & Body Ache)"
        },
        "description": {
            "hi": "प्राकृतिक एंटी-इंफ्लेमेटरी गुण जोड़ों की जकड़न और दर्द को दूर करते हैं।",
            "mr": "नैसर्गिक दाहशामक गुणांमुळे सांधेदुखी आणि सूज कमी होण्यास मदत होते.",
            "en": "Potent natural anti-inflammatory comfort for stiffness and joint mobility."
        },
        "ingredients": {
            "hi": ["1 कप गुनगुना गाय का दूध", "आधा छोटा चम्मच शुद्ध हल्दी", "1 चुटकी सोंठ (सूखा अदरक पावडर)"],
            "mr": ["१ कप कोमट दूध", "अर्धा चमचा हळद", "१ चिमूट सुंठ पावडर"],
            "en": ["1 cup warm milk", "1/2 tsp pure turmeric powder", "Pinch of dry ginger powder"]
        },
        "preparation": {
            "hi": "दूध में हल्दी और सोंठ मिलाकर रात को सोने से पहले पिएं। सुबह खाली पेट 5 भिगोए मेथी दाने चबाएं।",
            "mr": "दुधात हळद व सुंठ मिसळून रात्री झोपण्यापूर्वी प्या. सकाळी रिकाम्या पोटी ५ भिजवलेले मेथी दाणे चावून खा.",
            "en": "Mix turmeric in warm milk before bedtime. Chew 5 soaked fenugreek seeds in the morning."
        },
        "precaution": {
            "hi": "लैक्टोज असहिष्णुता (दूध न पचने) वाले गुनगुने पानी में हल्दी लें।",
            "mr": "दूध पचत नसल्यास कोमट पाण्यात हळद घेऊन प्या.",
            "en": "If lactose intolerant, take turmeric in warm water instead of milk."
        }
    },
    {
        "id": "hypertension_care",
        "category": "chronic_care",
        "tags": ["bp", "hypertension", "high_bp", "रक्तचाप", "उच्च रक्तदाब", "बीपी"],
        "title": {
            "hi": "दादी-माँ की बीपी देखभाल व अर्जुन छाल काढ़ा",
            "mr": "आजीचा उच्च रक्तदाब सल्ला व अर्जुन साल काढा",
            "en": "Dadi-Ma's Blood Pressure Lifestyle & Arjuna Bark Guide"
        },
        "description": {
            "hi": "रक्तचाप नियंत्रण के लिए प्राकृतिक आहार नियम और हृदय की सुरक्षा।",
            "mr": "रक्तदाब नियंत्रणात ठेवण्यासाठी आहाराचे नियम आणि हृदयाची काळजी.",
            "en": "Cardio-protective dietary discipline and natural lifestyle guidelines for BP management."
        },
        "ingredients": {
            "hi": ["सेंधा नमक (साधारण नमक बहुत कम)", "लहसुन की 1 कली (कच्ची)", "ताजा आंवला या नींबू पानी"],
            "mr": ["सेंधव मीठ (मीठाचे प्रमाण कमी ठेवा)", "लसणाची १ पाकळी (कच्ची)", "ताजा आवळा किंवा लिंबू पाणी"],
            "en": ["Rock salt (strictly reduce sodium)", "1 raw garlic clove in morning", "Fresh Amla or lemon water"]
        },
        "preparation": {
            "hi": "सुबह खाली पेट लहसुन की 1 कली पानी के साथ लें। दिनभर 8-10 गिलास पानी पिएं और नमक कम रखें।",
            "mr": "सकाळी रिकाम्या पोटी लसणाची १ पाकळी पाण्यासोबत घ्या. दिवसभरात भरपूर पाणी प्या व मीठ कमी खा.",
            "en": "Swallow 1 small garlic clove with water in morning. Maintain low sodium and adequate hydration."
        },
        "precaution": {
            "hi": "डॉक्टर की बीपी की गोली (जैसे Telmisartan/Amlodipine) कभी न छोड़ें। यह घरेलू नुस्खा सहायक है, दवा का विकल्प नहीं।",
            "mr": "डॉक्टरांनी दिलेली बीपीची गोळी कधीही बंद करू नका. हा उपाय केवळ मदतीसाठी आहे.",
            "en": "NEVER stop prescribed anti-hypertensive medication. Home care is supportive only."
        }
    },
    {
        "id": "diabetes_care",
        "category": "chronic_care",
        "tags": ["diabetes", "sugar", "मधुमेह", "शुगर", "साखर"],
        "title": {
            "hi": "दादी-माँ की शुगर देखभाल (जामुन गुठली व मेथी)",
            "mr": "आजीचा मधुमेह सल्ला (जांभूळ बी व मेथी)",
            "en": "Dadi-Ma's Diabetes & Blood Sugar Wellness Guide"
        },
        "description": {
            "hi": "रक्त में शर्करा स्तर संतुलित रखने और कमजोरी दूर करने के घरेलू नियम।",
            "mr": "रक्तातील साखर नियंत्रित ठेवण्यासाठी आणि थकवा दूर करण्यासाठी आजीचा सल्ला.",
            "en": "Holistic routine and safe herbs to assist glucose metabolism and prevent lethargy."
        },
        "ingredients": {
            "hi": ["जामुन की गुठली का पावडर (आधा चम्मच)", "मेथी दाना पावडर", "करेले या खीरे का रस"],
            "mr": ["जांभळाच्या बियांची पूड (अर्धा चमचा)", "मेथी दाणे पूड", "कारले किंवा काकडीचा रस"],
            "en": ["Jamun seed powder (1/2 tsp)", "Fenugreek seed powder", "Bitter gourd or cucumber juice"]
        },
        "preparation": {
            "hi": "सुबह खाली पेट जामुन गुठली का पावडर गुनगुने पानी के साथ लें। समय पर खाना खाएं, भूखे न रहें।",
            "mr": "सकाळी उपाशीपोटी जांभूळ बी पूड कोमट पाण्यासोबत घ्या. जेवणाच्या वेळा पाळा, उपाशी राहू नका.",
            "en": "Take 1/2 tsp Jamun seed powder with lukewarm water before breakfast. Never skip scheduled meals."
        },
        "precaution": {
            "hi": "मेटफॉर्मिन (Metformin) जैसी दवा के साथ समय पर भोजन अवश्य करें ताकि शुगर बहुत कम न हो।",
            "mr": "मेटफॉर्मिन गोळी घेतल्यानंतर वेळेवर जेवण करा, जेणेकरून साखर अचानक कमी होणार नाही.",
            "en": "Always eat meals on time when taking Metformin to prevent hypoglycemia."
        }
    },
    {
        "id": "insomnia_stress",
        "category": "mental_wellness",
        "tags": ["sleep", "insomnia", "stress", "नींद न आना", "तनाव", "झोप न येणे", "शांत झोप"],
        "title": {
            "hi": "जायफल-दूध और तलवों की मालिश (गहरी नींद)",
            "mr": "जायफळ-दूध आणि तळपायांची मालिश (गाढ झोप)",
            "en": "Nutmeg Warm Milk & Foot Massage (Restful Sleep)"
        },
        "description": {
            "hi": "बुजुर्गों के लिए बिना किसी नशे या आदत के शांतिपूर्ण नींद का प्राकृतिक उपाय।",
            "mr": "कोणतीही सवय न लागता शांत व गाढ झोपेसाठी नैसर्गिक आजीचा उपाय.",
            "en": "Gentle, non-habit forming traditional ritual for restorative sleep."
        },
        "ingredients": {
            "hi": ["1 चुटकी जायफल पावडर", "1 कप गुनगुना दूध", "थोड़ा सरसों या तिल का तेल"],
            "mr": ["१ चिमूट जायफळ पूड", "१ कप कोमट दूध", "थोडे तीळ किंवा मोहरीचे तेल"],
            "en": ["1 pinch Nutmeg powder (Jaiphal)", "1 cup warm milk", "Warm sesame or mustard oil"]
        },
        "preparation": {
            "hi": "दूध में 1 चुटकी जायफल डालकर पिएं। सोने से पहले पैरों के तलवों पर गुनगुने तेल से 5 मिनट मालिश करें।",
            "mr": "दुधात १ चिमूट जायफळ घालून प्या. झोपण्यापूर्वी तळपायांना कोमट तेलाने ५ मिनिटे मालिश करा.",
            "en": "Add 1 pinch nutmeg to warm milk before bed. Massage warm oil onto the soles of feet for 5 minutes."
        },
        "precaution": {
            "hi": "जायफल केवल 1 चुटकी ही लें, अधिक मात्रा में न लें।",
            "mr": "जायफळ केवळ १ चिमूटच घ्यावे, जास्त घेऊ नये.",
            "en": "Use only a tiny pinch of nutmeg; avoid excessive amounts."
        }
    }
]


# ==============================================================================
# 3. DADI-MA TIME-BASED GREETINGS & WELLNESS ENCOURAGEMENT
# ==============================================================================
def get_dadi_ma_greeting(hour: int = 8, lang: str = "hi", patient_name: str = "बेटा") -> Dict[str, str]:
    """Generates warm, maternal, contextual daily greetings based on local time."""
    if 5 <= hour < 12:
        period = "morning"
        if lang == "mr":
            title = "शुभ सकाळ! 🌅"
            text = f"नमस्कार {patient_name}! आजची सकाळ छान सुरू झाली आहे ना? आधी उपाशीपोटी घ्यायची औषधे घ्या, मग चांगला नाश्ता करा आणि भरपूर पाणी प्या. मी सदैव तुमच्या सोबत आहे."
            audio_text = f"नमस्कार! आजची सकाळ छान सुरू झाली आहे ना? आधी उपाशीपोटी घ्यायची औषधे घ्या, मग नाश्ता करा. काळजी घ्या!"
        elif lang == "hi":
            title = "शुभ प्रभात! 🌅"
            text = f"नमस्ते {patient_name}! आज का दिन आपके लिए मंगलमय हो। पहले खाली पेट वाली दवा लें, फिर पौष्टिक नाश्ता करें और गुनगुना पानी पिएं। अपना ख्याल रखना।"
            audio_text = f"नमस्ते! आज का दिन आपके लिए शुभ हो। पहले खाली पेट वाली दवा लें, फिर नाश्ता करें और गुनगुना पानी पिएं। खुश रहें!"
        else:
            title = "Good Morning! 🌅"
            text = f"Good morning, my dear! Start your day well: take your empty-stomach medicine if scheduled, have a wholesome breakfast, and stay hydrated. I am right here with you."
            audio_text = f"Good morning! Take your morning medicines on time, eat a healthy breakfast, and take good care of yourself today."
    elif 12 <= hour < 17:
        period = "afternoon"
        if lang == "mr":
            title = "शुभ दुपार! ☀️"
            text = f"नमस्कार! दुपारचे जेवण झाले का? जेवणानंतरची औषधे वेळेवर घ्या आणि थोडा वेळ विश्रांती घ्या. जास्त उन्हात जाऊ नका."
            audio_text = f"दुपारचे जेवण झाले का? जेवणानंतरची औषधे वेळेवर घ्या आणि थोडी विश्रांती घ्या."
        elif lang == "hi":
            title = "शुभ दोपहर! ☀️"
            text = f"नमस्ते! क्या आपने दोपहर का भोजन कर लिया? खाने के बाद वाली दवा समय पर लें और थोड़ी देर आराम करें। धूप से बचें और पानी पीते रहें।"
            audio_text = f"दोपहर का भोजन कर लिया हो तो दवा समय पर लें और थोड़ा आराम करें। पानी पीते रहें।"
        else:
            title = "Good Afternoon! ☀️"
            text = f"Good afternoon! Have you had your lunch? Take your post-meal doses on time and take a short rest. Stay well hydrated."
            audio_text = f"Good afternoon! Please take your post-meal medicines on time and rest for a while."
    elif 17 <= hour < 21:
        period = "evening"
        if lang == "mr":
            title = "शुभ संध्याकाळ! 🌇"
            text = f"संध्याकाळची वेळ झाली आहे. हलका फेरफटका मारा, मन शांत ठेवा आणि रात्रीच्या जेवणाची तयारी करा."
            audio_text = f"संध्याकाळ झाली आहे. थोडा हलका फेरफटका मारा आणि रात्रीची औषधे लक्षात ठेवा."
        elif lang == "hi":
            title = "शुभ संध्या! 🌇"
            text = f"शाम हो गई है। थोड़ा टहल लें, ताजी हवा लें और रात के खाने की तैयारी करें। रात की दवा मत भूलना।"
            audio_text = f"शाम का समय है। थोड़ा टहल लें और रात की दवा समय पर लेने के लिए तैयार रहें।"
        else:
            title = "Good Evening! 🌇"
            text = f"Good evening! Take a gentle stroll in fresh air, relax your mind, and prepare for a light dinner. Remember your evening medicines."
            audio_text = f"Good evening! Enjoy the evening air and remember your scheduled night medicines."
    else:
        period = "night"
        if lang == "mr":
            title = "शुभ रात्री! 🌙"
            text = f"रात्र झाली आहे. रात्रीची सर्व औषधे घेतली आहेत ना? आता एक कप कोमट हळद-दूध प्या आणि शांत झोपा. उद्या नवी ऊर्जा मिळेल."
            audio_text = f"रात्र झाली आहे. रात्रीची औषधे घेतली ना? आता शांत झोपा, शुभ रात्री!"
        elif lang == "hi":
            title = "शुभ रात्रि! 🌙"
            text = f"रात हो गई है बेटा। क्या आपने रात की सभी दवाइयाँ ले ली हैं? अब थोड़ा गुनगुना हल्दी दूध पिएं और गहरी नींद लें। शुभ रात्रि!"
            audio_text = f"रात हो गई है। रात की दवाइयाँ ले ली हों तो अब आराम से सो जाइए। शुभ रात्रि!"
        else:
            title = "Good Night! 🌙"
            text = f"It is bedtime, my dear. Have you taken all your night medicines? Drink a warm cup of water or milk and get peaceful sleep. Good night!"
            audio_text = f"Time for rest. Please ensure your night medicines are taken, and have a peaceful sleep. Good night!"

    return {
        "period": period,
        "title": title,
        "text": text,
        "audio_text": audio_text,
        "language": lang
    }


# ==============================================================================
# 4. CONVERSATIONAL REASONING & FALLBACK CHAT ENGINE
# ==============================================================================
def search_remedies(query: str, lang: str = "hi") -> List[Dict[str, Any]]:
    """Finds matching home remedies based on keywords."""
    query_lower = query.lower()
    matches = []
    
    for rem in REMEDY_CATALOG:
        for tag in rem["tags"]:
            if tag.lower() in query_lower:
                matches.append(rem)
                break
                
    if not matches and len(query_lower) < 4:
        return REMEDY_CATALOG[:3]
        
    return matches if matches else REMEDY_CATALOG[:2]


def format_dadi_ma_response(
    query: str,
    lang: str = "hi",
    medications: Optional[List[Dict[str, Any]]] = None,
    diagnosis: Optional[str] = None
) -> Dict[str, Any]:
    """
    Offline / Fallback Conversational Engine for Dadi-Ma.
    Generates warm, compassionate, culturally resonant answers even without WatsonX API keys.
    """
    is_emergency, warning = check_emergency_red_flags(query, lang)
    if is_emergency:
        return {
            "status": "emergency",
            "is_emergency": True,
            "emergency_warning": warning,
            "speech_text": warning,
            "response_text": warning,
            "action_required": "CALL_108_OR_VISIT_DOCTOR",
            "remedies": []
        }

    matching_remedies = search_remedies(query, lang)
    remedy_items = []
    
    for r in matching_remedies:
        remedy_items.append({
            "id": r["id"],
            "title": r["title"].get(lang, r["title"]["en"]),
            "description": r["description"].get(lang, r["description"]["en"]),
            "ingredients": r["ingredients"].get(lang, r["ingredients"]["en"]),
            "preparation": r["preparation"].get(lang, r["preparation"]["en"]),
            "precaution": r["precaution"].get(lang, r["precaution"]["en"]),
        })

    # Build compassionate contextual grandmotherly advice
    q_lower = query.lower()
    med_count = len(medications) if medications else 0

    if lang == "mr":
        if "औषध" in q_lower or "वेळ" in q_lower or "गोळी" in q_lower or "प्रिस्क्रिप्शन" in q_lower:
            intro = f"बेटा, मी तुझी आजी सांगते: डॉक्टर साहेबांनी दिलेली औषधे वेळेवर घेणे सर्वात महत्त्वाचे आहे. "
            if med_count > 0:
                intro += f"सध्या तुझ्याकडे {med_count} औषधांचे वेळापत्रक आहे. जेवणानंतरची औषधे रिकाम्या पोटी घेऊ नकोस. "
            else:
                intro += "सर्व गोळ्या पाण्यासोबत वेळेवर घे आणि आहारात हिरव्या भाज्या व भरपूर पाण्याचा समावेश कर. "
        elif "खोकला" in q_lower or "सर्दी" in q_lower or "ताप" in q_lower:
            intro = "काळजी करू नकोस बेटा! वातावरणातील बदलामुळे असा त्रास होतो. मी खाली एक सोपा घरगुती काढा दिला आहे. तो दिवसातून दोनदा घे आणि थंड पाणी पिणे टाळ."
        elif "पोट" in q_lower or "गॅस" in q_lower or "अ‍ॅसिडिटी" in q_lower:
            intro = "पोटातील जळजळ आणि अपचनासाठी बडीशेप आणि जिऱ्याचे पाणी खूप गुणकारी आहे. जास्त तिखट खाणे टाळ आणि जेवण हळूहळू चावून खा."
        elif "दुखी" in q_lower or "गुडघे" in q_lower or "सांधे" in q_lower:
            intro = "सांधेदुखी आणि बदनदुखीसाठी रात्री हळद-दूध पिणे आणि सकाळी हलका व्यायाम करणे खूप फायदेशीर आहे. स्वतःवर जास्त ताण घेऊ नकोस."
        else:
            intro = f"मी तुझी आजी सदैव तुझ्या आरोग्याची काळजी घेण्यासाठी इथे आहे. वेळेवर जेवण कर, वेळेवर औषधे घे आणि पुरेशी झोप घे."
            
        speech = intro
        if remedy_items:
            speech += f" घरगुती मदतीसाठी {remedy_items[0]['title']} चा उपाय करून बघ."

    elif lang == "hi":
        if "दवा" in q_lower or "समय" in q_lower or "गोली" in q_lower or "पर्चा" in q_lower:
            intro = f"बेटा, तुम्हारी दादी माँ तुम्हें समझाती है: डॉक्टर की दी हुई दवाइयाँ नियम से लेना सबसे जरूरी है। "
            if med_count > 0:
                intro += f"तुम्हारी {med_count} दवाइयाँ शेड्यूल में हैं। खाली पेट वाली दवा खाली पेट और भोजन के बाद वाली दवा खाने के 15 मिनट बाद ही लेना। "
            else:
                intro += "दवा हमेशा सादे पानी से लें, चाय या दूध के साथ बिना पूछे न लें। "
        elif "खांसी" in q_lower or "जुकाम" in q_lower or "गला" in q_lower:
            intro = "घबराओ मत बेटा! मौसम बदलने से जुकाम-खांसी हो जाती है। मैंने नीचे तुलसी-अदरक का भरोसेमंद काढ़ा बताया है, इसे गुनगुना करके पियो और ठंडी चीजें मत खाना।"
        elif "पेट" in q_lower or "गैस" in q_lower or "एसिडिटी" in q_lower or "कब्ज" in q_lower:
            intro = "पेट की गैस और भारीपन के लिए सौंफ और भुने जीरे का पानी बहुत जल्दी आराम देता है। तला-भुना खाना बंद रखो और दिन में गुनगुना पानी पियो।"
        elif "दर्द" in q_lower or "घुटने" in q_lower or "कमर" in q_lower or "जोड़ों" in q_lower:
            intro = "जोड़ों और बदन के दर्द में हल्दी वाला दूध और मेथी दाना बहुत आराम पहुंचाते हैं। रोज रात को पैरों के तलवों की तेल से मालिश जरूर किया करो।"
        else:
            intro = "मैं तुम्हारी दादी माँ हूँ बेटा, तुम्हारे स्वास्थ्य की रक्षा के लिए हमेशा तैयार। समय पर खाना, समय पर दवा और मन को शांत रखना ही सबसे बड़ा इलाज है।"
            
        speech = intro
        if remedy_items:
            speech += f" आराम के लिए {remedy_items[0]['title']} का घरेलू नुस्खा अपनाओ।"

    else:
        intro = f"My dear child, your Dadi-Ma is here to look after you. Adhering to your prescribed medicines on schedule is vital. "
        if med_count > 0:
            intro += f"You have {med_count} active scheduled medications. Always take them with plain water after wholesome meals. "
        speech = intro
        if remedy_items:
            speech += f" For soothing relief, you may try: {remedy_items[0]['title']}."

    return {
        "status": "success",
        "is_emergency": False,
        "response_text": intro,
        "speech_text": speech,
        "patient_context": {
            "diagnosis": diagnosis or "General Wellness",
            "medications_count": med_count,
            "language": lang
        },
        "remedies": remedy_items
    }


# ==============================================================================
# 5. FLASK BLUEPRINT & ROUTE HANDLERS
# ==============================================================================
from flask import Blueprint, request, jsonify

dadi_ma_bp = Blueprint("dadi_ma", __name__, url_prefix="/api/dadi-ma")


@dadi_ma_bp.route("/chat", methods=["POST"])
def dadi_ma_chat():
    data = request.get_json(silent=True) or {}
    query = data.get("query", "").strip()
    language = data.get("language", "hi")
    medications = data.get("medications", [])
    diagnosis = data.get("diagnosis", None)

    if not query:
        return jsonify({"status": "error", "message": "Missing 'query' field"}), 400

    resp = format_dadi_ma_response(query=query, lang=language, medications=medications, diagnosis=diagnosis)
    return jsonify(resp), 200


@dadi_ma_bp.route("/remedies", methods=["GET"])
def dadi_ma_remedies():
    language = request.args.get("language", "hi")
    query = request.args.get("query", "")
    remedies = search_remedies(query=query, lang=language)
    formatted = []
    for r in remedies:
        formatted.append({
            "id": r["id"],
            "title": r["title"].get(language, r["title"]["en"]),
            "description": r["description"].get(language, r["description"]["en"]),
            "ingredients": r["ingredients"].get(language, r["ingredients"]["en"]),
            "preparation": r["preparation"].get(language, r["preparation"]["en"]),
            "precaution": r["precaution"].get(language, r["precaution"]["en"]),
        })
    return jsonify({
        "status": "success",
        "count": len(formatted),
        "remedies": formatted
    }), 200


@dadi_ma_bp.route("/daily-greeting", methods=["POST"])
def dadi_ma_daily_greeting():
    data = request.get_json(silent=True) or {}
    hour = data.get("hour", 8)
    language = data.get("language", "hi")
    patient_name = data.get("patient_name", "बेटा")
    greeting = get_dadi_ma_greeting(hour=hour, lang=language, patient_name=patient_name)
    return jsonify({
        "status": "success",
        "data": greeting
    }), 200


@dadi_ma_bp.route("/explain-prescription", methods=["POST"])
def dadi_ma_explain_prescription():
    data = request.get_json(silent=True) or {}
    doctor = data.get("doctor_name", "डॉ. एस. के. शर्मा")
    diagnosis = data.get("diagnosis", "सामान्य परामर्श")
    language = data.get("language", "hi")
    medications = data.get("medications", [])

    med_names = [m.get("name", "") for m in medications if m.get("name")]
    meds_str = ", ".join(med_names)

    if language == "mr":
        explanation = f"नमस्कार! डॉक्टर {doctor} यांनी {diagnosis} साठी प्रिस्क्रिप्शन दिले आहे. यामध्ये {meds_str} या औषधांचा समावेश आहे. सर्व गोळ्या वेळेवर घ्या."
    elif language == "hi":
        explanation = f"नमस्ते बेटा! डॉक्टर {doctor} ने {diagnosis} के लिए यह पर्चा लिखा है। इसमें मुख्य रूप से {meds_str} दवाइयाँ हैं। कृपया सभी दवाइयाँ समय पर लें और नियम का पालन करें।"
    else:
        explanation = f"Hello! Dr. {doctor} has prescribed this treatment for {diagnosis}, including {meds_str}. Please take all medications as scheduled."

    return jsonify({
        "status": "success",
        "explanation_text": explanation,
        "medications_breakdown": medications
    }), 200

