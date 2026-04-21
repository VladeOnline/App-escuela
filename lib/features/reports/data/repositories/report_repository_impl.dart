import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/individual_report_entity.dart';
import '../../domain/entities/grade_report_entity.dart';
import '../../domain/entities/progress_chart_entity.dart';
import '../../domain/entities/historial_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../models/individual_report_model.dart';
import '../models/grade_report_model.dart';
import '../models/progress_chart_model.dart';
import '../models/historial_model.dart';

/// Implementación real del repositorio que se conecta con la API
class ReportRepositoryImpl implements ReportRepository {
  final http.Client httpClient;

  ReportRepositoryImpl({required this.httpClient});

  /// Obtener reporte individual de un estudiante desde la API (RF-17)
  @override
  Future<IndividualReportEntity> getIndividualReport(String estudianteId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('${AppConstants.apiBaseUrl}/reportes/individual/$estudianteId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final model = IndividualReportModel.fromJson(json);
        return model.toEntity();
      } else if (response.statusCode == 404) {
        throw Exception('Estudiante no encontrado');
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener reporte por grado desde la API (RF-18)
  @override
  Future<GradeReportEntity> getGradeReport(int grado) async {
    try {
      final response = await httpClient.get(
        Uri.parse('${AppConstants.apiBaseUrl}/reportes/grado/$grado'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final model = GradeReportModel.fromJson(json);
        return model.toEntity();
      } else if (response.statusCode == 404) {
        throw Exception('No hay estudiantes para ese grado');
      } else {
        throw Exception('Error al obtener reporte: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener datos de progreso para gráficas desde la API (RF-16)
  @override
  Future<ProgressChartEntity> getProgressChart(String estudianteId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('${AppConstants.apiBaseUrl}/reportes/progreso/$estudianteId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final model = ProgressChartModel.fromJson(json);
        return model.toEntity();
      } else if (response.statusCode == 404) {
        throw Exception('Estudiante no encontrado');
      } else {
        throw Exception('Error al obtener datos de progreso: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener historial de evaluaciones desde la API (RF-41)
  @override
  Future<HistorialEvaluacionesEntity> getHistorialEvaluaciones(String estudianteId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('${AppConstants.apiBaseUrl}/reportes/historial/$estudianteId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final model = HistorialEvaluacionesModel.fromJson(json);
        return model.toEntity();
      } else if (response.statusCode == 404) {
        throw Exception('Estudiante no encontrado');
      } else {
        throw Exception('Error al obtener historial: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reiniciar puntuaciones de un estudiante (RF-44)
  @override
  Future<void> reiniciarPuntuaciones(
    String estudianteId,
    String tipoReinicio, {
    String? evaluacionId,
    String? materiaId,
  }) async {
    try {
      final body = {
        'tipo_reinicio': tipoReinicio,
        if (evaluacionId != null && tipoReinicio == 'por_evaluacion')
          'evaluacion_id': evaluacionId,
        if (materiaId != null && tipoReinicio == 'por_materia')
          'materia_id': materiaId,
      };

      final response = await httpClient.post(
        Uri.parse('${AppConstants.apiBaseUrl}/reportes/admin/reiniciar/$estudianteId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Error al reiniciar puntuaciones: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
