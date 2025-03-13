import 'package:flutter/material.dart';
import 'package:pod_router/pod_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

// 1. Create your auth notifier
class MyAuthNotifier extends BaseAuthNotifier {
  MyAuthNotifier(super.ref);

  @override
  void initialize() {
    // Your auth initialization logic here
    login();
  }

  Future<void> login() async {
    setLoading();
    // Login implementation
    await Future.delayed(const Duration(seconds: 2));
    setAuthenticated();
  }

  Future<void> logout() async {
    setUnauthenticated();
    // setLoading();
    // await Future.delayed(const Duration(seconds: 1));
    // Logout implementation
  }
}

// 2. Create the auth provider
final authProvider =
    createAuthNotifierProvider<MyAuthNotifier>((ref) => MyAuthNotifier(ref));

// 3. Define your routes manager
class AppRoutesManager extends RoutesManager {
  AppRoutesManager(super.ref);

  @override
  List<String> get protectedRoutes => ['/home'];

  @override
  List<String> get publicRoutes => ['/login'];

  @override
  String get splashRoute => '/splash';

  @override
  String get defaultAuthenticatedRoute => '/home';

  @override
  String get defaultUnauthenticatedRoute => '/login';

  @override
  List<ProviderListenable> get initialDataProviders => [
        // userDataProvider,
        // settingsProvider,
      ];

  @override
  void initializeListeners() {
    super.initializeListeners(); // Don't forget this for initial data loading!

    // Connect auth state to router
    ref.listen(
      authProvider.select((value) => value.status),
      (prev, next) {
        authState.value = next;
      },
      fireImmediately: true,
    );

    // Connect loading state
    ref.listen(
      authProvider.select((value) => value.isLoading),
      (prev, next) {
        isLoading.value = next;
      },
      fireImmediately: true,
    );
  }

  @override
  String? get initialAppFlowRoute => null;
}

// 5. Create the router provider
final routesProvider =
    routesManagerProvider<AppRoutesManager>((ref) => AppRoutesManager(ref));

// 6. Set up the Go Router
final routerProvider = Provider<GoRouter>((ref) {
  final routesManager = ref.watch(routesProvider);

  return GoRouter(
    redirect: routesManager.onRedirect,
    refreshListenable: Listenable.merge(routesManager.refreshables),
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashPage(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => const MaterialPage(
          child: DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginPage(),
        ),
      ),
    ],
  );
});
