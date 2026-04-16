import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
class ApiStudentRepository implements StudentRepository {
  final String token;
  ApiStudentRepository({required this.token});
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
  ServerFailure _serverFailureFromResponse(
    http.Response response,
    String fallbackMessage,
  ) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return ServerFailure(message);
        }
      }
    } catch (_) {
      // Si no hay JSON usable, devolvemos el mensaje por defecto.
    }
    return ServerFailure(fallbackMessage);
  }
  StudentEntity _studentFromJson(Map<String, dynamic> json) {
    final rawConditions = json['conditions'] ?? json['condiciones'];
    return StudentEntity(
      id: json['_id'],
      fullName: json['nombre'],
      grade: json['grado'],
      age: json['edad'],
      conditions: rawConditions is List
          ? rawConditions.map((e) => e.toString()).toList()
          : const [],
      createdAt: DateTime.parse(json['creado_en']),
      photoUrl: json['foto_url']?.toString(),
    );
  }
  @override
  Future<({List<StudentEntity> students, AppFailure? failure})> getAll() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/estudiantes'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final students = data
            .cast<Map<String, dynamic>>()
            .map(_studentFromJson)
            .toList();
        return (students: students, failure: null);
      }
      return (
        students: <StudentEntity>[],
        failure: _serverFailureFromResponse(
          response,
          'Error al cargar estudiantes',
        ),
      );
    } catch (_) {
      return (
        students: <StudentEntity>[],
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }
  @override
  Future<({List<StudentEntity> students, AppFailure? failure})> search({
    String? name,
    int? grade,
  }) async {
    try {
      final queryParameters = <String, String>{};
      if (name != null && name.trim().isNotEmpty) {
        queryParameters['nombre'] = name.trim();
      }
      if (grade != null) {
        queryParameters['grado'] = grade.toString();
      }
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/estudiantes')
          .replace(queryParameters: queryParameters);
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final students = data
            .cast<Map<String, dynamic>>()
            .map(_studentFromJson)
            .toList();
        return (students: students, failure: null);
      }
      return (
        students: <StudentEntity>[],
        failure: _serverFailureFromResponse(response, 'Error en la búsqueda'),
      );
    } catch (_) {
      return (
        students: <StudentEntity>[],
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }
  @override
  Future<
      ({
        StudentEntity? student,
        String? generatedUsername,
        String? generatedPassword,
        AppFailure? failure
      })> create({
    required String fullName,
    required int grade,
    required int age,
    List<String> conditions = const [],
    String? photoDataUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'nombre': fullName,
        'grado': grade,
        'edad': age,
        'conditions': conditions,
      };
      if (photoDataUrl != null && photoDataUrl.trim().isNotEmpty) {
        payload['foto_perfil_url'] = photoDataUrl;
      }

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/estudiantes'),
        headers: _headers,
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final student = _studentFromJson(
          (data['estudiante'] as Map).cast<String, dynamic>(),
        );
        final credentials =
            (data['credenciales'] as Map?)?.cast<String, dynamic>();
        return (
          student: student,
          generatedUsername: credentials?['username']?.toString(),
          generatedPassword: credentials?['password']?.toString(),
          failure: null,
        );
      }
      return (
        student: null,
        generatedUsername: null,
        generatedPassword: null,
        failure: _serverFailureFromResponse(response, 'Error al crear estudiante'),
      );
    } catch (_) {
      return (
        student: null,
        generatedUsername: null,
        generatedPassword: null,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }
  @override
  Future<
      ({
        StudentEntity? student,
        String? generatedUsername,
        String? generatedPassword,
        AppFailure? failure
      })> update({
    required String id,
    required String fullName,
    required int grade,
    required int age,
    List<String> conditions = const [],
    String? photoDataUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'nombre': fullName,
        'grado': grade,
        'edad': age,
        'conditions': conditions,
      };
      if (photoDataUrl != null && photoDataUrl.trim().isNotEmpty) {
        payload['foto_perfil_url'] = photoDataUrl;
      }

      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/estudiantes/$id'),
        headers: _headers,
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final studentJson = (data['estudiante'] as Map?)?.cast<String, dynamic>() ?? data;
        final credentials =
            (data['credenciales'] as Map?)?.cast<String, dynamic>();
        return (
          student: _studentFromJson(studentJson),
          generatedUsername: credentials?['username']?.toString(),
          generatedPassword: credentials?['password']?.toString(),
          failure: null,
        );
      }
      return (
        student: null,
        generatedUsername: null,
        generatedPassword: null,
        failure: _serverFailureFromResponse(response, 'Error al editar estudiante'),
      );
    } catch (_) {
      return (
        student: null,
        generatedUsername: null,
        generatedPassword: null,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }
  @override
  Future<({bool success, AppFailure? failure})> delete(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/estudiantes/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return (success: true, failure: null);
      }
      return (
        success: false,
        failure:
            _serverFailureFromResponse(response, 'Error al eliminar estudiante'),
      );
    } catch (_) {
      return (
        success: false,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }
  @override
  Future<({bool success, AppFailure? failure})> deactivate(String id) async {
    return delete(id);
  }
}



