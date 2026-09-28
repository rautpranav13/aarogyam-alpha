# Aarogyam: Project Alpha — API Specification

> **Consolidated Backend REST API Specification**  
> Base URL: `http://localhost:5001` (or Tunneled Public HTTPS URL)

---

## 1. Overview
The Aarogyam backend service provides clinical computer vision and speech endpoints powered by **IBM WatsonX AI** (`ibm/granite-vision-3.2-2b`) and **IBM Watson Text-to-Speech**.

---

## 2. Endpoints

### 1. `GET /api/health`
Health check endpoint to verify backend service status and IBM WatsonX connectivity.

#### Response:
```json
{
  "status": "healthy",
  "vision_model": "ibm/granite-vision-3.2-2b",
  "tts_service": "active",
  "version": "2.0.0-alpha"
}
```

---

### 2. `POST /api/digitize-rx`
Analyzes an anonymized handwritten or printed doctor prescription image, extracts all medication entities, normalizes dosage timings into strict 24-hour intervals, and generates vernacular spoken instructions.

#### Headers:
```http
Content-Type: application/json
```

#### Request Body:
```json
{
  "image_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "language": "hi"
}
```

#### Response (200 OK):
```json
{
  "status": "success",
  "data": {
    "medications": [
      {
        "id": 1,
        "name": "Metformin",
        "strength": "500mg",
        "timing_24hr": ["08:30", "20:30"],
        "food_relation": "After Food",
        "instructions": "Take with water immediately after breakfast and dinner",
        "instructions_vernacular": "खाना खाने के तुरंत बाद सुबह और रात को एक गोली लें"
      }
    ]
  }
}
```

#### Error Response (400 Bad Request):
```json
{
  "status": "error",
  "message": "Missing image_base64 parameter or invalid base64 encoding."
}
```

---

### 3. `POST /api/verify-strip`
Inspects an image of a pharmaceutical blister strip or medicine box to confirm whether it matches the scheduled medication before the patient swallows it.

#### Request Body:
```json
{
  "image_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRg...",
  "expected_drug": "Metformin",
  "expected_strength": "500mg",
  "language": "hi"
}
```

#### Response (200 OK - Match):
```json
{
  "status": "success",
  "verified": true,
  "detected_text": "METFORMIN HYDROCHLORIDE 500 MG",
  "confidence": 0.97,
  "voice_alert_vernacular": "सत्यापित: यह मेटफॉर्मिन 500mg की गोली है। कृपया इसे पानी के साथ लें।",
  "action": "ALLOW_CONSUMPTION"
}
```

#### Response (200 OK - Mismatch):
```json
{
  "status": "success",
  "verified": false,
  "detected_text": "AMLODIPINE 5 MG",
  "confidence": 0.95,
  "voice_alert_vernacular": "चेतावनी! यह गलत दवा है। यह एम्लोडिपिन है, मेटफॉर्मिन नहीं। इसे न लें।",
  "action": "BLOCK_CONSUMPTION"
}
```

---

### 4. `POST /api/vernacular-tts`
Synthesizes spoken audio from text using IBM Watson Text-to-Speech in native Indic accents.

#### Request Body:
```json
{
  "text": "यह गोली सुबह खाने के बाद लेनी है",
  "language": "hi"
}
```

#### Response:
`audio/mpeg` binary stream (playable directly on Android via `audioplayers`).

---

### 5. `POST /api/dadi-ma/chat`
Dadi-Ma AI Companion Chat: Conversational vernacular health companion powered by IBM Granite. Explains drug prescriptions in grandmotherly terminology, checks patient schedule, recommends safe Ayurvedic home remedies, and detects life-threatening emergency symptoms.

#### Request Body:
```json
{
  "query": "मुझे रात में सूखी खांसी हो रही है, क्या करूं?",
  "language": "hi",
  "patient_name": "बेटा",
  "medications": [
    {
      "name": "Metformin 500mg",
      "frequency": "1-0-1",
      "food_relation": "After Food"
    }
  ],
  "diagnosis": "Type 2 Diabetes"
}
```

