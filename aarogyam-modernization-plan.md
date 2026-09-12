# Aarogyam — Complete Project Modernization Plan

## Overview

**Goal:** Transform the Aarogyam project from a FlutterFlow-generated prototype into a production-grade, open-source health-literacy platform.

**Scope:**
- Flutter mobile app: full removal of FlutterFlow, pure-Flutter rewrite of theme/widgets/navigation/i18n, Material 3 UI refresh, `flutter_dotenv` secret management, dependency upgrades.
- Three Python backends (rag-chatBot, lvm-watsonx, firstaid-object-storage): move all credentials to environment variables, optimize startup/caching, pin latest non-conflicting packages.
- README and documentation: production-grade public-release quality.

**Non-goals:**
- Changing the navigation structure or existing page layouts beyond visual polish.
- Switching deployment platform (staying on Render.com pip-based).
- Adding new features beyond what already exists.

**Approach:** Each sub-task is self-contained and ordered so that foundational work (theme, env, packages) comes before per-screen work, and backend work is independent of Flutter work.

---

## Sub-Tasks

---

### ST-1 — Remove FlutterFlow Infrastructure & Set Up Pure-Flutter Foundation

**Status:** `[ ] pending`

**Intent:**
Delete the entire `lib/flutter_flow/` directory and all FlutterFlow package dependencies, then put in place the pure-Flutter equivalents that every other sub-task will build on:
- Custom `AppTheme` (Material 3, `ColorScheme.fromSeed`, teal/indigo palette)
- Base screen model pattern (`ChangeNotifier`-based, replacing `FlutterFlowModel`)
- `flutter_dotenv` setup (`.env` asset, `.gitignore` entry)
- Navigation via `go_router` (routes kept identical, FlutterFlow serialization removed)
- Official `flutter_localizations` + `intl` ARB file system (replacing `internationalization.dart`)
- `pubspec.yaml` cleaned — remove `flutterflow_debug_panel`, `debug_panel_proto`, and any other FF-only packages; add `flutter_dotenv`, update everything else to latest non-conflicting versions.

**Expected Outcomes:**
- `lib/flutter_flow/` directory no longer exists.
- App compiles with zero FlutterFlow imports.
- `AppTheme.of(context)` (or `Theme.of(context)`) replaces every `FlutterFlowTheme.of(context)` call.
- `.env` is loaded at app startup via `flutter_dotenv`.
- `go_router` routes are intact, referencing the same page widgets.
- ARB files exist for all existing string keys (en, hi, ar).
- `pubspec.yaml` has no GitHub-sourced FlutterFlow packages.

