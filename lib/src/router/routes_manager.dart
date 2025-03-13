import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pod_router/src/router/routes_manager_registry_extension.dart';
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

  /// List of data providers that need to be loaded before navigation
  List<ProviderListenable> get initialDataProviders => [];

  /// Initialize all listeners required for routing
  void initializeListeners() {
    // Setup initial data loading listener if providers are specified
    if (initialDataProviders.isNotEmpty) {
      _setupInitialDataListener();
    }
  }

  /// Sets up listener for initial data loading
  void _setupInitialDataListener() {
    // Register this routes manager instance to the registry
    ref.registerRoutesManager(this);

    ref.listen(initialLoadProvider, (prev, next) {
      if (next is AsyncLoading || next is AsyncError) {
        isLoading.value = true;
      } else {
        isLoading.value = false;
      }
    }, fireImmediately: true);
  }

  /// Helper method to log redirects
  void logRedirect(String path, String destination) {
    PackageLogger.debug('''
    Redirecting from: $path
    isLoading: ${isLoading.value}
    authState: ${authState.value}
    appFlowNotifier: ${appFlowNotifier.value}
    Redirecting to: $destination
''', featureType: FeaturesType.routing);
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

  List<ChangeNotifier> get refreshables =>
      [isLoading, authState, appFlowNotifier];
}

/// Provider function to create routes manager provider
Provider<T> routesManagerProvider<T extends RoutesManager>(
    T Function(Ref) create) {
  return Provider<T>((ref) => create(ref));
}


/// Provider to handle loading of initial data
final initialLoadProvider = FutureProvider<bool>((ref) async {
  final routesManager = ref.watch(activeRoutesManagerProvider);

  try {
    // Wait for all initial data providers to load
    List<Future> futures = [];

    for (var provider in routesManager.initialDataProviders) {
      final value = ref.read(provider);
      if (value is Future) {
        futures.add(value);
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    return true;
  } catch (e) {
    PackageLogger.error('Error loading initial data: $e',
        featureType: FeaturesType.routing);
    return false;
  }
});

/// Registry for all routes managers
final routesManagerRegistry = StateProvider<List<RoutesManager>>((ref) => []);

/// Provider to access the active routes manager
final activeRoutesManagerProvider = Provider<RoutesManager>((ref) {
  final managers = ref.watch(routesManagerRegistry);
  if (managers.isEmpty) {
    throw StateError(
        'No routes manager registered. Make sure to register at least one RoutesManager implementation.');
  }
  // Return the first routes manager by default, or implement custom logic to select the active one
  return managers.first;
});

final routesManagerProviders = Provider<List<RoutesManager>>((ref) {
  return [];
});

