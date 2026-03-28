import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/models/dashboard_stat.dart';

/// Tarjeta individual de estadística del dashboard.
///
/// Responsabilidad única: renderizar UN dato (valor + label + ícono).
/// No sabe nada de dónde vienen los datos — los recibe por parámetro.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatIcon(icon: stat.icon, color: stat.color),
          const SizedBox(height: AppSpacing.sm),
          _StatValue(value: stat.value, color: stat.color),
          _StatLabel(label: stat.label, sublabel: stat.sublabel),
        ],
      ),
    );
  }
}

// ─── Subwidgets privados ──────────────────────────────────────────────────────
// Por qué privados: solo StatCard los usa. Exponerlos sería ruido innecesario.

class _StatIcon extends StatelessWidget {
  const _StatIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: const BorderRadius.all(AppRadius.medium),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({required this.value, required this.color});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  const _StatLabel({required this.label, this.sublabel});

  final String label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (sublabel != null)
          Text(
            sublabel!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                ),
          ),
      ],
    );
  }
}
