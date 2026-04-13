import 'package:flutter/material.dart';
import '../../domain/entities/individual_report_entity.dart';
import '../../domain/entities/report_result_entity.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que muestra el rendimiento por evaluación con gráfico
class PerformanceChart extends StatelessWidget {
  final IndividualReportEntity report;

  const PerformanceChart({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final evaluacionesPorMateria = _agruparPorMateria();

    if (evaluacionesPorMateria.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rendimiento por Evaluación',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Gráfico simplificado
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _buildSimpleChart(context, evaluacionesPorMateria),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Leyenda
          _buildLegend(evaluacionesPorMateria),
        ],
      ),
    );
  }

  /// Construye un gráfico simplificado de barras
  Widget _buildSimpleChart(BuildContext context, Map<String, List<ReportResultEntity>> data) {
    final evaluaciones = data.keys.toList();
    final maxCalificacion = 100;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        evaluaciones.length,
        (index) {
          final evaluacion = evaluaciones[index];
          final calificacion = data[evaluacion]!.isNotEmpty
              ? data[evaluacion]!.first.puntuacion
              : 0;
          final barHeight = (calificacion / maxCalificacion) * 150;
          final color = _getCalificacionColor(calificacion);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$calificacion%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 30,
                height: barHeight,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.7),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 50),
                child: Text(
                  evaluacion,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Construye la leyenda con estadísticas
  Widget _buildLegend(Map<String, List<ReportResultEntity>> data) {
    final promedio = report.promedio;
    final totalEvaluaciones = data.length;
    final evaluacionesAprobadas = data.entries
        .where((e) => e.value.isNotEmpty && e.value.first.aprobado)
        .length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(label: 'Promedio', value: '$promedio%'),
          _LegendItem(label: 'Evaluaciones', value: '$totalEvaluaciones'),
          _LegendItem(
            label: 'Aprobadas',
            value: '$evaluacionesAprobadas',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  /// Agrupa los resultados por evaluación (última calificación)
  Map<String, List<ReportResultEntity>> _agruparPorMateria() {
    final mapa = <String, List<ReportResultEntity>>{};

    for (var resultado in report.resultados) {
      final evaluacion = resultado.evaluacionTitulo;
      if (!mapa.containsKey(evaluacion)) {
        mapa[evaluacion] = [];
      }
      mapa[evaluacion]!.add(resultado);
    }

    // Ordenar por fecha descendente
    for (var key in mapa.keys) {
      mapa[key]!.sort((a, b) => b.fecha.compareTo(a.fecha));
    }

    return mapa;
  }

  Color _getCalificacionColor(int calificacion) {
    if (calificacion >= 80) return Colors.green;
    if (calificacion >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// Widget para ítems de leyenda
class _LegendItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.value,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
