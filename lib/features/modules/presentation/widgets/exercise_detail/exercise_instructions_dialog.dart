import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

class ExerciseInstructionsDialog extends StatelessWidget {
  const ExerciseInstructionsDialog._({required this.exercise});
  final ExerciseEntity exercise;

  static Future<void> show(BuildContext context, {required ExerciseEntity exercise}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 380),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (_, __, ___) => ExerciseInstructionsDialog._(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = exercise.difficulty.color;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 48, offset: const Offset(0, 20))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -- Cabecera con búho pensando --
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.04)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
              ),
              child: Column(children: [
                SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/buho_pensando.png', fit: BoxFit.contain),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: const BorderRadius.all(AppRadius.full),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(exercise.type.icon, color: color, size: 14),
                    const SizedBox(width: 5),
                    Text(exercise.type.label,
                        style: TextStyle(fontSize: 12, fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700, color: color)),
                  ]),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  exercise.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
              ]),
            ),

            // -- Cuerpo --
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.07),
                    borderRadius: const BorderRadius.all(AppRadius.large),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(exercise.instructions,
                          style: const TextStyle(fontSize: 14, fontFamily: 'Nunito',
                              height: 1.6, color: AppColors.textPrimary)),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.all(AppRadius.full),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '¡Puedes ganar hasta ${exercise.difficulty.basePoints} puntos!',
                      style: const TextStyle(fontSize: 13, fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700, color: AppColors.secondary),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('¡Listo, empecemos!',
                        style: TextStyle(fontSize: 16, fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      minimumSize: const Size(0, 52),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(AppRadius.large)),
                    ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

