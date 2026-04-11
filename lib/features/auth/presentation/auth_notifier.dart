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
  final String? userId;
  final String? userName;
  final String? studentId;
  final int? studentGrade;
  final int studentPoints;
  final String? studentPhotoUrl;
  final AppFailure? failure;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.token,
    this.role,
    this.userId,
    this.userName,
    this.studentId,
    this.studentGrade,
    this.studentPoints = 0,
    this.studentPhotoUrl,
    this.failure,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isTeacher => role == AppConstants.roleTeacher;
  bool get isStudent => role == AppConstants.roleStudent;

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? role,
    String? userId,
    String? userName,
    String? studentId,
    int? studentGrade,
    int? studentPoints,
    String? studentPhotoUrl,
    AppFailure? failure,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      studentId: studentId ?? this.studentId,
      studentGrade: studentGrade ?? this.studentGrade,
      studentPoints: studentPoints ?? this.studentPoints,
      studentPhotoUrl: studentPhotoUrl ?? this.studentPhotoUrl,
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
      final usuario =
          (response['usuario'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final estudiante = (response['estudiante'] as Map?)?.cast<String, dynamic>();
      final rawGrade = estudiante == null ? null : estudiante['grado'];
      final rawPoints = estudiante == null ? null : estudiante['puntos_total'];

      setAuth(
        token: response['token']?.toString() ?? '',
        role: usuario['rol']?.toString() ?? role,
        userId: usuario['id']?.toString(),
        userName: usuario['nombre']?.toString(),
        studentId: estudiante == null ? null : estudiante['id']?.toString(),
        studentGrade: rawGrade is int ? rawGrade : int.tryParse('${rawGrade ?? ''}'),
        studentPoints: rawPoints is int
            ? rawPoints
            : int.tryParse('${rawPoints ?? ''}') ?? 0,
        studentPhotoUrl: estudiante == null ? null : estudiante['foto_url']?.toString(),
      );
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

  void setAuth({
    required String token,
    required String role,
    String? userId,
    String? userName,
    String? studentId,
    int? studentGrade,
    int studentPoints = 0,
    String? studentPhotoUrl,
  }) {
    _emit(AuthState(
      status: AuthStatus.authenticated,
      token: token,
      role: role,
      userId: userId,
      userName: userName,
      studentId: studentId,
      studentGrade: studentGrade,
      studentPoints: studentPoints,
      studentPhotoUrl: studentPhotoUrl,
    ));
  }

  void clearFailure() {
    _emit(_state.copyWith(status: AuthStatus.unauthenticated));
  }
}
