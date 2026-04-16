import 'package:flutter/material.dart';
import '../../domain/entities/progress_chart_entity.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que muestra un gráfico de barras simple para el progreso
class ProgressChart extends StatelessWidget {
  final ProgressChartEntity chart;

  const ProgressChart({
    Key? key,
    required this.chart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chart.data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No hay datos para mostrar',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final maxScore = chart.data.isNotEmpty ? chart.data.reduce((a, b) => a > b ? a : b) : 100;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: chart.labels.length * 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(chart.data.length, (index) {
                  final score = chart.data[index];
                  final height = (score / (maxScore > 0 ? maxScore : 100)) * 250;
                  final color = score >= 80
                      ? Colors.green
                      : score >= 60
                          ? Colors.orange
                          : Colors.red;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        child: Center(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              '$score%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: 50,
                        child: Text(
                          chart.labels[index],
                          style: const TextStyle(fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Leyenda
            Row(
              children: [
                _LegendItem(color: Colors.green, label: 'Excelente (80%+)'),
                const SizedBox(width: AppSpacing.lg),
                _LegendItem(color: Colors.orange, label: 'Bueno (60-79%)'),
                const SizedBox(width: AppSpacing.lg),
                _LegendItem(color: Colors.red, label: 'Bajo (<60%)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
