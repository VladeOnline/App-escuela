import '../../domain/entities/grade_report_entity.dart';
import 'report_result_model.dart';

/// Modelo para mapear GradeReport desde el JSON del backend
class GradeReportModel {
  final int grado;
  final int totalEstudiantes;
  final int totalResultados;
  final int promedioGrado;
  final List<ReportResultModel> resultados;

  GradeReportModel({
    required this.grado,
    required this.totalEstudiantes,
    required this.totalResultados,
    required this.promedioGrado,
    required this.resultados,
  });

  /// Crear instancia desde JSON del backend
  factory GradeReportModel.fromJson(Map<String, dynamic> json) {
    final resultadosList = json['resultados'] as List? ?? [];

    return GradeReportModel(
      grado: (json['grado'] as num?)?.toInt() ?? 0,
      totalEstudiantes: (json['totalEstudiantes'] as num?)?.toInt() ?? 0,
      totalResultados: (json['totalResultados'] as num?)?.toInt() ?? 0,
      promedioGrado: (json['promedioGrado'] as num?)?.toInt() ?? 0,
      resultados: resultadosList
          .map((r) => ReportResultModel.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    'grado': grado,
    'totalEstudiantes': totalEstudiantes,
    'totalResultados': totalResultados,
    'promedioGrado': promedioGrado,
    'resultados': resultados.map((r) => r.toJson()).toList(),
  };

  /// Convertir a Entidad
  GradeReportEntity toEntity() => GradeReportEntity(
    grado: grado,
    totalEstudiantes: totalEstudiantes,
    totalResultados: totalResultados,
    promedioGrado: promedioGrado,
    resultados: resultados.map((r) => r.toEntity()).toList(),
  );
}
