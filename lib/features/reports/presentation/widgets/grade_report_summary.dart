import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/grade_report_entity.dart';

/// Resumen de estadísticas del reporte por grado.
/// Reutiliza los colores semánticos del design system en lugar de Colors.green/blue.
class GradeReportSummary extends StatelessWidget {
  const GradeReportSummary({super.key, required this.report});

  final GradeReportEntity report;

  Color _promedioColor(int pct) {
    if (pct >= 75) return AppColors.success;
    if (pct >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────
        Text(
          'Grado ${report.grado}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Stat cards ───────────────────────────────────────────
        Row(
          children: [
            _StatCard(
              icon: Icons.groups_outlined,
              label: 'Estudiantes',
              value: '${report.totalEstudiantes}',
              cardColor: const Color(0xFFEFF6FF),
              borderColor: const Color(0xFFBFDBFE),
              valueColor: const Color(0xFF1D4ED8),
              labelColor: AppColors.info,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              icon: Icons.assignment_outlined,
              label: 'Evaluaciones',
              value: '${report.totalResultados}',
              cardColor: const Color(0xFFF0FDFA),
              borderColor: const Color(0xFF99F6E4),
              valueColor: AppColors.primaryDark,
              labelColor: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatCard(
              icon: Icons.trending_up_rounded,
              label: 'Promedio Grado',
              value: '${report.promedioGrado}%',
              cardColor: _promedioColor(report.promedioGrado)
                  .withValues(alpha: 0.08),
              borderColor: _promedioColor(report.promedioGrado)
                  .withValues(alpha: 0.3),
              valueColor: _promedioColor(report.promedioGrado),
              labelColor: _promedioColor(report.promedioGrado),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.cardColor,
    required this.borderColor,
    required this.valueColor,
    required this.labelColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color cardColor;
  final Color borderColor;
  final Color valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.all(AppRadius.medium),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: valueColor),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
