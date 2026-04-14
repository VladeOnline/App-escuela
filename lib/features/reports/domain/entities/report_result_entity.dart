/// Entidad que representa un resultado individual de evaluación
class ReportResultEntity {
  final String id;
  final String estudianteId;
  final String evaluacionId;
  final String evaluacionTitulo;
  final int puntuacion;
  final DateTime fecha;
  final bool aprobado;
  final int intentos;

  ReportResultEntity({
    required this.id,
    required this.estudianteId,
    required this.evaluacionId,
    required this.evaluacionTitulo,
    required this.puntuacion,
    required this.fecha,
    required this.aprobado,
    required this.intentos,
  });
}
