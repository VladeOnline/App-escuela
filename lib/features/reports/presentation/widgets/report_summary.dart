import 'package:flutter/material.dart';
import '../../domain/entities/individual_report_entity.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que muestra el resumen estadístico del reporte individual
class ReportSummary extends StatelessWidget {
  final IndividualReportEntity report;

  const ReportSummary({
    Key? key,
    required this.report,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${report.estudianteNombre} - Grado ${report.estudianteGrado}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCard(
                label: 'Total Evaluaciones',
                value: '${report.totalEvaluaciones}',
                icon: Icons.assignment,
              ),
              _StatCard(
                label: 'Promedio General',
                value: '${report.promedio}%',
                icon: Icons.trending_up,
                color: _getPromedioColor(report.promedio),
              ),
              _StatCard(
                label: 'Aprobadas',
                value: '${_countApproved(report)}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Cuenta cuántas evaluaciones fueron aprobadas
  int _countApproved(IndividualReportEntity report) {
    return report.resultados.where((r) => r.aprobado).length;
  }

  /// Determina el color del promedio
  Color _getPromedioColor(int promedio) {
    if (promedio >= 80) return Colors.green;
    if (promedio >= 60) return Colors.orange;
    return Colors.red;
  }
}

/// Widget para cada estadística individual
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
