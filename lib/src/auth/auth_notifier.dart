import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'auth_state.dart';
import '../utils/package_logger.dart';
import 'auth_status.dart';

/// Abstract auth notifier that can be extended for different authentication systems
abstract class BaseAuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  BaseAuthNotifier(this.ref) : super(AuthState.empty()) {
    initialize();
  }

  /// Initialize auth state and listeners
  void initialize();

  /// Set auth state to authenticated
  void setAuthenticated() {
    if (state.status == AuthStatus.authenticated) return;
    state = state.copyWith(status: AuthStatus.authenticated, isLoading: false);
    PackageLogger.info('Auth state: authenticated');
  }

  /// Set auth state to unauthenticated
  void setUnauthenticated() {
    if (state.status == AuthStatus.unauthenticated) return;
    state =
        state.copyWith(status: AuthStatus.unauthenticated, isLoading: false);
    PackageLogger.info('Auth state: unauthenticated');
  }

  /// Set loading state
  void setLoading() {
    state = state.copyWith(isLoading: true);
  }
}

/// Provider function to create auth notifier provider
StateNotifierProvider<T, AuthState>
    createAuthNotifierProvider<T extends BaseAuthNotifier>(
        T Function(Ref) create) {
  return StateNotifierProvider<T, AuthState>((ref) => create(ref));
}

/// Base auth state class that can be extended
class AuthState extends Equatable {
  final AuthStatus status;
  final bool isLoading;

  const AuthState({
    required this.status,
    required this.isLoading,
  });

  factory AuthState.empty() {
    return const AuthState(
      status: AuthStatus.unknown,
      isLoading: true,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [status, isLoading];
}
