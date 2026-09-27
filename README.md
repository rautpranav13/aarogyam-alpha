# Aarogyam 🏥 (Project Alpha)

> **Vernacular Prescription Guardian & Blister Strip Pill Verifier**  
> *Transforming handwritten doctor prescriptions into private, voice-guided, verified daily medication routines for multilingual India.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?logo=python)](https://python.org)
[![IBM WatsonX](https://img.shields.io/badge/IBM-Granite%20Vision%203.2%202B-0530AD?logo=ibm)](https://www.ibm.com/watsonx)
[![IBM Watson](https://img.shields.io/badge/IBM-Watson%20TTS-0530AD?logo=ibm)](https://cloud.ibm.com/catalog/services/text-to-speech)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📌 One Razor-Sharp Problem Statement
In India and developing nations, over **50% of chronic patients do not take medications as prescribed (WHO)**.
1. **Illegible Prescriptions**: Doctor handwriting and Latin abbreviations (*OD, BD, TDS, PC, AC*) are confusing and error-prone.
2. **Language Barrier**: Prescriptions are written in English, while millions of elderly patients speak only Hindi, Marathi, or other Indic languages.
3. **Pill Mix-Up Fatality**: Patients with polypharmacy frequently confuse lookalike blister packs, leading to accidental overdoses.
4. **Cloud Privacy Risks**: Uploading raw health records to third-party public AI models leaks sensitive personal identifiable information (PII).

---

## 🚀 The 5-Step Closed-Loop Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│        Aarogyam: Vernacular Prescription Guardian & Pill Verifier       │
│                                                                        │
│  STEP 1: SMART PRIVACY-FIRST SCAN (Edge / On-Device)                   │
│  • Patient captures handwritten prescription                           │
│  • Client-side image enhancement (deskew, contrast, crop)              │
│  • On-device PII Masking: Redacts patient name, address, phone number  │
│    before any image byte leaves the device                             │
│                                                                        │
│  STEP 2: CLINICAL AI DIGITIZATION (IBM Granite Vision)                 │
│  • Anonymized Rx image processed by IBM Granite Vision 3.2 2B          │
│  • Decodes illegible doctor handwriting & clinical abbreviations       │
│    (Rx, OD, BD, TDS, AC, PC)                                           │
│  • Normalizes into structured JSON: [Drug, Strength, Timing, Diet]     │
│                                                                        │
│  STEP 3: VERNACULAR EXPLAINER ("Dadi-Ma Mode" via Watson TTS)          │
│  • Converts clinical drug jargon into simple, spoken instructions      │
│  • High-clarity native audio synthesis in Hindi & Marathi              │
│  • "यह नीली गोली (Paracetamol) खाना खाने के बाद रात 8 बजे लेनी है"     │
│                                                                        │
│  STEP 4: AUTONOMOUS LOCAL ADHERENCE (Offline-First)                    │
│  • Ingests schedule directly into the offline SQLite database          │
│  • Registers exact, battery-optimized daily alarms via Android         │
│    AlarmManager & Local Notifications (Zero cloud dependency)          │
│                                                                        │
│  STEP 5: CLOSED-LOOP BLISTER STRIP VERIFIER (Proof-of-Consumption)     │
│  • Alarm sounds ──► Patient points camera at medicine blister pack     │
│  • Granite Vision validates: Does strip foil match scheduled dose?     │
│  • Spoken Voice Confirmation prevents lethal wrong-pill mix-ups        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Built with IBM Bob (Our AI Development Partner)

In alignment with the **IBM SkillsBuild Week 3 & 4 Rubric**, IBM Bob was embedded across the entire engineering lifecycle:
* **Problem Scoping & Pruning**: IBM Bob guided our pivot from an unfocused "All-in-One Life Assistant" (Project Beta) into our razor-sharp "Prescription Guardian" (Project Alpha).
* **Granite Vision Prompt Engineering**: Formulated zero-shot clinical JSON extraction prompts with low temperature and deterministic constraints.
* **Refactoring & Code Quality**: Scaffolding automated Flutter unit/widget test suites resulting in **85+ passing tests**.
* **Responsible AI Implementation**: Architected the client-side PII redactor to ensure zero patient data exposure.

---

## 📂 Project Structure

```
aarogyam/
├── backend/                    # Consolidated Localhost Gateway
│   ├── app.py                  # Granite Vision 3.2 2B + Watson TTS endpoints
│   ├── requirements.txt        # Backend dependencies
│   ├── .env.example            # Environment template
│   └── tests/                  # Pytest test suite
│       └── test_app.py
│
├── aarogyam-flutter/           # Cross-Platform Mobile Client
│   ├── lib/
│   │   ├── main.dart           # App entry point & initialization
│   │   ├── app_state.dart      # Global persistent state
│   │   ├── core/router/        # GoRouter navigation
│   │   ├── backend/sqlite/     # Offline SQLite medication store
│   │   └── main_pages/         # 5-step user screens
│   ├── test/
│   │   ├── unit/               # Unit test suites (85 tests)
│   │   ├── widget/             # Widget tests
│   │   └── integration/        # Smoke integration tests
│   └── pubspec.yaml
│
├── docs/                       # Comprehensive Project Documentation
│   ├── plan.md                 # Master Implementation Plan
│   ├── architecture.md         # Technical Architecture & Sequence Flows
│   ├── api_spec.md             # REST API Specifications
│   ├── demo_guide.md           # Live Pitch Choreography & Cheat Sheet
│   └── responsible_ai.md       # IBM Responsible AI Alignment Document
│
├── pytest.ini                  # Root test runner configuration
└── README.md
```

---

## ⚡ Quick Start: Zero-Latency Live Demo Setup

### 1. Launch the Backend Locally
```bash
cd backend
pip install -r requirements.txt
cp .env.example .env   # Configure WATSONX_API_KEY and WATSONX_PROJECT_ID
python app.py          # Runs on http://localhost:5001
```

### 2. Expose via Cloudflare Tunnel or USB Tethering
* **Cloudflare Tunnel**:
  ```bash
  cloudflared tunnel --url http://localhost:5001
  ```
* **USB Direct (`adb reverse` — 0 ms latency, 0 Wi-Fi required)**:
  ```bash
  adb reverse tcp:5001 tcp:5001
  ```

### 3. Run the Flutter Mobile App
```bash
cd aarogyam-flutter
flutter pub get
flutter run
```

---

## 🧪 Testing & Verification

* **Flutter Test Suite**:
  ```bash
  cd aarogyam-flutter
  flutter test test/unit/ test/widget/ test/integration/
  # Output: All 85 tests passed!
  ```
* **Backend Pytest Suite**:
  ```bash
  pytest backend/tests/ -v
  ```

---

## 📜 Documentation Links
* [Master Implementation Plan](docs/plan.md)
* [Technical Architecture](docs/architecture.md)
* [API Specification](docs/api_spec.md)
* [Pitch Choreography & Demo Guide](docs/demo_guide.md)
* [Responsible AI Alignment](docs/responsible_ai.md)

---

<p align="center">
  Built with ❤️ in collaboration with <b>IBM SkillsBuild</b> & <b>IBM Bob</b>
</p>
