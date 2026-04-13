import 'package:flutter/material.dart';
import '../../domain/entities/individual_report_entity.dart';
import '../../domain/entities/report_result_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/pdf_reporting_service.dart';

/// Widget que muestra la tabla de últimas evaluaciones por materia
class EvaluationsTable extends StatelessWidget {
  final IndividualReportEntity report;

  const EvaluationsTable({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Agrupar resultados por evaluación (materia)
    final evaluacionesPorMateria = _agruparPorMateria();

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
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Últimas Evaluaciones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () => PdfReportingService.generateIndividualReportPdf(report),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Descargar PDF'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Grid de evaluaciones
          if (evaluacionesPorMateria.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              alignment: Alignment.center,
              child: Text(
                'No hay evaluaciones registradas',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.2,
              ),
              itemCount: evaluacionesPorMateria.length,
              itemBuilder: (context, index) {
                final entry = evaluacionesPorMateria.entries.toList()[index];
                final evaluacion = entry.key;
                final resultados = entry.value;
                final ultimaCalificacion = resultados.isNotEmpty
                    ? resultados.first.puntuacion
                    : 0;

                return _EvaluacionCard(
                  evaluacion: evaluacion,
                  calificacion: ultimaCalificacion,
                  intentos: resultados.length,
                  aprobado: resultados.isNotEmpty
                      ? resultados.first.aprobado
                      : false,
                );
              },
            ),
          const SizedBox(height: AppSpacing.lg),

          // Promedio general
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calificación general',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${report.promedio}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Agrupa los resultados por título de evaluación
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
}

/// Tarjeta individual de evaluación
class _EvaluacionCard extends StatelessWidget {
  final String evaluacion;
  final int calificacion;
  final int intentos;
  final bool aprobado;

  const _EvaluacionCard({
    required this.evaluacion,
    required this.calificacion,
    required this.intentos,
    required this.aprobado,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCalificacionColor(calificacion);
    final estatus = _getEstatus(calificacion, aprobado);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nombre de evaluación
          Text(
            evaluacion,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Información
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nota:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$calificacion%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Intentos:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '$intentos',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Estatus badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              estatus,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCalificacionColor(int calificacion) {
    if (calificacion >= 80) return Colors.green;
    if (calificacion >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getEstatus(int calificacion, bool aprobado) {
    if (aprobado) {
      if (calificacion >= 80) return '✓ Excelente';
      return '✓ Aprobado';
    }
    return '✗ No aprobado';
  }
}
