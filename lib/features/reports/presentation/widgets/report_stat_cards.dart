import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/individual_report_entity.dart';

/// 4 tarjetas de estadísticas con fondo de color.
/// "Aprobadas" usa un verde más claro que "Prom. General" para distinguirse.
class ReportStatCards extends StatelessWidget {
  const ReportStatCards({super.key, required this.report});

  final IndividualReportEntity report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.assignment_outlined,
          label: 'Evaluaciones',
          value: '${report.totalEvaluaciones}',
          cardColor: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          valueColor: const Color(0xFF1D4ED8),
          labelColor: AppColors.info,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          icon: Icons.trending_up_rounded,
          label: 'Prom. General',
          value: '${report.promedio}%',
          cardColor: const Color(0xFFF0FDFA),
          borderColor: const Color(0xFF99F6E4),
          valueColor: AppColors.primaryDark,
          labelColor: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        // Verde más claro para diferenciarse del teal de Promedio General
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          label: 'Aprobadas',
          value: '${report.aprobadas}',
          cardColor: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFFBBF7D0),
          valueColor: const Color(0xFF16A34A),   // verde más brillante
          labelColor: const Color(0xFF22C55E),   // verde claro
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          icon: Icons.star_outline_rounded,
          label: 'Puntos XP',
          value: '${report.xpPoints}',
          cardColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFDE68A),
          valueColor: const Color(0xFF92400E),
          labelColor: const Color(0xFFD97706),
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
  final String   label;
  final String   value;
  final Color    cardColor;
  final Color    borderColor;
  final Color    valueColor;
  final Color    labelColor;

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
