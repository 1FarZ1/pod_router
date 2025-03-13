# pod_router

<p align="center">
    <img src="logo.jpg" alt="pod_router logo" width="200"/>
</p>
A Flutter package that simplifies integration between Go Router and Riverpod state management with authentication handling. This package helps you manage routing based on authentication state and other app conditions, reducing boilerplate and providing a standardized approach.

[![Pub Version](https://img.shields.io/badge/pub-v0.1.0-blue)](https://pub.dev/packages/pod_router)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

## Features

- 🔐 **Authentication-aware routing** - Automatically redirect users based on auth state
- 🔄 **State-driven navigation** - Route changes respond to Riverpod state changes
- 🌊 **Simplified navigation flow** - Handle onboarding, authentication flow, and protected routes
- 📝 **Declarative route definition** - Define protected and public routes clearly
- 🪝 **Easy integration** - Works with your existing Go Router and Riverpod setup
- 🚀 **Initial data loading** - Wait for required data before navigation starts

## Installation

```yaml
dependencies:
  pod_router : ^0.0.1
```

Run:

```
flutter pub get
```

## Quick Start

```dart
import 'package:pod_router/pod_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1. Create your auth notifier
class MyAuthNotifier extends BaseAuthNotifier {
  MyAuthNotifier(Ref ref) : super(ref);
  
  @override
  void initialize() {
    // Your auth initialization logic here
  }
  
  Future<void> login() async {
    setLoading();
    // Login implementation
    setAuthenticated();
  }
  
  Future<void> logout() async {
    setLoading();
    // Logout implementation
    setUnauthenticated();
  }
}

// 2. Create the auth provider
final authProvider = createAuthNotifierProvider<MyAuthNotifier>(
  (ref) => MyAuthNotifier(ref)
);

// 3. Define your routes manager
class AppRoutesManager extends RoutesManager {
  AppRoutesManager(Ref ref) : super(ref);
  
  @override
  List<String> get protectedRoutes => ['/profile', '/settings'];
  
  @override
  List<String> get publicRoutes => ['/login', '/register'];
  
  @override
  String get splashRoute => '/splash';
  
  @override
  String get defaultAuthenticatedRoute => '/home';
  
  @override
  String get defaultUnauthenticatedRoute => '/login';
  
  // 4. Define initial data providers (NEW!)
  @override
  List<ProviderListenable> get initialDataProviders => [
    userDataProvider,
    settingsProvider,
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
    ref.listen(authProvider.select((value) => value.isLoading),
      (prev, next) {
        isLoading.value = next;
      },
      fireImmediately: true,
    );
  }
}

// 5. Create the router provider
final routesProvider = routesManagerProvider<AppRoutesManager>(
  (ref) => AppRoutesManager(ref)
);

// 6. Set up the Go Router
final routerProvider = Provider<GoRouter>((ref) {
  final routesManager = ref.watch(routesProvider);
  
  return GoRouter(
    redirect: routesManager.onRedirect,
    refreshListenable: Listenable.merge(routesManager.refreshables),
    routes: [
      // Your routes here
    ],
  );
});
```

## Detailed Usage

### Authentication State Management

The package provides a `BaseAuthNotifier` class that handles authentication state. Extend this class to implement your specific authentication logic:

```dart
class FirebaseAuthNotifier extends BaseAuthNotifier {
  FirebaseAuthNotifier(Ref ref) : super(ref);
  
  @override
  void initialize() {
    // Listen to Firebase auth changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setAuthenticated();
      } else {
        setUnauthenticated();
      }
    });
  }
  
  Future<void> signIn(String email, String password) async {
    setLoading();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      setUnauthenticated();
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    setLoading();
    await FirebaseAuth.instance.signOut();
  }
}
```

### Route Management

The `RoutesManager` class handles route redirects based on authentication state:

```dart
class MyRoutesManager extends RoutesManager {
  MyRoutesManager(Ref ref) : super(ref);
  
  @override
  List<String> get protectedRoutes => [
    '/profile', 
    '/settings',
    '/dashboard'
  ];
  
  @override
  List<String> get publicRoutes => [
    '/login', 
    '/register',
    '/forgot-password'
  ];
  
  @override
  String get splashRoute => '/splash';
  
  @override
  String get defaultAuthenticatedRoute => '/home';
  
  @override
  String get defaultUnauthenticatedRoute => '/login';
  
  @override
  String? get initialAppFlowRoute => '/onboarding';
  
  @override
  void initializeListeners() {
    super.initializeListeners(); // Important for initial data loading!
    
    // Listen to auth state
    ref.listen(
      authProvider.select((value) => value.status),
      (prev, next) {
        authState.value = next;
      },
      fireImmediately: true,
    );
    
    // Optional: Listen to onboarding completion
    ref.listen(onboardingCompletedProvider, (prev, next) {
      appFlowNotifier.value = !next;
    });
    
    // Other state listeners...
  }
}
```

### Initial Data Loading (NEW!)

The package now supports waiting for initial data to load before navigation:

```dart
class MyRoutesManager extends RoutesManager {
  // ... other overrides
  
  @override
  List<ProviderListenable> get initialDataProviders => [
    // Add providers that need to be loaded before navigation begins
    userDataProvider,
    themeProvider,
    localizationProvider,
    // Any async provider that should complete before navigation
  ];
}
```

### Initial Data Loading

When these providers are specified, the router will:

- Show the splash screen until all data is loaded
- Register the routes manager with the system
- Track loading state automatically
- Provide error handling for data loading failures

### Setting Up Go Router

Integrate with Go Router with Route Manager

```dart
final goRouterProvider = Provider<GoRouter>((ref) {
  final routesManager = ref.watch(routesManagerProvider);
  
  return GoRouter(
    debugLogDiagnostics: true,
    redirect: routesManager.onRedirect,
    refreshListenable: Listenable.merge(routesManager.refreshables),
    initialLocation: '/splash',
    routes: [
      // Your routes...
    ],
  );
});
```

## Complete Example

See the [example](https://github.com/yourusername/pod_router/tree/main/example) folder for a complete implementation.

## Debugging

Enable debug logs to help troubleshoot routing issues:

```dart
void main() {
  PackageLogger.enableDebugLogs = true;
  runApp(ProviderScope(child: MyApp()));
}
```

## Additional Configuration

### Customizing Redirect Logic

You can override the `onRedirect` method in your `RoutesManager` subclass to customize the redirect logic:

```dart
@override
FutureOr<String?> onRedirect(BuildContext context, GoRouterState state) async {
  // Custom logic before calling super
  if (specialCondition) {
    return '/special-route';
  }
  
  // Use default logic
  return await super.onRedirect(context, state);
}
```

### Adding Custom State Triggers

You can add additional `ValueNotifier` objects to trigger route refreshes:

```dart
final themeChanged = ValueNotifier<bool>(false);

@override
List<ChangeNotifier> get refreshables => [
  ...super.refreshables,
  themeChanged,
];
```

### Waiting for Authenticated State

The package provides a utility to wait for authentication state to be determined:

```dart
Future<void> loadInitialData() async {
  // Wait for auth state before proceeding
  final authStatus = await waitForAuthState(ref, authProvider);
  
  // Now you can perform actions based on auth status
  if (authStatus == AuthStatus.authenticated) {
    await ref.read(userDataProvider.notifier).loadUserData();
  }
}
```

## TODOS

- [ ] Add more Examples
- [ ] reducing boilerplate in defining public and protected routes
- [ ] enhancing the auth notifier workflow

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
