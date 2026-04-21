import '../../domain/entities/progress_chart_entity.dart';

/// Modelo para mapear ProgressChart desde el JSON del backend
class ProgressChartModel {
  final String estudianteId;
  final String estudianteNombre;
  final int estudianteGrado;
  final List<String> labels;
  final List<int> data;

  ProgressChartModel({
    required this.estudianteId,
    required this.estudianteNombre,
    required this.estudianteGrado,
    required this.labels,
    required this.data,
  });

  /// Crear instancia desde JSON del backend
  factory ProgressChartModel.fromJson(Map<String, dynamic> json) {
    final estudianteData = json['estudiante'] ?? {};
    final graficaData = json['grafica'] ?? {};

    final labels = (graficaData['labels'] as List?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    
    final data = (graficaData['data'] as List?)
        ?.map((e) => (e as num).toInt())
        .toList() ?? [];

    return ProgressChartModel(
      estudianteId: estudianteData['id'] ?? '',
      estudianteNombre: estudianteData['nombre'] ?? 'Sin nombre',
      estudianteGrado: (estudianteData['grado'] as num?)?.toInt() ?? 0,
      labels: labels,
      data: data,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    'estudiante': {
      'id': estudianteId,
      'nombre': estudianteNombre,
      'grado': estudianteGrado,
    },
    'grafica': {
      'labels': labels,
      'data': data,
    },
  };

  /// Convertir a Entidad
  ProgressChartEntity toEntity() => ProgressChartEntity(
    estudianteId: estudianteId,
    estudianteNombre: estudianteNombre,
    estudianteGrado: estudianteGrado,
    labels: labels,
    data: data,
  );
}
