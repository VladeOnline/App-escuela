import 'report_result_entity.dart';

/// Entidad para el reporte por grado (RF-18)
class GradeReportEntity {
  final int grado;
  final int totalEstudiantes;
  final int totalResultados;
  final int promedioGrado;
  final List<ReportResultEntity> resultados;

  GradeReportEntity({
    required this.grado,
    required this.totalEstudiantes,
    required this.totalResultados,
    required this.promedioGrado,
    required this.resultados,
  });
}
