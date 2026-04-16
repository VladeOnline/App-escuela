import 'package:flutter/material.dart';
import '../../domain/entities/historial_entity.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que muestra el historial de evaluaciones
class HistorialTable extends StatelessWidget {
  final HistorialEvaluacionesEntity historial;

  const HistorialTable({
    Key? key,
    required this.historial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (historial.historial.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Sin evaluaciones registradas',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Evaluación')),
          DataColumn(label: Text('Materia'), numeric: false),
          DataColumn(label: Text('Fecha'), numeric: false),
          DataColumn(label: Text('Puntuación'), numeric: true),
          DataColumn(label: Text('Preguntas'), numeric: true),
          DataColumn(label: Text('Intento'), numeric: true),
          DataColumn(label: Text('Estado'), numeric: false),
        ],
        rows: historial.historial.map((item) {
          return DataRow(
            cells: [
              DataCell(Text(item.evaluacionNombre)),
              DataCell(Text(item.materia)),
              DataCell(
                Text('${item.fecha.day}/${item.fecha.month}/${item.fecha.year}'),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: _getPuntuacionColor(item.puntuacion),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${item.puntuacion}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text(
                    '${item.preguntasCorrectas}/${item.totalPreguntas}',
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text('${item.intento}'),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: item.aprobado ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.aprobado ? 'Aprobado' : 'No aprobado',
                    style: TextStyle(
                      color: item.aprobado ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getPuntuacionColor(int puntuacion) {
    if (puntuacion >= 80) return Colors.green;
    if (puntuacion >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// Widget que muestra las estadísticas del historial
class HistorialStats extends StatelessWidget {
  final HistorialEvaluacionesEntity historial;

  const HistorialStats({
    Key? key,
    required this.historial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total Evaluaciones',
            value: '${historial.totalEvaluaciones}',
            icon: Icons.assessment,
          ),
          _StatItem(
            label: 'Aprobadas',
            value: '${historial.evaluacionesAprobadas}',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          _StatItem(
            label: 'Promedio',
            value: '${historial.promedioGeneral}%',
            icon: Icons.trending_up,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
