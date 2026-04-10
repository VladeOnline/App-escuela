import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

class FillInTheBlankExercise extends StatefulWidget {
  const FillInTheBlankExercise({super.key, required this.exercise, required this.onResult});
  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;

  @override
  State<FillInTheBlankExercise> createState() => _FillInTheBlankExerciseState();
}

class _FillInTheBlankExerciseState extends State<FillInTheBlankExercise> {
  final _ctrl = TextEditingController();
  bool  _submitted = false;
  bool? _correct;

  String  get _template => widget.exercise.content['template'] as String;
  String  get _answer   => widget.exercise.content['correctAnswer'] as String;
  String? get _hint     => widget.exercise.content['hint'] as String?;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _submit() {
    if (_submitted || _ctrl.text.trim().isEmpty) return;
    final correct = _ctrl.text.trim().toLowerCase() == _answer.toLowerCase();
    setState(() { _submitted = true; _correct = correct; });
    widget.onResult(ExerciseResult.fromExercise(
      exercise: widget.exercise,
      isCorrect: correct,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final parts = _template.split('[BLANK]');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Texto con blank
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(parts[0], style: const TextStyle(fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.w600, height: 2)),
            _BlankChip(
              submitted: _submitted,
              correct: _correct,
              answer: _answer,
              currentText: _ctrl.text.trim(),
              levelColor: widget.exercise.difficulty.color,
            ),
            if (parts.length > 1)
              Text(parts[1], style: const TextStyle(fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.w600, height: 2)),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),

      // Pista
      if (_hint != null && !_submitted)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
              borderRadius: const BorderRadius.all(AppRadius.large),
            ),
            child: Row(children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.secondary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text('Pista: $_hint',
                  style: const TextStyle(fontSize: 12, fontFamily: 'Nunito', color: AppColors.secondary))),
            ]),
          ),
        ),

      // Input
      if (!_submitted)
        TextField(
          controller: _ctrl,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta aquí...',
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(AppRadius.large),
              borderSide: BorderSide(color: widget.exercise.difficulty.color, width: 2),
            ),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),

      // Respuesta correcta si falló
      if (_submitted && !_correct!)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('La respuesta correcta es: $_answer',
                style: const TextStyle(fontSize: 14, fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700, color: AppColors.success)),
          ]),
        ),

      const SizedBox(height: AppSpacing.lg),
      if (!_submitted)
        FilledButton(
          onPressed: _ctrl.text.trim().isNotEmpty ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: widget.exercise.difficulty.color,
            minimumSize: const Size(0, 52),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.large)),
          ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
          child: const Text('Confirmar respuesta',
              style: TextStyle(fontSize: 16, fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        ),
      const SizedBox(height: AppSpacing.xl),
    ]);
  }
}

// ─── Chip del espacio en blanco ───

class _BlankChip extends StatelessWidget {
  const _BlankChip({
    required this.submitted,
    required this.correct,
    required this.answer,
    required this.currentText,
    required this.levelColor,
  });

  final bool submitted;
  final bool? correct;
  final String answer;
  final String currentText;
  final Color levelColor;

  Color get _bg => submitted
      ? (correct! ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.1))
      : levelColor.withOpacity(0.08);

  Color get _border => submitted
      ? (correct! ? AppColors.success : AppColors.error)
      : levelColor;

  Color get _textColor => submitted
      ? (correct! ? AppColors.success : AppColors.error)
      : levelColor;

  String get _displayText {
    if (!submitted) return currentText.isEmpty ? '  ___  ' : currentText;
    return correct! ? answer : currentText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(color: _border, width: 2),
      ),
      child: Text(_displayText,
          style: TextStyle(fontSize: 18, fontFamily: 'Nunito',
              fontWeight: FontWeight.w800, color: _textColor)),
    );
  }
}
