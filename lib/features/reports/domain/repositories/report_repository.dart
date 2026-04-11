import '../entities/individual_report_entity.dart';
import '../entities/grade_report_entity.dart';
import '../entities/progress_chart_entity.dart';
import '../entities/historial_entity.dart';

/// Contrato/Interfaz del repositorio de reportes
abstract class ReportRepository {
  /// Obtener reporte individual de un estudiante (RF-17)
  Future<IndividualReportEntity> getIndividualReport(String estudianteId);

  /// Obtener reporte por grado (RF-18)
  Future<GradeReportEntity> getGradeReport(int grado);

  /// Obtener datos de progreso para gráficas (RF-16)
  Future<ProgressChartEntity> getProgressChart(String estudianteId);

  /// Obtener historial de evaluaciones (RF-41)
  Future<HistorialEvaluacionesEntity> getHistorialEvaluaciones(String estudianteId);

  /// Reiniciar puntuaciones de estudiante (RF-44)
  Future<void> reiniciarPuntuaciones(
    String estudianteId,
    String tipoReinicio, {
    String? evaluacionId,
    String? materiaId,
  });
}
