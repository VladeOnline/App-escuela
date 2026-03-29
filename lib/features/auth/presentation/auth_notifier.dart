import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../services/auth_service.dart';

enum AuthStatus { unauthenticated, loading, authenticated, failure }

@immutable
class AuthState {
  final AuthStatus status;
  final String? token;
  final String? role;
  final AppFailure? failure;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.token,
    this.role,
    this.failure,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isTeacher => role == AppConstants.roleTeacher;
  bool get isStudent => role == AppConstants.roleStudent;

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? role,
    AppFailure? failure,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      role: role ?? this.role,
      failure: failure,
    );
  }
}

class AuthNotifier extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;

  void _emit(AuthState next) {
    _state = next;
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
    required String role,
  }) async {
    _emit(_state.copyWith(status: AuthStatus.loading));

    try {
      final response = await AuthService.login(username.trim(), password, role);
      setAuth(response['token'], response['usuario']['rol']);
      return true;
    } on AuthFailure catch (failure) {
      _emit(_state.copyWith(
        status: AuthStatus.failure,
        failure: failure,
      ));
      return false;
    } catch (_) {
      _emit(_state.copyWith(
        status: AuthStatus.failure,
        failure: const AuthFailure('No se pudo conectar con el servidor.'),
      ));
      return false;
    }
  }

  void logout() {
    _emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void setAuth(String token, String role) {
    _emit(_state.copyWith(
      status: AuthStatus.authenticated,
      token: token,
      role: role,
    ));
  }

  void clearFailure() {
    _emit(_state.copyWith(status: AuthStatus.unauthenticated));
  }
}
