import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/dashboard_stat.dart';
import 'stat_card.dart';

/// Fila de estadísticas generales del docente.
///
/// Muestra 4 tarjetas: estudiantes, casos graves, sesiones recientes
/// y progreso promedio. Recibe los datos desde la página padre.
///
/// Por qué los datos vienen de afuera y no los calcula aquí:
/// Este widget es "tonto" (dumb widget) — solo presenta. La lógica
/// de calcular stats vendrá del notifier cuando el Back conecte.
/// Esto lo hace fácil de testear y reutilizar.
class StatsOverviewRow extends StatelessWidget {
  const StatsOverviewRow({super.key, required this.stats});

  final List<DashboardStat> stats;

  /// Constructor con datos mock para usar mientras el Back no está listo.
  /// Cuando conecte la API, la página padre pasará los datos reales.
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
        // En pantallas muy angostas (< 500px) apilamos en 2 columnas.
        // En el resto, una fila de 4 que se adapta con Flexible.
        final isNarrow = constraints.maxWidth < 500;

        if (isNarrow) {
          return _TwoColumnGrid(stats: stats);
        }

        return Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              Flexible(child: StatCard(stat: stats[i])),
              if (i < stats.length - 1)
                const SizedBox(width: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

// ─── Fallback para pantallas angostas ─────────────────────────────────────────

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
