import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_status.dart';
import '../utils/package_logger.dart';

/// Base class for route management with integrated auth state
abstract class RoutesManager {
  RoutesManager(this.ref) {
    initializeListeners();
  }

  final Ref ref;

  /// Value notifier for loading state
  final isLoading = ValueNotifier<bool>(false);

  /// Value notifier for auth state
  final authState = ValueNotifier<AuthStatus>(AuthStatus.unknown);

  /// Optional notifier for initial app flow (like onboarding)
  final appFlowNotifier = ValueNotifier<bool>(false);

  /// Define routes that should be accessible only when authenticated
  List<String> get protectedRoutes;

  /// Define routes that should be accessible only when unauthenticated
  List<String> get publicRoutes;

  /// Define your splash route
  String get splashRoute;

  /// Define your default authenticated route
  String get defaultAuthenticatedRoute;

  /// Define your default unauthenticated route
  String get defaultUnauthenticatedRoute;

  /// Define any initial app flow route (like onboarding)
  String? get initialAppFlowRoute;

  /// Initialize all listeners required for routing
  void initializeListeners();

  /// Helper method to log redirects
  void logRedirect(String path, String destination) {
    PackageLogger.debug('''
    Redirecting from: $path
    isLoading: ${isLoading.value}
    authState: ${authState.value}
    appFlowNotifier: ${appFlowNotifier.value}
    Redirecting to: $destination
''');
  }

  /// Main redirect logic that can be used with GoRouter
  FutureOr<String?> onRedirect(
      BuildContext context, GoRouterState state) async {
    final path = state.uri.path;

    // Handle loading and unknown states
    if (isLoading.value || authState.value == AuthStatus.unknown) {
      if (path == splashRoute) return null;
      logRedirect(path, splashRoute);
      return splashRoute;
    }

    // Handle initial app flow (like onboarding)
    if (initialAppFlowRoute != null && appFlowNotifier.value == true) {
      if (path == initialAppFlowRoute) return null;
      logRedirect(path, initialAppFlowRoute!);
      return initialAppFlowRoute;
    }

    // Handle authentication states
    final isLoggedIn = authState.value == AuthStatus.authenticated;
    if (isLoggedIn) {
      if ((publicRoutes.contains(path) || path == splashRoute)) {
        logRedirect(path, defaultAuthenticatedRoute);
        return defaultAuthenticatedRoute;
      } else {
        return null;
      }
    } else {
      // Guest access logic - can be customized
      if (protectedRoutes.contains(path)) {
        logRedirect(path, defaultUnauthenticatedRoute);
        return defaultUnauthenticatedRoute;
      }
      return null;
    }
  }

  /// List of all notifiers that should trigger a route refresh
  List<ChangeNotifier> get refreshables =>
      [isLoading, authState, appFlowNotifier];
}

/// Create a convenience provider for the RoutesManager
Provider<T> routesManagerProvider<T extends RoutesManager>(
    T Function(Ref) create) {
  return Provider<T>((ref) => create(ref));
}
