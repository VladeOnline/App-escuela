import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class SubjectStatCards extends StatelessWidget {
  const SubjectStatCards({
    super.key,
    required this.totalExercises,
    required this.completedExercises,
    required this.pendingExercises,
    required this.successRate,
  });

  final int totalExercises;
  final int completedExercises;
  final int pendingExercises;
  final double successRate;

  Color _rateColor(double r) {
    if (r >= 0.7) return AppColors.success;
    if (r >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  String _rateLabel(double r) {
    if (r >= 0.7) return 'muy bien';
    if (r >= 0.4) return 'en progreso';
    return 'necesita apoyo';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.assignment_rounded,
                  label: 'Total',
                  value: '$totalExercises',
                  subtitle: 'ejercicios',
                  gradientColors: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Completados',
                  value: '$completedExercises',
                  subtitle: 'de $totalExercises',
                  gradientColors: const [Color(0xFF10B981), Color(0xFF34D399)],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Tasa de éxito',
                  value: '${(successRate * 100).toStringAsFixed(0)}%',
                  subtitle: _rateLabel(successRate),
                  gradientColors: [
                    _rateColor(successRate),
                    _rateColor(successRate).withValues(alpha: 0.7),
                  ],
                  showProgressBar: true,
                  progressValue: successRate,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _StatCard(
                  icon: Icons.schedule_rounded,
                  label: 'Pendientes',
                  value: '$pendingExercises',
                  subtitle: pendingExercises == 0
                      ? '¡Todo al día! 🎉'
                      : 'por hacer',
                  gradientColors: pendingExercises == 0
                      ? const [Color(0xFF10B981), Color(0xFF34D399)]
                      : const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Divisor sutil sin texto
        Container(
          height: 1,
          color: AppColors.border,
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
    required this.subtitle,
    required this.gradientColors,
    this.showProgressBar = false,
    this.progressValue = 0,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final List<Color> gradientColors;
  final bool showProgressBar;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    final baseColor = gradientColors.first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: baseColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: const BorderRadius.all(AppRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        color: baseColor)),
                if (showProgressBar) ...[
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: baseColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(baseColor),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        color: baseColor.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}