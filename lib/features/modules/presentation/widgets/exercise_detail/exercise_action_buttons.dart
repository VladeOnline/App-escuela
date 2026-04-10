import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import '../../pages/exercise_detail_page.dart';

class ExerciseActionButtons extends StatelessWidget {
  const ExerciseActionButtons({
    super.key,
    required this.phase,
    required this.result,
    required this.exercise,
    required this.onRetry,
    required this.onContinue,
  });

  final ExercisePhase   phase;
  final ExerciseResult? result;
  final ExerciseEntity  exercise;
  final VoidCallback    onRetry;
  final VoidCallback    onContinue;

  @override
  Widget build(BuildContext context) {
    if (phase != ExercisePhase.reviewing) return const SizedBox.shrink();

    final isCorrect = result?.isCorrect ?? false;
    final color     = exercise.difficulty.color;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: AppSpacing.lg),
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isCorrect ? AppColors.success.withOpacity(0.08) : AppColors.error.withOpacity(0.07),
          borderRadius: const BorderRadius.all(AppRadius.large),
          border: Border.all(
            color: isCorrect ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.25),
          ),
        ),
        child: Row(children: [
          SizedBox(
            width: 52, height: 52,
            child: Image.asset(
              isCorrect
                  ? 'assets/images/buho_celebracion.png'
                  : 'assets/images/buho_triste.png',
              fit: BoxFit.contain,
              color: Colors.white,
              colorBlendMode: BlendMode.multiply,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isCorrect ? '¡Respuesta correcta!' : '¡Casi lo tienes!',
                style: TextStyle(fontSize: 15, fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: isCorrect ? AppColors.success : AppColors.error),
              ),
              const SizedBox(height: 2),
              Text(
                isCorrect
                    ? '¡Muy bien! Ganaste ${result!.pointsEarned} puntos.'
                    : 'No te preocupes, ¡puedes intentarlo de nuevo!',
                style: TextStyle(fontSize: 12, fontFamily: 'Nunito',
                    color: isCorrect
                        ? AppColors.success.withOpacity(0.8)
                        : AppColors.error.withOpacity(0.8)),
              ),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: AppSpacing.md),
      Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.replay_rounded, size: 18),
            label: const Text('Reintentar',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.large)),
            ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Continuar',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 15)),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size(0, 50),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.large)),
            ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
          ),
        ),
      ]),
      const SizedBox(height: AppSpacing.xl),
    ]);
  }
}