# river_routes

A Flutter package that simplifies integration between Go Router and Riverpod state management with authentication handling. This package helps you manage routing based on authentication state and other app conditions, reducing boilerplate and providing a standardized approach.

[![Pub Version](https://img.shields.io/badge/pub-v0.1.0-blue)](https://pub.dev/packages/river_routes)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

## Features

- 🔐 **Authentication-aware routing** - Automatically redirect users based on auth state
- 🔄 **State-driven navigation** - Route changes respond to Riverpod state changes
- 🌊 **Simplified navigation flow** - Handle onboarding, authentication flow, and protected routes
- 📝 **Declarative route definition** - Define protected and public routes clearly
- 🪝 **Easy integration** - Works with your existing Go Router and Riverpod setup

## Installation

```yaml
dependencies:
  river_routes: ^0.1.0
```

Run:

```
flutter pub get
```

## Quick Start

```dart
import 'package:river_routes/river_routes.dart';
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
  
  @override
  void initializeListeners() {
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

// 4. Create the router provider
final routesProvider = routesManagerProvider<AppRoutesManager>(
  (ref) => AppRoutesManager(ref)
);

// 5. Set up the Go Router
final routerProvider = Provider<GoRouter>((ref) {
  final routesManager = ref.watch(routesProvider);
  
  return GoRouter(
    redirect: routesManager.onRedirect,
    refreshListenable: CombinedListen(routesManager.refreshables),
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

### Setting Up Go Router

Integrate with Go Router using the `CombinedListen` utility:

```dart
final goRouterProvider = Provider<GoRouter>((ref) {
  final routesManager = ref.watch(routesManagerProvider);
  
  return GoRouter(
    debugLogDiagnostics: true,
    redirect: routesManager.onRedirect,
    refreshListenable: CombinedListen(routesManager.refreshables),
    initialLocation: '/splash',
    routes: [
      // Your routes...
    ],
  );
});
```

## Complete Example

See the [example](https://github.com/yourusername/river_routes/tree/main/example) folder for a complete implementation.

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
