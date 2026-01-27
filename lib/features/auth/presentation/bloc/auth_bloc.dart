import 'package:chat_app/features/auth/domain/entities/app_user.dart';
import 'package:chat_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:chat_app/features/auth/domain/usecases/login_user.dart';
import 'package:chat_app/features/auth/domain/usecases/register_user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthStates> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.getCurrentUser,
  }) : super(const AuthStates()) {
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<AuthCheckRequested>(_onCheckAuth);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
      LoginSubmitted event, Emitter<AuthStates> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final AppUser user = await loginUser(event.email, event.password);
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRegister(
      RegisterSubmitted event, Emitter<AuthStates> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    if (event.password != event.confirmPassword) {
      emit(state.copyWith(isLoading: false, error: "Passwords do not match"));
      return;
    }

    try {
      final AppUser user =
          await registerUser(event.email, event.password);
      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onCheckAuth(AuthCheckRequested event, Emitter<AuthStates> emit) {
    final user = getCurrentUser();
    emit(state.copyWith(user: user));
  }

  Future<void> _onLogout(
      LogoutRequested event, Emitter<AuthStates> emit) async {
    // You can add Supabase signOut usecase if required
    emit(const AuthStates());
  }
}
