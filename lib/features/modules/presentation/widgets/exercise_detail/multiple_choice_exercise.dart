import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';
import 'exercise_option_card.dart';

class MultipleChoiceExercise extends StatefulWidget {
  const MultipleChoiceExercise({super.key, required this.exercise, required this.onResult});
  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  int? _selected;
  bool _submitted = false;

  static const _letters   = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const _optColors = [
    Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFFEF4444),
  ];

  List<String> get _options      => (widget.exercise.content['options'] as List).cast<String>();
  int          get _correctIndex => widget.exercise.content['correctIndex'] as int;
  String       get _question     => widget.exercise.content['question'] as String;
  String?      get _explanation  => widget.exercise.content['explanation'] as String?;

  void _submit() {
    if (_selected == null || _submitted) return;
    setState(() => _submitted = true);
    widget.onResult(ExerciseResult.fromExercise(
      exercise: widget.exercise,
      isCorrect: _selected == _correctIndex,
    ));
  }

  ExerciseOptionState _stateFor(int i) {
    if (!_submitted) return _selected == i ? ExerciseOptionState.selected : ExerciseOptionState.idle;
    if (i == _correctIndex) return ExerciseOptionState.correct;
    if (_selected == i)     return ExerciseOptionState.wrong;
    return ExerciseOptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Pregunta
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Text(_question,
          style: const TextStyle(fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.w700, height: 1.5),
          textAlign: TextAlign.center),
      ),
      const SizedBox(height: AppSpacing.lg),

      // Opciones
      ...List.generate(_options.length, (i) => ExerciseOptionCard(
        letter: i < _letters.length ? _letters[i] : '${i + 1}',
        color:  _optColors[i % _optColors.length],
        text:   _options[i],
        state:  _stateFor(i),
        onTap:  _submitted ? null : () => setState(() => _selected = i),
      )),

      // Explicación
      if (_submitted && _explanation != null) ...[
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.07),
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(color: AppColors.accent.withOpacity(0.25)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lightbulb_rounded, color: AppColors.accent, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(_explanation!,
                style: const TextStyle(fontSize: 13, fontFamily: 'Nunito', height: 1.5))),
          ]),
        ),
      ],

      // Botón confirmar
      if (!_submitted) ...[
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: _selected != null ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: widget.exercise.difficulty.color,
            minimumSize: const Size(0, 52),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.large)),
          ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
          child: const Text('Confirmar respuesta',
              style: TextStyle(fontSize: 16, fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        ),
      ],
      const SizedBox(height: AppSpacing.xl),
    ]);
  }
}
