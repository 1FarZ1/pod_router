import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_status.dart';
import '../utils/package_logger.dart';

/// Creates a provider that handles initial data loading for the router
FutureProvider<bool> createInitialDataProvider(Ref ref,
    StateNotifierProvider authProvider, List<ProviderListenable> dataProviders,
    {bool checkOnBoarding = false, ProviderListenable? onBoardingProvider}) {
  return FutureProvider<bool>((ref) async {
    try {
      // Wait for auth state to be determined
      await waitForAuthState(ref, authProvider);

      // Load all data providers
      final futures = dataProviders.map((provider) {
        try {
          final value = ref.read(provider);
          if (value is Future) {
            return value;
          }
          return Future.value(null);
        } catch (e) {
          PackageLogger.error('Error loading provider $provider: $e',
              featureType: FeaturesType.routing);
          return Future.value(null);
        }
      }).toList();

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      // Check onboarding if needed
      if (checkOnBoarding && onBoardingProvider != null) {
        final isOnboardingComplete = ref.read(onBoardingProvider);
        if (!isOnboardingComplete) {
          PackageLogger.debug('Onboarding not complete',
              featureType: FeaturesType.routing);
          return false;
        }
      }

      return true;
    } catch (e) {
      PackageLogger.error('Error loading initial data: $e',
          featureType: FeaturesType.routing);
      return false;
    }
  });
}

/// Helper function to wait for auth state to be determined
Future<AuthStatus> waitForAuthState(
    Ref ref, StateNotifierProvider authProvider) async {
  final completer = Completer<AuthStatus>();

  ref.listen(authProvider.select((value) => value.status), (previous, next) {
    if (completer.isCompleted) return;
    if (next != AuthStatus.unknown && !completer.isCompleted) {
      PackageLogger.debug('Auth state changed to $next',
          featureType: FeaturesType.auth);
      completer.complete(next);
    }
  }, fireImmediately: true);

  return completer.future;
}
