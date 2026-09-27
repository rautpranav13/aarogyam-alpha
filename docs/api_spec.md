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
