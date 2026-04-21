import '../../domain/entities/individual_report_entity.dart';
import 'report_result_model.dart';

/// Modelo para mapear IndividualReport desde el JSON del backend
class IndividualReportModel {
  final String estudianteId;
  final String estudianteNombre;
  final int estudianteGrado;
  final int totalEvaluaciones;
  final int promedio;
  final List<ReportResultModel> resultados;

  IndividualReportModel({
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.totalEvaluaciones,
    required this.promedio,
    required this.resultados,
  });

  /// Crear instancia desde JSON del backend
  factory IndividualReportModel.fromJson(Map<String, dynamic> json) {
    final estudianteData = json['estudiante'] ?? {};
    final resumenData = json['resumen'] ?? {};
    final resultadosList = json['resultados'] as List? ?? [];

    return IndividualReportModel(
      estudianteId: estudianteData['id'] ?? '',
      estudianteNombre: estudianteData['nombre'] ?? 'Sin nombre',
      estudianteGrado: (estudianteData['grado'] as num?)?.toInt() ?? 0,
      totalEvaluaciones: (resumenData['totalEvaluaciones'] as num?)?.toInt() ?? 0,
      promedio: (resumenData['promedio'] as num?)?.toInt() ?? 0,
      resultados: resultadosList
          .map((r) => ReportResultModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    'estudiante': {
      'id': estudianteId,
      'nombre': estudianteNombre,
      'grado': estudianteGrado,
    },
    'resumen': {
      'totalEvaluaciones': totalEvaluaciones,
      'promedio': promedio,
    },
    'resultados': resultados.map((r) => r.toJson()).toList(),
  };

  /// Convertir a Entidad
  IndividualReportEntity toEntity() => IndividualReportEntity(
    estudianteId: estudianteId,
    estudianteNombre: estudianteNombre,
    estudianteGrado: estudianteGrado,
    totalEvaluaciones: totalEvaluaciones,
    promedio: promedio,
    resultados: resultados.map((r) => r.toEntity()).toList(),
  );
}
