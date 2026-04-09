import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class ExercisesEmptyState extends StatelessWidget {
  const ExercisesEmptyState({super.key, this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 72,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aún no hay ejercicios',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                onCreate != null
                    ? 'Comience a crear ejercicios para este módulo y enriquezca el aprendizaje de sus estudiantes.'
                    : 'El docente aún no ha agregado ejercicios.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      height: 1.5,
                    ),
              ),
            ),
            if (onCreate != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add_circle_rounded, size: 20),
                  label: const Text('Crear el primer ejercicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: 16,
                    ),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(AppRadius.medium),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Nunito',
                      letterSpacing: 0.3,
                    ),
                  ).copyWith(
                    mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}