**Todo List:**
1. Delete `lib/flutter_flow/` directory entirely.
2. Create `lib/theme/app_theme.dart` — `ThemeData` with `useMaterial3: true`, `ColorScheme.fromSeed(seedColor: Color(0xFF00897B))` (teal), custom `TextTheme` using Google Fonts Poppins.
3. Create `lib/theme/app_colors.dart` — named color constants (primary, secondary, surface, error, etc.).
4. Create `lib/core/base_model.dart` — `ChangeNotifier`-based `BaseModel<T extends StatefulWidget>` with `initState`, `dispose` lifecycle hooks (drop-in for `FlutterFlowModel`).
5. Create `.env` at `aarogyam-flutter/.env` with keys:
   - `WATSON_TTS_API_KEY`, `WATSON_TTS_ENDPOINT`
   - `WATSON_STT_API_KEY`, `WATSON_STT_ENDPOINT`
   - `RAG_API_URL`, `LVM_API_URL`, `FIRSTAID_API_URL`
   - `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIREBASE_PROJECT_ID`, `FIREBASE_STORAGE_BUCKET`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_APP_ID`, `FIREBASE_MEASUREMENT_ID`
6. Add `.env` to `pubspec.yaml` assets section and add `flutter_dotenv` dependency.
7. Add `.env` to `.gitignore`; create `.env.example` with placeholder values.
8. Rewrite `lib/flutter_flow/nav/nav.dart` → `lib/core/router/app_router.dart` using pure `go_router` (same routes, remove FlutterFlow project URL references and serialization helpers).
9. Create `lib/l10n/app_en.arb`, `lib/l10n/app_hi.arb`, `lib/l10n/app_ar.arb` with all existing string keys migrated from `internationalization.dart`.
10. Update `pubspec.yaml`: remove `flutterflow_debug_panel`, `debug_panel_proto`, `translator`; add `flutter_dotenv ^5.2.1`, `flutter_localizations`, `intl`; upgrade all other packages to latest non-conflicting.
11. Update `lib/main.dart`: initialize `flutter_dotenv`, remove `FFAppState` FlutterFlow init, set `localizationsDelegates`, `supportedLocales`, router from `app_router.dart`.

**Relevant Context:**
- `aarogyam-flutter/lib/flutter_flow/` — entire directory to delete
- `aarogyam-flutter/pubspec.yaml` — dependency manifest
- `aarogyam-flutter/lib/main.dart` — app entry point
- `aarogyam-flutter/lib/app_state.dart` — `FFAppState` global state (keep the state data, remove FF prefix)
- `aarogyam-flutter/lib/flutter_flow/nav/nav.dart` — existing routes to preserve
- `aarogyam-flutter/lib/flutter_flow/internationalization.dart` — string keys to migrate

---

### ST-2 — Backend: Secrets via `.env` & Package Upgrades

**Status:** `[ ] pending`

**Intent:**
Move all hardcoded API keys and credentials out of Python source files for all three backends. Create `.env` files (not committed), `.env.example` files (committed), and update `requirements.txt` with pinned latest non-conflicting package versions. Add `python-dotenv` to load env vars locally; on Render.com the same env var names are set via the dashboard.

**Expected Outcomes:**
- Zero hardcoded secrets in any `app.py`.
- Each backend has `.env.example` and loads via `os.getenv()`.
- `requirements.txt` files reference pinned, non-conflicting, up-to-date versions.
- `render.yaml` updated to document required env var names (without values).

**Todo List:**

**rag-chatBot:**
1. Add `python-dotenv` load at top of `rag-chatBot/flask_app/app.py`.
2. Replace hardcoded `api_key`, `project_id` with `os.getenv("WATSONX_API_KEY")`, `os.getenv("WATSONX_PROJECT_ID")`.
3. Create `rag-chatBot/.env.example` with `WATSONX_API_KEY=`, `WATSONX_PROJECT_ID=`, `WATSONX_URL=`.
4. Add `.env` to `rag-chatBot/.gitignore`.
5. Pin `requirements.txt` to latest: `flask==3.1.0`, `langchain==0.3.x`, `langchain-ibm==0.3.x`, `langchain-chroma==0.2.x`, `chromadb==0.6.x`, `gunicorn==23.0.0`, `flask-cors==5.x`, `ibm-watsonx-ai` (latest), remove `PyPDF2` (use `pypdf`), update `werkzeug` to latest.
6. Update `render.yaml` to document env var keys (empty values, marked as required).

**lvm-watsonx:**
7. Add `python-dotenv` load to `lvm-watsonx/flask_app/app.py`.
8. Replace hardcoded `api_key`, `project_id`, region URL with `os.getenv()` calls.
9. Create `lvm-watsonx/.env.example` with `WATSONX_API_KEY=`, `WATSONX_PROJECT_ID=`, `WATSONX_URL=`.
10. Pin `lvm-watsonx/requirements.txt` to latest compatible versions.
11. Update `lvm-watsonx/render.yaml`.

**firstaid-object-storage:**
12. Replace placeholder credential strings in `firstaid-object-storage/app.py` with `os.getenv()`.
13. Create `firstaid-object-storage/.env.example` with `COS_API_KEY_ID=`, `COS_INSTANCE_CRN=`, `COS_ENDPOINT=`, `BUCKET_NAME=`.
14. Pin `firstaid-object-storage/requirements.txt` (`flask==3.1.0`, `ibm-cos-sdk` latest, `gunicorn==23.0.0`).
15. Update `firstaid-object-storage/render.yaml`.

**Relevant Context:**
- `rag-chatBot/flask_app/app.py` lines 20-24
- `lvm-watsonx/flask_app/app.py` lines 56-64
- `firstaid-object-storage/app.py` lines 10-13
- All three `requirements.txt` and `render.yaml` files

---

### ST-3 — RAG Chatbot Backend: Performance Optimization

**Status:** `[ ] pending`

**Intent:**
The RAG chatbot rebuilds the entire vector store on every cold start — PDF loading, text splitting, embedding generation, Chroma indexing. On Render.com free tier this takes 60+ seconds. Fix by persisting the Chroma vector store to `./chroma_db/` and skipping rebuild if it already exists. Also add response caching for identical queries and fix the incorrect `startCommand` in `render.yaml`.

**Expected Outcomes:**
- First startup builds and persists `./chroma_db/`.
- Subsequent startups load in under 5 seconds (no re-embedding).
- Duplicate queries within a session are served from an in-memory cache.
- `render.yaml` `startCommand` points to the correct path.
- CORS is properly configured (not wildcard `*` on production paths).

**Todo List:**
1. In `rag-chatBot/flask_app/app.py`, wrap Chroma initialization: if `./chroma_db/` exists use `Chroma(persist_directory=..., embedding_function=...)`, else build from documents and persist.
2. Replace `PyPDF2.PdfReader` with `pypdf.PdfReader` (PyPDF2 is unmaintained).
3. Add a simple `functools.lru_cache` or `dict`-based in-process query cache keyed on the normalized query string.
4. Remove hard-coded `chunk_size` and `overlap` from code — read from env vars with sensible defaults.
5. Fix `render.yaml` `startCommand` from `python flask_server.py` to `gunicorn flask_app.app:app --bind 0.0.0.0:$PORT --workers 2`.
6. Tighten CORS: set `origins` to the Flutter app domain or `*` only if explicitly enabled via env var.
7. Add a `GET /health` endpoint returning `{"status": "ok", "vectorstore": "ready"}`.

**Relevant Context:**
- `rag-chatBot/flask_app/app.py` lines 44-79 (PDF + Chroma init)
- `rag-chatBot/flask_app/app.py` lines 85-134 (endpoint + QA chain)
- `rag-chatBot/render.yaml`

---

### ST-4 — LVM Watsonx Backend: Optimization & Hardening

**Status:** `[ ] pending`

**Intent:**
The image-processing service fetches the image from a URL and base64-encodes it on every request. Add input validation, a timeout on the upstream image fetch, a `GET /health` endpoint, and ensure proper error responses. Fix any missing CORS headers.

**Expected Outcomes:**
- Requests with missing/invalid `image_url` or `user_query` return 400 with a descriptive message.
- Upstream image fetch has a configurable timeout (default 10 s via env var).
- `GET /health` endpoint returns 200.
- CORS configured consistently with rag-chatBot.

**Todo List:**
1. Add input validation in the `/process-image` handler — return 400 if `image_url` or `user_query` is missing or empty.
2. Add `timeout` parameter to `requests.get(image_url, timeout=int(os.getenv("IMAGE_FETCH_TIMEOUT", 10)))`.
3. Add `GET /health` endpoint.
4. Ensure `flask-cors` is applied and CORS origins match rag-chatBot pattern.
5. Wrap model call in try/except — return 500 with `{"error": "message"}` on LLM failure.

**Relevant Context:**
- `lvm-watsonx/flask_app/app.py`
- `lvm-watsonx/render.yaml`

---

### ST-5 — First Aid Object Storage Backend: Hardening

**Status:** `[ ] pending`

**Intent:**
The first-aid backend has placeholder credentials. After ST-2 loads them from env vars, this task adds input validation, proper 404 when a folder is empty, a health endpoint, and fixes the CORS setup.

**Expected Outcomes:**
- `GET /list_objects` with missing `folder_name` returns 400.
- Empty folder result returns 200 with `{"objects": []}` (not a 500).
- `GET /health` returns 200.
- CORS configured.

**Todo List:**
1. Add `folder_name` query param validation — return 400 if missing.
2. Handle empty S3 listing response (no `Contents` key) gracefully.
3. Add `GET /health` endpoint.
4. Add `flask-cors` and configure origins.

**Relevant Context:**
- `firstaid-object-storage/app.py`

---

### ST-6 — Flutter App: Secrets Moved to `.env`

**Status:** `[ ] pending`

**Intent:**
Replace every hardcoded secret in the Flutter app with `dotenv.env['KEY']` lookups. This includes Watson TTS/STT API keys and endpoint URLs in `text_audio.dart` and `transcribe_audio.dart`, the Firebase config in `firebase_config.dart`, and the API base URLs in `api_calls.dart`. Depends on ST-1 (`.env` file created, `flutter_dotenv` loaded).

**Expected Outcomes:**
- Zero hardcoded API keys, endpoints, or Firebase config values in Dart source.
- All values read from `.env` via `dotenv.env['KEY']` with a runtime assertion if key is missing.
- `.env.example` documents all required keys.

**Todo List:**
1. In `lib/custom_code/actions/text_audio.dart`: replace hardcoded API key and URL with `dotenv.env['WATSON_TTS_API_KEY']` and `dotenv.env['WATSON_TTS_ENDPOINT']`.
2. In `lib/custom_code/actions/transcribe_audio.dart`: replace hardcoded API key and URL with `dotenv.env['WATSON_STT_API_KEY']` and `dotenv.env['WATSON_STT_ENDPOINT']`.
3. In `lib/backend/api_requests/api_calls.dart`: replace hardcoded `https://ibmaarogyam.onrender.com` and `https://aarogyam.onrender.com` with `dotenv.env['LVM_API_URL']` and `dotenv.env['RAG_API_URL']`.
4. In `lib/backend/firebase/firebase_config.dart`: replace all hardcoded Firebase config values with `dotenv.env[...]` lookups.
5. Update `aarogyam-flutter/.env.example` to document all keys added in steps 1-4.

