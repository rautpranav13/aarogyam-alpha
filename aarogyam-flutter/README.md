# aarogyam-flutter

The Flutter mobile application for Aarogyam — Material 3, pure Flutter (no FlutterFlow), Firebase Auth, and `flutter_dotenv` for secret management.

---

## Prerequisites

| Requirement | Version | Install |
|---|---|---|
| Flutter SDK | 3.x | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.x | Bundled with Flutter |
| Firebase CLI | latest | `npm install -g firebase-tools` |
| FlutterFire CLI | latest | `dart pub global activate flutterfire_cli` |
| Xcode (iOS) | 15+ | Mac App Store |
| Android Studio / SDK | latest | [developer.android.com](https://developer.android.com/studio) |

---

## Setup

### 1. Clone and enter the directory

```bash
git clone https://github.com/rautpranav13/aarogyam-IBM.git
cd aarogyam-IBM/aarogyam-flutter
```

### 2. Create the `.env` file

```bash
cp .env.example .env
```

Open `.env` and fill in every value. See [Environment Variables](#environment-variables) below.

> **Important:** `.env` is listed in `.gitignore` and must never be committed.

### 3. Install Flutter dependencies

```bash
flutter pub get
```

### 4. Configure Firebase

Log in and link the app to your Firebase project:

```bash
firebase login
flutterfire configure
```

`flutterfire configure` writes `lib/firebase_options.dart` automatically. The Firebase API credentials in `.env` must match the same Firebase project.

### 5. Run the app

```bash
# Debug on connected device / emulator
flutter run

# Target a specific device
flutter run -d <device-id>
```

---

## Environment Variables

Copy `.env.example` to `.env` and populate all values. The app will assert at startup if a required key is missing.

| Name | Required | Description | Example |
|---|---|---|---|
| `WATSON_TTS_API_KEY` | ✅ | IBM Watson Text-to-Speech API key | `abc123...` |
| `WATSON_TTS_ENDPOINT` | ✅ | Watson TTS instance endpoint URL | `https://api.eu-gb.text-to-speech.watson.cloud.ibm.com/instances/<id>` |
| `WATSON_STT_API_KEY` | ✅ | IBM Watson Speech-to-Text API key | `abc123...` |
| `WATSON_STT_ENDPOINT` | ✅ | Watson STT instance endpoint URL | `https://api.eu-gb.speech-to-text.watson.cloud.ibm.com/instances/<id>` |
| `RAG_API_URL` | ✅ | Base URL of the deployed RAG chatbot service | `https://aarogyam.onrender.com` |
| `LVM_API_URL` | ✅ | Base URL of the deployed LVM image analysis service | `https://ibmaarogyam.onrender.com` |
| `FIRSTAID_API_URL` | ✅ | Base URL of the deployed first-aid object storage service | `https://your-firstaid-api.onrender.com` |
| `FIREBASE_API_KEY` | ✅ | Firebase Web API key | `AIzaSy...` |
| `FIREBASE_AUTH_DOMAIN` | ✅ | Firebase Auth domain | `your-project.firebaseapp.com` |
| `FIREBASE_PROJECT_ID` | ✅ | Firebase project ID | `your-project-id` |
| `FIREBASE_STORAGE_BUCKET` | ✅ | Firebase Storage bucket | `your-project.appspot.com` |
| `FIREBASE_MESSAGING_SENDER_ID` | ✅ | Firebase Cloud Messaging sender ID | `123456789` |
| `FIREBASE_APP_ID` | ✅ | Firebase App ID | `1:123456789:web:abc...` |
| `FIREBASE_MEASUREMENT_ID` | ✅ | Firebase Analytics measurement ID | `G-XXXXXXX` |

---

## Build Commands

```bash
# Debug build (development)
flutter run --debug

# Release APK (Android)
flutter build apk --release

# Release App Bundle (Android — preferred for Play Store)
flutter build appbundle --release

# Release IPA (iOS — requires a Mac with Xcode)
flutter build ios --release
```

---

## Architecture Notes

- **Material 3** — `ThemeData(useMaterial3: true)` with a teal seed colour (`Color(0xFF00897B)`). All screens use `Theme.of(context)` — no hardcoded colours.
- **Pure Flutter** — zero FlutterFlow packages or generated code. `FlutterFlowTheme`, `FFAppState`, `FlutterFlowModel` have all been removed.
- **Navigation** — [`go_router`](https://pub.dev/packages/go_router) with named routes declared in `lib/core/router/app_router.dart`.
- **State management** — lightweight `ChangeNotifier`-based `BaseModel` per screen (`lib/core/base_model.dart`).
- **Secret management** — [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) loads `.env` at app startup in `main()`. Keys are accessed via `dotenv.env['KEY']`.
- **Internationalisation** — ARB files at `lib/l10n/` (English, Hindi, Arabic), generated via `flutter gen-l10n`.
- **Voice** — IBM Watson STT/TTS called via custom Dart actions in `lib/custom_code/actions/`.
- **AI backends** — API calls to the three Python backends declared in `lib/backend/api_requests/api_calls.dart`.

---

## Project Structure

```
lib/
├── authentication/        # Welcome, login, register, forgot-password, user-info screens
├── backend/
│   ├── api_requests/      # api_calls.dart — watsonchat, process-image, list_objects
│   ├── firebase/          # firebase_config.dart, firebase_user_provider.dart
│   └── schema/            # Firestore data models
├── core/
│   ├── base_model.dart    # ChangeNotifier base for all screen models
│   └── router/
│       └── app_router.dart  # go_router route definitions
├── custom_code/
│   └── actions/
│       ├── text_audio.dart      # Watson TTS
│       └── transcribe_audio.dart # Watson STT
├── l10n/
│   ├── app_en.arb
│   ├── app_hi.arb
│   └── app_ar.arb
├── main_pages/
│   ├── chat_bot/          # AI chatbot screen
│   ├── first_aid/         # First-aid browser
│   ├── home_page/         # Dashboard
│   ├── profile_page/      # User profile + allergies
│   ├── reminder_page/     # Medication reminders
│   └── report_sanner/     # Medical report scanner
├── theme/
│   ├── app_colors.dart    # Named colour constants
│   └── app_theme.dart     # ThemeData factory
├── widgets/               # Shared widgets (chat bubble, disclaimer, etc.)
└── main.dart
```

---

## Contributing

See the root [CONTRIBUTING.md](../CONTRIBUTING.md).
