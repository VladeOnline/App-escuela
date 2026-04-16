import 'package:flutter/material.dart';
import '../../domain/entities/individual_report_entity.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que muestra la tabla de resultados de evaluaciones
class ResultsTable extends StatelessWidget {
  final IndividualReportEntity report;

  const ResultsTable({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (report.resultados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No hay evaluaciones registradas',
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
          DataColumn(label: Text('Fecha'), numeric: false),
          DataColumn(label: Text('Puntuación'), numeric: true),
          DataColumn(label: Text('Estado'), numeric: false),
          DataColumn(label: Text('Intentos'), numeric: true),
        ],
        rows: report.resultados.map((resultado) {
          return DataRow(
            cells: [
              DataCell(Text(resultado.evaluacionTitulo)),
              DataCell(
                Text(
                  '${resultado.fecha.day}/${resultado.fecha.month}/${resultado.fecha.year}',
                ),
              ),
              DataCell(
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: _getPuntuacionColor(resultado.puntuacion),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${resultado.puntuacion}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: resultado.aprobado ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    resultado.aprobado ? 'Aprobado' : 'No aprobado',
                    style: TextStyle(
                      color: resultado.aprobado ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: Text('${resultado.intentos}'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Determina el color basado en la puntuación
  Color _getPuntuacionColor(int puntuacion) {
    if (puntuacion >= 80) return Colors.green;
    if (puntuacion >= 60) return Colors.orange;
    return Colors.red;
  }
}
