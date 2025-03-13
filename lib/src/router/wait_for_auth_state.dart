import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pod_router/src/auth/auth_status.dart';
import 'package:pod_router/src/utils/package_logger.dart';

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