**Relevant Context:**
- `aarogyam-flutter/lib/custom_code/actions/text_audio.dart`
- `aarogyam-flutter/lib/custom_code/actions/transcribe_audio.dart`
- `aarogyam-flutter/lib/backend/api_requests/api_calls.dart`
- `aarogyam-flutter/lib/backend/firebase/firebase_config.dart`

---

### ST-7 — Flutter App: Authentication Screens — Material 3 Redesign

**Status:** `[ ] pending`

**Intent:**
Rebuild all authentication screens (welcome, login, create account, forgot password, user info) as pure-Flutter widgets using Material 3 components. Remove all `FlutterFlowTheme`, `FlutterFlowModel`, and FlutterFlow widget references. Keep the same navigation flow and form logic.

**Expected Outcomes:**
- All 5 auth screens compile with zero FlutterFlow imports.
- Screens use `Theme.of(context)`, standard `TextFormField`, `FilledButton`, `OutlinedButton`.
- Existing Firebase auth logic is preserved.
- Design matches the teal/indigo Material 3 palette.

**Todo List:**
1. Rewrite `auth_welcome_screen/auth_welcome_screen_widget.dart` — hero illustration, app name, "Sign In" / "Create Account" buttons.
2. Rewrite `auth_login/auth_login_widget.dart` — email + password fields, forgot password link, sign-in FilledButton, social/Google sign-in if present.
3. Rewrite `auth_create/auth_create_widget.dart` — registration form, validation.
4. Rewrite `auth_forgot_password/auth_forgot_password_widget.dart`.
5. Rewrite `auth_user_info/auth_user_info_widget.dart` — profile setup (gender, age, height, weight, allergies).
6. Replace all `*Model extends FlutterFlowModel` with `*Model extends BaseModel` (from ST-1 `lib/core/base_model.dart`).
7. Replace `FFLocalizations.of(context).getText(key)` with `AppLocalizations.of(context)!.key` using ARB keys from ST-1.

