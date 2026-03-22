import 'package:flutter/foundation.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../services/auth_service.dart';

/// Estado de autenticación.
enum AuthStatus { unauthenticated, loading, authenticated, failure }

@immutable
class AuthState {
  final AuthStatus status;
  final String? token;   // tokenKey — listo para JWT del Back
  final String? role;    // roleKey — 'docente' | 'estudiante'
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

/// Notifier de autenticación.
/// Absorbe y mejora el AuthProvider original del equipo.
/// El Back reemplaza _mockLogin() con la llamada real a la API.
class AuthNotifier extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;

  void _emit(AuthState next) {
    _state = next;
    notifyListeners();
  }

  /// RF-05: Login con rol.
  /// Cuando el Back esté listo, reemplaza el mock por:
  ///   final response = await AuthService.login(password, role);
  ///   setAuth(response.token, response.role);
Future<bool> login({
  required String password,
  required String role,
}) async {
  _emit(_state.copyWith(status: AuthStatus.loading));

  try {
    final response = await AuthService.login('docente', password, role);
    setAuth(response['token'], response['usuario']['rol']);
    return true;
  } catch (e) {
    // Si el backend no está disponible, usa mock
    final isValid = password == AppConstants.mockTeacherPassword;
    if (isValid) {
      _emit(_state.copyWith(
        status: AuthStatus.authenticated,
        token: 'mock_token',
        role: role,
      ));
      return true;
    }
    _emit(_state.copyWith(
      status: AuthStatus.failure,
      failure: const AuthFailure('Credenciales incorrectas.'),
    ));
    return false;
  }
}

  /// RF-06: Cierre de sesión seguro.
  void logout() {
    _emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Expone setAuth para cuando el Back conecte auth real.
  /// Mismo nombre que el método original del equipo.
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

  // ── Mock de validación local ──────────────────────────────────────────────
  bool _mockValidate({required String password, required String role}) {
    if (role == AppConstants.roleTeacher) {
      return password == AppConstants.mockTeacherPassword;
    }
    // Estudiantes: el Back validará por nombre/grado.
    // Por ahora cualquier contraseña no vacía funciona.
    return password.isNotEmpty;
  }
}
