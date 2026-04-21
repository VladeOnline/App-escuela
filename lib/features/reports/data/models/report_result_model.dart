import '../../domain/entities/report_result_entity.dart';

/// Modelo para mapear ReportResult desde el JSON del backend
class ReportResultModel {
  final String id;
  final String estudianteId;
  final String evaluacionId;
  final String evaluacionTitulo;
  final String materia;
  final int puntuacion;
  final DateTime fecha;
  final bool aprobado;
  final int intentos;

  ReportResultModel({
    required this.id,
    required this.estudianteId,
    required this.evaluacionId,
    required this.evaluacionTitulo,
    required this.materia,
    required this.puntuacion,
    required this.fecha,
    required this.aprobado,
    required this.intentos,
  });

  /// Crear instancia desde JSON del backend
  factory ReportResultModel.fromJson(Map<String, dynamic> json) {
    final rawEvaluacion = json['evaluacion_id'];
    final nestedTitulo = rawEvaluacion is Map<String, dynamic>
        ? (rawEvaluacion['titulo']?.toString() ?? rawEvaluacion['nombre']?.toString())
        : null;

    return ReportResultModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      estudianteId: json['estudianteId']?.toString() ?? json['estudiante_id']?.toString() ?? '',
      evaluacionId: json['evaluacionId']?.toString() ?? json['evaluacion_id']?.toString() ?? '',
      evaluacionTitulo:
          json['evaluacionTitulo']?.toString() ?? nestedTitulo ?? 'Sin título',
      materia: json['materia']?.toString() ?? '',
      puntuacion: (json['puntuacion'] as num?)?.toInt() ?? 0,
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      aprobado: json['aprobado'] == true,
      intentos: (json['intentos'] as num?)?.toInt() ?? 1,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'estudianteId': estudianteId,
        'evaluacionId': evaluacionId,
        'evaluacionTitulo': evaluacionTitulo,
        'materia': materia,
        'puntuacion': puntuacion,
        'fecha': fecha.toIso8601String(),
        'aprobado': aprobado,
        'intentos': intentos,
      };

  /// Convertir a Entidad
  ReportResultEntity toEntity() => ReportResultEntity(
        id: id,
        estudianteId: estudianteId,
        evaluacionId: evaluacionId,
        evaluacionTitulo: evaluacionTitulo,
        materia: materia,
        puntuacion: puntuacion,
        fecha: fecha,
        aprobado: aprobado,
        intentos: intentos,
      );
}
