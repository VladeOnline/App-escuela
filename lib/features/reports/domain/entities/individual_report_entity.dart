import 'report_result_entity.dart';

/// Entidad que representa un reporte individual de un estudiante
class IndividualReportEntity {
  final String estudianteId;
  final String estudianteNombre;
  final int estudianteGrado;
  final int totalEvaluaciones;
  final int promedio;
  final List<ReportResultEntity> resultados;

  IndividualReportEntity({
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.totalEvaluaciones,
    required this.promedio,
    required this.resultados,
  });
}