**Relevant Context:**
- `aarogyam-flutter/lib/authentication/` — all sub-folders
- `aarogyam-flutter/lib/auth/firebase_auth/firebase_user_provider.dart`

---

### ST-8 — Flutter App: Home Page — Material 3 Redesign

**Status:** `[ ] pending`

**Intent:**
Rebuild the home page with Material 3 cards, updated swipeable health card deck, and proper use of `Theme.of(context)`. Remove all FlutterFlow dependencies. Keep the swipeable card interaction and existing navigation tiles.

**Expected Outcomes:**
- `home_page_widget.dart` compiles with zero FlutterFlow imports.
- Uses `Card` with `elevation` and `SurfaceTintColor` per Material 3.
- `flutter_card_swiper` integration kept.
- `HomePageModel extends BaseModel`.

**Todo List:**
1. Replace `FlutterFlowTheme.of(context)` with `Theme.of(context)` throughout `home_page_widget.dart`.
2. Replace `FlutterFlowIconButton` with standard `IconButton`.
3. Replace `FFLocalizations` calls with `AppLocalizations`.
4. Update `HomePageModel` to extend `BaseModel`.
5. Use `SliverAppBar` with Material 3 styling for the top bar.
6. Apply `Card` + `ListTile` for health metric summary items.

**Relevant Context:**
- `aarogyam-flutter/lib/main_pages/home_page/`

---

### ST-9 — Flutter App: Chat Bot Screen — Material 3 Redesign

**Status:** `[ ] pending`

**Intent:**
The chat bot screen is the most complex — it contains the RAG API call, TTS/STT integration, and a multi-turn chat UI. Remove all FlutterFlow infrastructure, apply Material 3 chat bubble design (user bubbles right, AI bubbles left), keep all existing functionality.

