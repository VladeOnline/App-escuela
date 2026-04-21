import '../../domain/entities/report_result_entity.dart';

/// Modelo para mapear ReportResult desde el JSON del backend
class ReportResultModel {
  final String id;
  final String estudianteId;
  final String evaluacionId;
  final String evaluacionTitulo;
  final int puntuacion;
  final DateTime fecha;
  final bool aprobado;
  final int intentos;

  ReportResultModel({
    required this.id,
    required this.estudianteId,
    required this.evaluacionId,
    required this.evaluacionTitulo,
    required this.puntuacion,
    required this.fecha,
    required this.aprobado,
    required this.intentos,
  });

  /// Crear instancia desde JSON del backend
  factory ReportResultModel.fromJson(Map<String, dynamic> json) {
    return ReportResultModel(
      id: json['_id'] ?? '',
      estudianteId: json['estudiante_id'] ?? '',
      evaluacionId: json['evaluacion_id'] ?? '',
      evaluacionTitulo: json['evaluacion_id']?['titulo'] ?? 'Sin título',
      puntuacion: (json['puntuacion'] as num?)?.toInt() ?? 0,
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      aprobado: json['aprobado'] ?? false,
      intentos: (json['intentos'] as num?)?.toInt() ?? 1,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    '_id': id,
    'estudiante_id': estudianteId,
    'evaluacion_id': evaluacionId,
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
    puntuacion: puntuacion,
    fecha: fecha,
    aprobado: aprobado,
    intentos: intentos,
  );
}
