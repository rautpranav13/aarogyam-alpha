import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';

import '/backend/sqlite/sqlite_manager.dart';
import 'backend/firebase/firebase_config.dart';
import '/theme/app_theme.dart';
import '/core/router/app_router.dart';
import '/core/services/medication_storage_service.dart';
import '/core/services/vernacular_service.dart';
import '/core/services/dadi_ma_service.dart';
import '/l10n/l10n.dart';
import 'app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }

  try {
    await initFirebase();
  } catch (e, st) {
    debugPrint('Error initializing Firebase: $e\n$st');
  }

  try {
    await SQLiteManager.initialize();
  } catch (e, st) {
    debugPrint('Error initializing SQLiteManager: $e\n$st');
  }

  try {
    await AppTheme.initialize();
  } catch (e, st) {
    debugPrint('Error initializing AppTheme: $e\n$st');
  }

  final appState = AppState();
  try {
    await appState.initializePersistedState();
  } catch (e, st) {
    debugPrint('Error initializing persisted state: $e\n$st');
  }

  final medService = MedicationStorageService();
  try {
    await medService.initialize();
  } catch (e, st) {
    debugPrint('Error initializing MedicationStorageService: $e\n$st');
  }

  final vernService = VernacularService();
  try {
    await vernService.initialize();
  } catch (e, st) {
    debugPrint('Error initializing VernacularService: $e\n$st');
  }

  final dadiService = DadiMaService();
  try {
    await dadiService.initialize();
  } catch (e, st) {
    debugPrint('Error initializing DadiMaService: $e\n$st');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: medService),
        ChangeNotifierProvider.value(value: vernService),
        ChangeNotifierProvider.value(value: dadiService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = AppTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  late Stream<BaseAuthUser> userStream;
  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    try {
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      _appStateNotifier.update(AarogyamFirebaseUser(currentFirebaseUser));
    } catch (_) {}
    _router = createRouter(_appStateNotifier);
    try {
      userStream = aarogyamFirebaseUserStream()
        ..listen((user) => _appStateNotifier.update(user));
      jwtTokenStream.listen((_) {});
    } catch (e) {
      debugPrint('Error setting up auth stream: $e');
    }
  }

  @override
  void dispose() {
    authUserSub.cancel();
    super.dispose();
  }

  void setLocale(String language) {
    _storeLocale(language);
    final appLang = language.startsWith('mr')
        ? AppLanguage.marathi
        : (language.startsWith('en') ? AppLanguage.english : AppLanguage.hindi);
    VernacularService().setLanguage(appLang);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        AppTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return Consumer<VernacularService>(
      builder: (context, vernService, child) {
        final currentLocale = _createLocale(vernService.langCode);
        return MaterialApp.router(
          title: 'Aarogyam',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeMode,
          routerConfig: _router,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Locale helpers
// ---------------------------------------------------------------------------

const _kLocaleStorageKey = 'aarogyam_language_code';

Locale _createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

Future<void> _storeLocale(String locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kLocaleStorageKey, locale);
}

// ---------------------------------------------------------------------------
// safeSetState extension
// ---------------------------------------------------------------------------

extension StatefulWidgetExtensions on State<StatefulWidget> {
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      // ignore: invalid_use_of_protected_member
      setState(fn);
    }
  }
}