**Expected Outcomes:**
- `chat_bot_widget.dart` compiles with zero FlutterFlow imports.
- Chat bubbles styled with Material 3 `Card`/`Container` with `borderRadius`.
- Voice record FAB uses `FloatingActionButton.extended` with animation.
- TTS/STT calls use `dotenv.env[...]` (ST-6).
- `ChatBotModel extends BaseModel`.

**Todo List:**
1. Replace `FlutterFlowTheme.of(context)` and all FF widget references in `chat_bot_widget.dart`.
2. Implement a `ChatBubble` widget: user messages right-aligned with `primaryContainer` color; AI messages left-aligned with `surfaceVariant`.
3. Style the voice input FAB with `FloatingActionButton` + pulse animation using `flutter_animate`.
4. Update `ChatBotModel` to extend `BaseModel`.
5. Preserve all existing API call logic (ST-6 will have already moved secrets out).
6. Add a typing indicator (three animated dots) while awaiting AI response.

**Relevant Context:**
- `aarogyam-flutter/lib/main_pages/chat_bot/chat_bot_widget.dart`
- `aarogyam-flutter/lib/main_pages/chat_bot/chat_bot_model.dart`
- `aarogyam-flutter/lib/custom_code/actions/text_audio.dart`
- `aarogyam-flutter/lib/custom_code/actions/transcribe_audio.dart`

---

### ST-10 — Flutter App: Report Scanner Screen — Material 3 Redesign

**Status:** `[ ] pending`

**Intent:**
Rebuild the report scanner screen with Material 3 styling. Keep image pick → upload → process-image API → extract medications → reminder flow intact. Improve the image upload UX with a prominent upload zone and progress indicator.

**Expected Outcomes:**
- `report_sanner_widget.dart` compiles with zero FlutterFlow imports.
- Image upload zone is a `DashedBorder` card or outlined container with upload icon.
- Processing state shows `CircularProgressIndicator.adaptive()`.
- HTML result rendered with `flutter_html`.
- `ReportSannerModel extends BaseModel`.

**Todo List:**
1. Replace FlutterFlow references in `report_sanner_widget.dart` and `report_sanner_model.dart`.
2. Build an `ImagePickerCard` widget: dashed border, upload icon, tap to pick, shows thumbnail after pick.
3. Add a loading overlay `Stack` with `CircularProgressIndicator.adaptive()` during API call.
4. Render the HTML response using `flutter_html` with a custom `Style` matching `Theme.of(context)`.
5. Update `ReportSannerModel` to extend `BaseModel`.

**Relevant Context:**
- `aarogyam-flutter/lib/main_pages/report_sanner/`

---

### ST-11 — Flutter App: First Aid, Reminder & Profile Screens — Material 3 Redesign

**Status:** `[ ] pending`

**Intent:**
Apply the same Material 3 / pure-Flutter treatment to the remaining main screens: First Aid, Reminder, and Profile/Allergies pages.

**Expected Outcomes:**
- All three screen directories compile with zero FlutterFlow imports.
- Consistent Material 3 design across all screens.
- All `*Model` classes extend `BaseModel`.

**Todo List:**
1. Rewrite `first_aid/` widgets — grid of first-aid categories, video/image viewer.
2. Rewrite `reminder_page/` — list of medication reminders, add/edit bottom sheet.
3. Rewrite `profile_page/` and `profile_page/allergies/` — user info cards, allergy chips.
4. Update all `*Model` classes to extend `BaseModel`.
5. Replace all FlutterFlow widget/theme/i18n references.
6. Rewrite shared widgets in `lib/widgets/` (reminder list, AI disclaimer, user info) with Material 3.

**Relevant Context:**
- `aarogyam-flutter/lib/main_pages/first_aid/`
- `aarogyam-flutter/lib/main_pages/reminder_page/`
- `aarogyam-flutter/lib/main_pages/profile_page/`
- `aarogyam-flutter/lib/widgets/`

---

### ST-12 — Flutter App: App-Wide Polish & Performance

**Status:** `[ ] pending`

**Intent:**
Cross-cutting improvements that don't belong to a single screen: bottom navigation bar Material 3 update, splash screen, app icon, `flutter_animate` micro-animations on page transitions, performance audit (remove unused imports, ensure `const` constructors everywhere possible), and clean up `app_state.dart`.

**Expected Outcomes:**
- `NavigationBar` (Material 3) replaces any old bottom nav.
- `flutter_animate` page transitions on route change.
- `const` constructors on all leaf widgets.
- No unused imports or dead code.
- `AppState` renamed from `FFAppState`, removed FF dependency.

