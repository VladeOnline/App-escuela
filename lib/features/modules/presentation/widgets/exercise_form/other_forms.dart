import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import 'form_shared.dart';

// ─── Verdadero / Falso ────────────────────────────────────────────────────────

class ExFormTrueOrFalse extends StatelessWidget {
  const ExFormTrueOrFalse({
    super.key,
    required this.statementCtrl,
    required this.correctAnswer,
    required this.onAnswerChanged,
  });

  final TextEditingController statementCtrl;
  final bool correctAnswer;
  final ValueChanged<bool> onAnswerChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExFormFieldLabel(
          label: 'Afirmación',
          required: true,
          hint: 'Escribe la oración que el estudiante debe evaluar.',
          child: TextField(
            controller: statementCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ej: Los nombres propios siempre se escriben con mayúscula.',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Respuesta correcta *', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: ExFormSelectableTile(
                label: 'Verdadero',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                selected: correctAnswer,
                onTap: () => onAnswerChanged(true),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ExFormSelectableTile(
                label: 'Falso',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                selected: !correctAnswer,
                onTap: () => onAnswerChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Completar el espacio ─────────────────────────────────────────────────────

class ExFormFillInBlank extends StatelessWidget {
  const ExFormFillInBlank({
    super.key,
    required this.templateCtrl,
    required this.answerCtrl,
    required this.hintCtrl,
  });

  final TextEditingController templateCtrl;
  final TextEditingController answerCtrl;
  final TextEditingController hintCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExFormFieldLabel(
          label: 'Texto con espacio en blanco',
          required: true,
          hint: 'Usa [BLANK] para indicar dónde va el espacio.',
          child: TextField(
            controller: templateCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Ej: Lucía caminó hacia la [BLANK] después de desayunar.',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ExFormFieldLabel(
          label: 'Respuesta correcta',
          required: true,
          child: TextField(
            controller: answerCtrl,
            decoration: const InputDecoration(hintText: 'Ej: escuela'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ExFormFieldLabel(
          label: 'Pista para el estudiante (opcional)',
          child: TextField(
            controller: hintCtrl,
            decoration: const InputDecoration(
              hintText: 'Ej: Es el lugar donde van los niños a aprender.',
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Ordenamiento — próximo sprint ────────────────────────────────────────────

class ExFormOrderingComingSoon extends StatelessWidget {
  const ExFormOrderingComingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.06),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.construction_rounded, color: AppColors.secondary, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ordenamiento — Próximo sprint',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Este tipo de ejercicio estará disponible en el siguiente sprint.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