#### Response (200 OK - Standard Guidance):
```json
{
  "status": "success",
  "is_emergency": false,
  "response_text": "घबराओ मत बेटा! मौसम बदलने से जुकाम-खांसी हो जाती है। मैंने नीचे तुलसी-अदरक का काढ़ा बताया है, इसे पियो।",
  "speech_text": "घबराओ मत बेटा! तुलसी-अदरक का काढ़ा पियो और ठंडी चीजें मत खाना।",
  "action_required": "NONE",
  "remedies": [
    {
      "id": "cough_cold",
      "title": "तुलसी, अदरक और शहद का काढ़ा (खांसी-जुकाम)",
      "description": "खांसी और गले की खराश के लिए दादी-माँ का सबसे भरोसेमंद नुस्खा।",
      "ingredients": ["5-6 ताजी तुलसी की पत्तियां", "1 छोटा टुकड़ा अदरक", "1 चम्मच शहद", "1 कप पानी"],
      "preparation": "पानी में तुलसी और अदरक उबालें। गुनगुना होने पर शहद मिलाकर धीरे-धीरे पिएं।",
      "precaution": "मधुमेह के मरीज शहद की मात्रा कम रखें।"
    }
  ]
}
```

#### Response (200 OK - Emergency Red-Flag Triage):
```json
{
  "status": "emergency",
  "is_emergency": true,
  "emergency_warning": "⚠️ आपातकालीन चेतावनी: यह गंभीर लक्षण हो सकते हैं। कृपया तुरंत नजदीकी डॉक्टर से मिलें या १०८ एम्बुलेंस को कॉल करें।",
  "action_required": "CALL_108_OR_VISIT_DOCTOR",
  "remedies": []
}
```

---

### 6. `GET / POST /api/dadi-ma/remedies`
Returns curated, clinically safe traditional Ayurvedic home-care remedies categorized by condition (respiratory, digestive, pain relief, chronic care, sleep).

#### Parameters:
- `language`: `hi` | `mr` | `en`
- `category` (optional): `respiratory` | `digestive` | `pain_relief` | `chronic_care` | `mental_wellness`
- `query` (optional): search string

#### Response (200 OK):
```json
{
  "status": "success",
  "count": 6,
  "language": "hi",
  "remedies": [
    {
      "id": "cough_cold",
      "category": "respiratory",
      "title": "तुलसी, अदरक और शहद का काढ़ा (खांसी-जुकाम)",
      "ingredients": ["..."],
      "preparation": "...",
      "precaution": "..."
    }
  ]
}
```

---

### 7. `GET / POST /api/dadi-ma/daily-greeting`
Generates dynamic, time-of-day contextual maternal greetings and daily wellness encouragement.

#### Parameters:
- `hour`: integer (0-23)
- `language`: `hi` | `mr` | `en`

#### Response (200 OK):
```json
{
  "status": "success",
  "data": {
    "period": "morning",
    "title": "शुभ प्रभात! 🌅",
    "text": "नमस्ते बेटा! पहले खाली पेट वाली दवा लें, फिर पौष्टिक नाश्ता करें और गुनगुना पानी पिएं।",
    "audio_text": "शुभ प्रभात! सुबह की दवाइयाँ समय पर लें और नाश्ता करें।"
  }
}
```

---

### 8. `POST /api/dadi-ma/explain-prescription`
Deep prescription explainer breaking down every medicine, why it was prescribed, food timings, and recovery home habits.

#### Request Body:
```json
{
  "doctor_name": "डॉ. एस. के. शर्मा",
  "diagnosis": "उच्च रक्तचाप और मधुमेह",
  "language": "hi",
  "medications": [
    {
      "name": "Metformin 500mg",
      "frequency": "1-0-1",
      "instructions_vernacular": "भोजन के बाद पानी के साथ लें।"
    }
  ]
}
```

