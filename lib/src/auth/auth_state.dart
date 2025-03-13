import 'package:equatable/equatable.dart';
import 'package:pod_router/src/auth/auth_status.dart';

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