**Todo List:**
1. Implement Material 3 `NavigationBar` in the root scaffold.
2. Add `flutter_animate` `FadeTransition` / `SlideTransition` on route push/pop.
3. Audit all widget files for `const` constructor opportunities.
4. Remove all unused imports (especially `package:flutter_flow/`).
5. Rename `FFAppState` → `AppState`, remove FF-specific fields, keep health data fields.
6. Add `flutter_native_splash` configuration for splash screen matching the new palette.

**Relevant Context:**
- `aarogyam-flutter/lib/app_state.dart`
- `aarogyam-flutter/lib/core/router/app_router.dart` (from ST-1)
- `aarogyam-flutter/pubspec.yaml`

---

### ST-13 — Documentation: README & Production Release Prep

**Status:** `[ ] pending`

**Intent:**
Rewrite the root `README.md` and add per-service `README.md` files to a production-grade standard expected of a public open-source release. Document setup, environment variables, deployment, architecture, and contributing guidelines.

**Expected Outcomes:**
- Root `README.md`: project overview, architecture diagram (ASCII or image), tech stack table, quick-start instructions, environment variable documentation for all services.
- `aarogyam-flutter/README.md`: Flutter setup, `.env` keys, build commands.
- `rag-chatBot/README.md`: local setup, env vars, endpoints, performance notes.
- `lvm-watsonx/README.md`: local setup, env vars, endpoints.
- `firstaid-object-storage/README.md`: IBM COS setup, env vars, endpoints.
- `CONTRIBUTING.md` at root.
- `LICENSE` file present (or noted if already present).
- All `.env.example` files cross-referenced in documentation.

**Todo List:**
1. Rewrite `README.md` at root with badges, architecture overview, service map, and setup guide.
2. Write `aarogyam-flutter/README.md`.
3. Write `rag-chatBot/README.md`.
4. Write `lvm-watsonx/README.md`.
5. Write `firstaid-object-storage/README.md`.
6. Write `CONTRIBUTING.md`.
7. Verify or add `LICENSE` (MIT or Apache 2.0 recommended for a health app).
8. Add `.gitignore` entries at root for all `.env` files across the project.

**Relevant Context:**
- `README.md` (root)
- All `render.yaml` files (deployment documentation)
- All `.env.example` files (created in ST-2 and ST-6)

---

## Dependency Summary (Flutter)

| Package | Current | Target |
|---|---|---|
| `firebase_core` | 3.8.0 | latest (3.x) |
| `firebase_auth` | 5.3.3 | latest (5.x) |
| `cloud_firestore` | 5.5.0 | latest (5.x) |
| `go_router` | 12.1.3 | latest (14.x) |
| `flutter_dotenv` | — | 5.2.1 |
| `flutter_animate` | 4.5.0 | latest |
| `google_fonts` | 6.1.0 | latest |
| `audioplayers` | 6.1.0 | latest |
| `flutterflow_debug_panel` | 0.2.0 | **REMOVED** |
| `debug_panel_proto` | 0.1.4 | **REMOVED** |
| `translator` | 1.0.3+1 | **REMOVED** (replaced by ARB/intl) |
| `flutter_native_splash` | — | latest |

## Dependency Summary (Python)

| Package | Current | Target |
|---|---|---|
| `flask` | 2.2.5 | 3.1.0 |
| `gunicorn` | 20.1.0 | 23.0.0 |
| `werkzeug` | 2.2.3 | latest (3.x) |
| `langchain` | unpinned | 0.3.x |
| `langchain-ibm` | unpinned | 0.3.x |
| `langchain-chroma` | unpinned | 0.2.x |
| `chromadb` | unpinned | 0.6.x |
| `PyPDF2` | 3.0.1 | **REMOVED** → `pypdf` latest |
| `python-dotenv` | — | 1.0.1 |
| `ibm-watsonx-ai` | unpinned | latest |
| `flask-cors` | unpinned | 5.x |

---

## Execution Order

The sub-tasks should be executed in this order:

```
ST-1 (Flutter Foundation) ──► ST-6 (Flutter Secrets) ──► ST-7 through ST-12 (Screen Rewrites)
ST-2 (Backend Secrets) ──────► ST-3 (RAG Perf) ──► ST-4 (LVM) ──► ST-5 (FirstAid)
ST-13 (Docs) — can run after all others
```

ST-1 must complete before ST-6 through ST-12. ST-2 must complete before ST-3 through ST-5. ST-3/4/5 and ST-6/7 can be parallelized. ST-13 is last.
