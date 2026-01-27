part of 'auth_bloc.dart';

class AuthStates extends Equatable {
  final bool isLoading;
  final AppUser? user;
  final String? error;

  const AuthStates({this.isLoading = false, this.user, this.error});

  AuthStates copyWith({bool? isLoading, AppUser? user, String? error}) {
    return AuthStates(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, error];
}
