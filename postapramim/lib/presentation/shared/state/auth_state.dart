import 'package:equatable/equatable.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/user.dart';

/// Estados mutuamente exclusivos via sealed class — impossível
/// representar `isLoading && hasError` simultaneamente.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
