import '../../domain/entities/historial_entity.dart';

/// Modelo para un item del historial
class HistorialItemModel {
  final String resultadoId;
  final String evaluacionId;
  final String evaluacionNombre;
  final String materia;
  final int puntuacion;
  final int preguntasCorrectas;
  final int totalPreguntas;
  final int intento;
  final DateTime fecha;
  final bool aprobado;

  HistorialItemModel({
    required this.resultadoId,
    required this.evaluacionId,
    required this.evaluacionNombre,
    required this.materia,
    required this.puntuacion,
    required this.preguntasCorrectas,
    required this.totalPreguntas,
    required this.intento,
    required this.fecha,
    required this.aprobado,
  });

  /// Crear instancia desde JSON del backend
  factory HistorialItemModel.fromJson(Map<String, dynamic> json) {
    return HistorialItemModel(
      resultadoId: json['resultado_id'] ?? '',
      evaluacionId: json['evaluacion_id'] ?? '',
      evaluacionNombre: json['evaluacion_nombre'] ?? 'Sin nombre',
      materia: json['materia'] ?? 'No especificada',
      puntuacion: (json['puntuacion'] as num?)?.toInt() ?? 0,
      preguntasCorrectas: (json['preguntas_correctas'] as num?)?.toInt() ?? 0,
      totalPreguntas: (json['total_preguntas'] as num?)?.toInt() ?? 0,
      intento: (json['intento'] as num?)?.toInt() ?? 1,
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      aprobado: json['aprobado'] ?? false,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    'resultado_id': resultadoId,
    'evaluacion_id': evaluacionId,
    'evaluacion_nombre': evaluacionNombre,
    'materia': materia,
    'puntuacion': puntuacion,
    'preguntas_correctas': preguntasCorrectas,
    'total_preguntas': totalPreguntas,
    'intento': intento,
    'fecha': fecha.toIso8601String(),
    'aprobado': aprobado,
  };

  /// Convertir a Entidad
  HistorialItemEntity toEntity() => HistorialItemEntity(
    resultadoId: resultadoId,
    evaluacionId: evaluacionId,
    evaluacionNombre: evaluacionNombre,
    materia: materia,
    puntuacion: puntuacion,
    preguntasCorrectas: preguntasCorrectas,
    totalPreguntas: totalPreguntas,
    intento: intento,
    fecha: fecha,
    aprobado: aprobado,
  );
}

/// Modelo para mapear HistorialEvaluaciones desde el JSON del backend
class HistorialEvaluacionesModel {
  final String estudianteId;
  final String estudianteNombre;
  final int estudianteGrado;
  final int totalEvaluaciones;
  final int evaluacionesAprobadas;
  final int promedioGeneral;
  final List<HistorialItemModel> historial;

  HistorialEvaluacionesModel({
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.totalEvaluaciones,
    required this.evaluacionesAprobadas,
    required this.promedioGeneral,
    required this.historial,
  });

  /// Crear instancia desde JSON del backend
  factory HistorialEvaluacionesModel.fromJson(Map<String, dynamic> json) {
    final estudianteData = json['estudiante'] ?? {};
    final estadisticasData = json['estadisticas'] ?? {};
    final historialList = json['historial'] as List? ?? [];

    return HistorialEvaluacionesModel(
      estudianteId: estudianteData['id'] ?? '',
      estudianteNombre: estudianteData['nombre'] ?? 'Sin nombre',
      estudianteGrado: (estudianteData['grado'] as num?)?.toInt() ?? 0,
      totalEvaluaciones: (estadisticasData['total_evaluaciones'] as num?)?.toInt() ?? 0,
      evaluacionesAprobadas: (estadisticasData['evaluaciones_aprobadas'] as num?)?.toInt() ?? 0,
      promedioGeneral: (estadisticasData['promedio_general'] as num?)?.toInt() ?? 0,
      historial: historialList
          .map((h) => HistorialItemModel.fromJson(h as Map<String, dynamic>))
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
    'estadisticas': {
      'total_evaluaciones': totalEvaluaciones,
      'evaluaciones_aprobadas': evaluacionesAprobadas,
      'promedio_general': promedioGeneral,
    },
    'historial': historial.map((h) => h.toJson()).toList(),
  };

  /// Convertir a Entidad
  HistorialEvaluacionesEntity toEntity() => HistorialEvaluacionesEntity(
    estudianteId: estudianteId,
    estudianteNombre: estudianteNombre,
    estudianteGrado: estudianteGrado,
    totalEvaluaciones: totalEvaluaciones,
    evaluacionesAprobadas: evaluacionesAprobadas,
    promedioGeneral: promedioGeneral,
    historial: historial.map((h) => h.toEntity()).toList(),
  );
}
