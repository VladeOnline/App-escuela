import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../mock/report_mock_data.dart';

/// Sección de gamificación: ranking, puntos XP y máximo 2 insignias.
/// Usa IntrinsicHeight para que todas las cajas tengan la misma altura,
/// y Expanded para que ranking + XP llenen el espacio disponible.
class GamificationStrip extends StatelessWidget {
  const GamificationStrip({
    super.key,
    required this.ranking,
    required this.xp,
    required this.levelName,
    required this.badges,
  });

  final int    ranking;
  final int    xp;
  final String levelName;
  final List<BadgeData> badges;

  @override
  Widget build(BuildContext context) {
    final visibleBadges = badges.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gamificación',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ranking
              Expanded(
                child: _RankingBox(ranking: ranking),
              ),
              const SizedBox(width: AppSpacing.sm),
              // XP
              Expanded(
                child: _XpBox(xp: xp, levelName: levelName),
              ),
              // Insignias (ancho fijo, se adaptan al número)
              if (visibleBadges.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                ...visibleBadges.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xs),
                    child: SizedBox(width: 80, child: _BadgeCard(data: b)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Ranking ───────────────────────────────────────────────────────────────────

class _RankingBox extends StatelessWidget {
  const _RankingBox({required this.ranking});
  final int ranking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFFDE68A)),
        borderRadius: const BorderRadius.all(AppRadius.medium),
      ),
      child: Row(
        children: [
          Text(
            '#$ranking',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD97706),
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ranking',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'en su grado',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFB45309),
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── XP ────────────────────────────────────────────────────────────────────────

class _XpBox extends StatelessWidget {
  const _XpBox({required this.xp, required this.levelName});
  final int    xp;
  final String levelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        borderRadius: const BorderRadius.all(AppRadius.medium),
      ),
      child: Row(
        children: [
          Text(
            '$xp',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF059669),
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Puntos XP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF065F46),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  levelName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.data});
  final BadgeData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: const BorderRadius.all(AppRadius.medium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 24, color: data.color),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}