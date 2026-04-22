import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/achievement_entity.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key, required this.achievements});
  final List<AchievementEntity> achievements;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return SingleChildScrollView(
      // padding lateral mínimo para que las flechas respiren
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UnlockedBar(unlocked: unlocked, total: achievements.length),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, c) {
                // Fijo en 5 columnas siempre
                const crossCount = 5;
                const spacing = AppSpacing.sm;
                final size =
                    (c.maxWidth - spacing * (crossCount - 1)) / crossCount;
                return Wrap(
                  spacing: spacing,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final a in achievements)
                      SizedBox(
                        width: size,
                        child: _BadgeTile(
                          achievement: a,
                          onTap: () => _showDetail(context, a),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, AchievementEntity a) {
    showDialog<void>(
      context: context,
      builder: (_) => _AchievementDetailDialog(achievement: a),
    );
  }
}

class _UnlockedBar extends StatelessWidget {
  const _UnlockedBar({required this.unlocked, required this.total});
  final int unlocked;
  final int total;
  static const _pink = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : unlocked / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _pink.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(AppRadius.small),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    size: 15, color: _pink),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Logros obtenidos',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ]),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _pink.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.all(AppRadius.full),
              ),
              child: Text(
                '$unlocked de $total',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: _pink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: const BorderRadius.all(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _pink.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation(_pink),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatefulWidget {
  const _BadgeTile({required this.achievement, required this.onTap});
  final AchievementEntity achievement;
  final VoidCallback onTap;

  @override
  State<_BadgeTile> createState() => _BadgeTileState();
}

class _BadgeTileState extends State<_BadgeTile>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.05).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _tooltip(AchievementEntity a) {
    if (!a.isUnlocked) {
      return '🔒 ${a.title}\n${a.description}\n${a.pointsRequired} pts requeridos';
    }
    if (a.unlockedAt != null) {
      final d = a.unlockedAt!;
      final date =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      return '✓ ${a.title}\n${a.description}\nObtenido el $date';
    }
    return '${a.title}\n${a.description}';
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.achievement;
    final isLocked = !a.isUnlocked;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scale,
          child: Tooltip(
            message: _tooltip(a),
            preferBelow: false,
            textStyle: const TextStyle(
                fontSize: 12, fontFamily: 'Nunito', color: Colors.white),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppColors.surface
                      : a.color.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(AppRadius.large),
                  border: Border.all(
                    color: isLocked
                        ? AppColors.border
                        : _hovered
                            ? a.color.withValues(alpha: 0.7)
                            : a.color.withValues(alpha: 0.25),
                    width: _hovered ? 2 : 1.5,
                  ),
                  boxShadow: _hovered && !isLocked
                      ? [
                          BoxShadow(
                            color: a.color.withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(a.icon, size: 24,
                        color: isLocked ? AppColors.textHint : a.color),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isLocked ? AppColors.surface : a.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLocked
                                ? AppColors.border
                                : a.color.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isLocked
                              ? Icons.lock_rounded
                              : Icons.check_rounded,
                          size: 8,
                          color:
                              isLocked ? AppColors.textHint : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementDetailDialog extends StatelessWidget {
  const _AchievementDetailDialog({required this.achievement});
  final AchievementEntity achievement;

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final isUnlocked = a.isUnlocked;

    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.xl)),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? a.color.withValues(alpha: 0.15)
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked
                      ? a.color.withValues(alpha: 0.4)
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: Icon(a.icon, size: 40,
                  color: isUnlocked ? a.color : AppColors.textHint),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(a.title,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(a.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            if (isUnlocked && a.unlockedAt != null)
              _Pill(
                icon: Icons.check_circle_rounded,
                label: 'Obtenido el: ${_fmt(a.unlockedAt!)}',
                color: AppColors.success,
              )
            else if (!isUnlocked)
              _Pill(
                icon: Icons.lock_rounded,
                label: 'Requiere ${a.pointsRequired} puntos',
                color: AppColors.textSecondary,
              ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}