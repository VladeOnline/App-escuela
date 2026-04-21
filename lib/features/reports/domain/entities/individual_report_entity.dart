import 'report_result_entity.dart';

class ReportSubjectPerformanceEntity {
  final String nombre;
  final int lectura;
  final int escritura;

  const ReportSubjectPerformanceEntity({
    required this.nombre,
    required this.lectura,
    required this.escritura,
  });
}

class ReportProgressPointEntity {
  final String week;
  final int value;

  const ReportProgressPointEntity({
    required this.week,
    required this.value,
  });
}

/// Entidad que representa un reporte individual de un estudiante
class IndividualReportEntity {
  final String estudianteId;
  final String estudianteNombre;
  final int estudianteGrado;
  final int totalEvaluaciones;
  final int promedio;
  final int aprobadas;
  final int xpPoints;
  final int ranking;
  final String levelName;
  final List<String> insignias;
  final List<ReportSubjectPerformanceEntity> rendimientoPorMateria;
  final List<ReportProgressPointEntity> progresoSemanal;
  final List<ReportResultEntity> resultados;

  IndividualReportEntity({
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.totalEvaluaciones,
    required this.promedio,
    required this.aprobadas,
    required this.xpPoints,
    required this.ranking,
    required this.levelName,
    required this.insignias,
    required this.rendimientoPorMateria,
    required this.progresoSemanal,
    required this.resultados,
  });
}
