import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget que muestra gamificación y puntos del estudiante
class GamificationSection extends StatelessWidget {
  final int puntos;
  final int nivel;
  final int medallas;

  const GamificationSection({
    Key? key,
    this.puntos = 0,
    this.nivel = 1,
    this.medallas = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Gamificación',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Grid de puntos/Nivel/Medalas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            children: [
              _GamificationCard(
                icon: Icons.star,
                iconColor: Colors.amber,
                label: 'Puntos',
                value: '$puntos',
                backgroundColor: Colors.amber[50]!,
              ),
              _GamificationCard(
                icon: Icons.trending_up,
                iconColor: Colors.blue,
                label: 'Nivel',
                value: '$nivel',
                backgroundColor: Colors.blue[50]!,
              ),
              _GamificationCard(
                icon: Icons.military_tech,
                iconColor: Colors.purple,
                label: 'Medallas',
                value: '$medallas',
                backgroundColor: Colors.purple[50]!,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Barra de progreso al siguiente nivel
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso a Nivel ${nivel + 1}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(puntos % 100)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (puntos % 100) / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue[400]!,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual de gamificación
class _GamificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color backgroundColor;

  const _GamificationCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
