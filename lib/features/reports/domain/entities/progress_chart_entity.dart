/// Entidad para datos de gráficas de progreso (RF-16)
class ProgressChartEntity {
  final String estudianteId;
  final String estudianteNombre;
  final int estudianteGrado;
  final List<String> labels;
  final List<int> data;

  ProgressChartEntity({
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.labels,
    required this.data,
  });
}
