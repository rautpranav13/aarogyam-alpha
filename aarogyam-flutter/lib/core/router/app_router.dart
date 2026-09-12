
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/auth/base_auth_user_provider.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// ---------------------------------------------------------------------------
// AppStateNotifier — auth & splash state (no FF dependencies)
// ---------------------------------------------------------------------------

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// When true the app will rebuild on sign-in / sign-out events.
  /// Disable temporarily before performing post-auth navigation.
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Router factory
// ---------------------------------------------------------------------------

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => appStateNotifier.loggedIn
          ? const HomePageWidget()
          : const AuthWelcomeScreenWidget(),
      routes: [
        GoRoute(
          name: '_initialize',
          path: '/',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            appStateNotifier.loggedIn
                ? const HomePageWidget()
                : const AuthWelcomeScreenWidget(),
          ),
        ),
        GoRoute(
          name: 'Profile',
          path: '/profile',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const ProfileWidget(),
          ),
        ),
        GoRoute(
          name: 'ReportSanner',
          path: '/reportSanner',
          pageBuilder: (context, state) {
            final filepath = state.uri.queryParameters['filepath'];
            return _buildPage(
              context,
              state,
              appStateNotifier,
              ReportSannerWidget(filepath: filepath),
            );
          },
        ),
        GoRoute(
          name: 'HomePage',
          path: '/homePage',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const HomePageWidget(),
          ),
        ),
        GoRoute(
          name: 'ResponsePage',
          path: '/responsePage',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const ResponsePageWidget(),
          ),
        ),
        GoRoute(
          name: 'FirstAid',
          path: '/firstAid',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const FirstAidWidget(),
          ),
        ),
        GoRoute(
          name: 'auth_home',
          path: '/authHome',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AuthHomeWidget(),
          ),
        ),
        GoRoute(
          name: 'auth_WelcomeScreen',
          path: '/authWelcomeScreen',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AuthWelcomeScreenWidget(),
          ),
        ),
        GoRoute(
          name: 'auth_Create',
          path: '/authCreate',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AuthCreateWidget(),
          ),
        ),
        GoRoute(
          name: 'auth_Login',
          path: '/authLogin',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AuthLoginWidget(),
          ),
        ),
        GoRoute(
          name: 'auth_ForgotPassword',
          path: '/authForgotPassword',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AuthForgotPasswordWidget(),
          ),
        ),
        GoRoute(
          name: 'ReminderPage',
          path: '/reminderPage',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const ReminderPageWidget(),
          ),
        ),
        GoRoute(
          name: 'ProfilePageCopy',
          path: '/profilePageCopy',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const ProfilePageCopyWidget(),
          ),
        ),
        GoRoute(
          name: 'AllergiesPAgeCopy',
          path: '/allergiesPAgeCopy',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AllergiesPAgeCopyWidget(),
          ),
        ),
        GoRoute(
          name: 'auth_userInfo',
          path: '/authUserInfo',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AuthUserInfoWidget(),
          ),
        ),
        GoRoute(
          name: 'Allergies',
          path: '/allergies',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const AllergiesWidget(),
          ),
        ),
        GoRoute(
          name: 'ChatBot',
          path: '/chatBot',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const ChatBotWidget(),
          ),
        ),
        GoRoute(
          name: 'CustomQuery',
          path: '/customQuery',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const CustomQueryWidget(),
          ),
        ),
        GoRoute(
          name: 'dbpageee',
          path: '/dbpageee',
          pageBuilder: (context, state) => _buildPage(
            context,
            state,
            appStateNotifier,
            const DbpageeeWidget(),
          ),
        ),
      ],
      observers: [routeObserver],
    );

// ---------------------------------------------------------------------------
// Page builder helper
// ---------------------------------------------------------------------------

Page<dynamic> _buildPage(
  BuildContext context,
  GoRouterState state,
  AppStateNotifier appStateNotifier,
  Widget pageWidget,
) {
  // Redirect if a pending redirect location is stored.
  // (Redirect logic is handled in the router's redirect callback below via
  // GoRouterExtensions, but splash/loading is handled here.)
  final child = appStateNotifier.loading
      ? Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        )
      : pageWidget;

  return MaterialPage(key: state.pageKey, child: child);
}

// A global RouteObserver for listening to route changes.
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

// ---------------------------------------------------------------------------
// Navigation extensions
// ---------------------------------------------------------------------------

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

// ---------------------------------------------------------------------------
// RootPageContext — marks the root page for back-navigation detection
// ---------------------------------------------------------------------------

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

// ---------------------------------------------------------------------------
// GoRouterLocationExtension — get the current router location
// ---------------------------------------------------------------------------

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
