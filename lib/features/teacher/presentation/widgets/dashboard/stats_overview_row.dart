import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/dashboard_stat.dart';
import 'stat_card.dart';

class StatsOverviewRow extends StatelessWidget {
  const StatsOverviewRow({super.key, required this.stats});

  final List<DashboardStat> stats;

  factory StatsOverviewRow.mock() {
    return StatsOverviewRow(
      stats: const [
        DashboardStat(
          label: 'Estudiantes',
          value: '8',
          icon: Icons.people_alt_rounded,
          color: AppColors.primary,
          sublabel: 'este año',
        ),
        DashboardStat(
          label: 'Casos graves',
          value: '2',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
          sublabel: 'requieren atención',
        ),
        DashboardStat(
          label: 'Sesiones recientes',
          value: '10',
          icon: Icons.play_circle_outline_rounded,
          color: AppColors.accent,
          sublabel: 'últimos 7 días',
        ),
        DashboardStat(
          label: 'Progreso promedio',
          value: '70%',
          icon: Icons.trending_up_rounded,
          color: AppColors.secondary,
          sublabel: 'avance general',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        final isNarrow = constraints.maxWidth < 500;

        if (isNarrow) {
          return _TwoColumnGrid(stats: stats);
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < stats.length; i++) ...[
                Expanded(child: StatCard(stat: stats[i])),
                if (i < stats.length - 1)
                  const SizedBox(width: AppSpacing.md),
              ],
            ],
          ),
        );
      },
    );
  }
}
class _TwoColumnGrid extends StatelessWidget {
  const _TwoColumnGrid({required this.stats});

  final List<DashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.3,
      children: stats.map((s) => StatCard(stat: s)).toList(),
    );
  }
}