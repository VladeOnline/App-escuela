import '../../domain/entities/individual_report_entity.dart';
import 'report_result_model.dart';

/// Modelo para mapear IndividualReport desde el JSON del backend
class IndividualReportModel {
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
  final List<ReportResultModel> resultados;

  IndividualReportModel({
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

  /// Crear instancia desde JSON del backend
  factory IndividualReportModel.fromJson(Map<String, dynamic> json) {
    final estudianteData = (json['estudiante'] as Map?)?.cast<String, dynamic>() ?? {};
    final resumenData = (json['resumen'] as Map?)?.cast<String, dynamic>() ?? {};
    final resultadosList = (json['resultados'] as List?) ?? const [];
    final rendimientoList = (json['rendimientoPorMateria'] as List?) ?? const [];
    final progresoList = (json['progresoSemanal'] as List?) ?? const [];
    final gamificacion = (json['gamificacion'] as Map?)?.cast<String, dynamic>() ?? {};

    return IndividualReportModel(
      estudianteId: estudianteData['id']?.toString() ?? '',
      estudianteNombre: estudianteData['nombre']?.toString() ?? 'Sin nombre',
      estudianteGrado: (estudianteData['grado'] as num?)?.toInt() ?? 0,
      totalEvaluaciones: (resumenData['totalEvaluaciones'] as num?)?.toInt() ?? 0,
      promedio: (resumenData['promedio'] as num?)?.toInt() ?? 0,
      aprobadas: (resumenData['aprobadas'] as num?)?.toInt() ?? 0,
      xpPoints: (gamificacion['xpPoints'] as num?)?.toInt() ?? 0,
      ranking: (gamificacion['ranking'] as num?)?.toInt() ?? 0,
      levelName: gamificacion['levelName']?.toString() ?? 'Nivel 1',
      insignias: ((gamificacion['insignias'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      rendimientoPorMateria: rendimientoList
          .whereType<Map>()
          .map((raw) {
            final m = raw.cast<String, dynamic>();
            return ReportSubjectPerformanceEntity(
              nombre: m['nombre']?.toString() ?? 'General',
              lectura: (m['lectura'] as num?)?.toInt() ?? 0,
              escritura: (m['escritura'] as num?)?.toInt() ?? 0,
            );
          })
          .toList(),
      progresoSemanal: progresoList
          .whereType<Map>()
          .map((raw) {
            final p = raw.cast<String, dynamic>();
            return ReportProgressPointEntity(
              week: p['week']?.toString() ?? '',
              value: (p['value'] as num?)?.toInt() ?? 0,
            );
          })
          .toList(),
      resultados: resultadosList
          .whereType<Map>()
          .map((r) => ReportResultModel.fromJson(r.cast<String, dynamic>()))
          .toList(),
    );
  }

  /// Convertir a Entidad
  IndividualReportEntity toEntity() => IndividualReportEntity(
        estudianteId: estudianteId,
        estudianteNombre: estudianteNombre,
        estudianteGrado: estudianteGrado,
        totalEvaluaciones: totalEvaluaciones,
        promedio: promedio,
        aprobadas: aprobadas,
        xpPoints: xpPoints,
        ranking: ranking,
        levelName: levelName,
        insignias: insignias,
        rendimientoPorMateria: rendimientoPorMateria,
        progresoSemanal: progresoSemanal,
        resultados: resultados.map((r) => r.toEntity()).toList(),
      );
}
