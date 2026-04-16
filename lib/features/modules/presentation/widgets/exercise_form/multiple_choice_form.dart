import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import 'form_shared.dart';

/// Formulario de contenido para ejercicios de selección múltiple.
/// Soporta agregar y eliminar opciones dinámicamente (mínimo 2).
class ExFormMultipleChoice extends StatelessWidget {
  const ExFormMultipleChoice({
    super.key,
    required this.questionCtrl,
    required this.optionCtrls,
    required this.correctIndex,
    required this.onCorrectChanged,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.explanationCtrl,
  });

  final TextEditingController questionCtrl;
  final List<TextEditingController> optionCtrls;
  final int correctIndex;
  final ValueChanged<int> onCorrectChanged;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;
  final TextEditingController explanationCtrl;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExFormFieldLabel(
          label: 'Pregunta',
          required: true,
          child: TextField(
            controller: questionCtrl,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Ej: ¿Qué hizo el personaje al llegar a la escuela?'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Título "Opciones de respuesta *"
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleMedium,
            children: const [
              TextSpan(text: 'Opciones de respuesta'),
              TextSpan(text: ' *', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Selecciona cuál es la respuesta correcta con el botón de la izquierda.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Opciones dinámicas
        ...List.generate(optionCtrls.length, (i) => _OptionRow(
          index: i,
          letter: i < _letters.length ? _letters[i] : '${i + 1}',
          controller: optionCtrls[i],
          isCorrect: correctIndex == i,
          canRemove: optionCtrls.length > 2,
          onSelectCorrect: () => onCorrectChanged(i),
          onRemove: () => onRemoveOption(i),
        )),

        // Botón agregar opción
        _AddOptionButton(onTap: onAddOption),

        const SizedBox(height: AppSpacing.md),
        ExFormFieldLabel(
          label: 'Explicación (opcional)',
          hint: 'Se mostrará al estudiante después de responder.',
          child: TextField(
            controller: explanationCtrl,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Ej: La letra mayúscula se usa al inicio de oración.'),
          ),
        ),
      ],
    );
  }
}

// --- Fila de opción -----------------------------------------------------------

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.index,
    required this.letter,
    required this.controller,
    required this.isCorrect,
    required this.canRemove,
    required this.onSelectCorrect,
    required this.onRemove,
  });

  final int index;
  final String letter;
  final TextEditingController controller;
  final bool isCorrect;
  final bool canRemove;
  final VoidCallback onSelectCorrect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // Botón seleccionar correcta
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onSelectCorrect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCorrect ? AppColors.success : Colors.transparent,
                  border: Border.all(color: isCorrect ? AppColors.success : AppColors.border, width: 2),
                ),
                child: isCorrect
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : Center(
                        child: Text(letter, style: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w700, fontSize: 11, fontFamily: 'Nunito')),
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Campo de texto
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Opción $letter',
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                  borderSide: BorderSide(color: isCorrect ? AppColors.success : AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          // Botón eliminar
          if (canRemove) ...[
            const SizedBox(width: AppSpacing.xs),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: AppColors.textHint),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- Botón agregar opción -----------------------------------------------------

class _AddOptionButton extends StatelessWidget {
  const _AddOptionButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
            borderRadius: const BorderRadius.all(AppRadius.medium),
            color: AppColors.primary.withValues(alpha: 0.04),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
              const SizedBox(width: AppSpacing.xs),
              Text('Agregar opción', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Nunito', color: AppColors.primary.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }
}


