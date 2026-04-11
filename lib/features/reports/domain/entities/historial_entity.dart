/// Elemento individual en el historial de evaluaciones
class HistorialItemEntity {
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

  HistorialItemEntity({
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
}

/// Entidad para historial de evaluaciones (RF-41)
class HistorialEvaluacionesEntity {
  final String estudianteId;
  final String estudianteNombre;
  final int estudianteGrado;
  final int totalEvaluaciones;
  final int evaluacionesAprobadas;
  final int promedioGeneral;
  final List<HistorialItemEntity> historial;

  HistorialEvaluacionesEntity({
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.totalEvaluaciones,
    required this.evaluacionesAprobadas,
    required this.promedioGeneral,
    required this.historial,
  });
}
