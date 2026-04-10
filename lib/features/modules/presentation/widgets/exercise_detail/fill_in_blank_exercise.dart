import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

/// Ejercicio de completar el espacio en blanco (RF-09).
class FillInTheBlankExercise extends StatefulWidget {
  const FillInTheBlankExercise({
    super.key,
    required this.exercise,
    required this.onResult,
    this.onRetry,
    this.onContinue,
  });

  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;
  final VoidCallback? onRetry;
  final VoidCallback? onContinue;

  @override
  State<FillInTheBlankExercise> createState() => _FillInTheBlankExerciseState();
}

class _FillInTheBlankExerciseState extends State<FillInTheBlankExercise> {
  final _ctrl = TextEditingController();
  bool _submitted = false;
  bool? _correct;

  String get _template => widget.exercise.content['template'] as String;
  String get _answer => widget.exercise.content['correctAnswer'] as String;
  String? get _hint => widget.exercise.content['hint'] as String?;
  String? get _passage => widget.exercise.content['passage'] as String?;
  String? get _explanation =>
      widget.exercise.content['explanation'] as String?;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted || _ctrl.text.trim().isEmpty) return;
    final correct = _ctrl.text.trim().toLowerCase() == _answer.toLowerCase();
    setState(() {
      _submitted = true;
      _correct = correct;
    });
    widget.onResult(ExerciseResult.fromExercise(
      exercise: widget.exercise,
      isCorrect: correct,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final parts = _template.split('[BLANK]');

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── Enunciado / texto de lectura ──────────────────────────────────────
      if (_passage != null && _passage!.isNotEmpty) ...[
        _PassageCard(text: _passage!),
        const SizedBox(height: AppSpacing.lg),
      ],

      // ── Oración con el blank ──────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              parts[0],
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                height: 2,
              ),
            ),
            _BlankChip(
              submitted: _submitted,
              correct: _correct,
              answer: _answer,
              currentText: _ctrl.text.trim(),
              levelColor: widget.exercise.difficulty.color,
            ),
            if (parts.length > 1)
              Text(
                parts[1],
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  height: 2,
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),

      // ── Pista ─────────────────────────────────────────────────────────────
      if (_hint != null && !_submitted) ...[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.08),
            borderRadius: const BorderRadius.all(AppRadius.large),
          ),
          child: Row(children: [
            const Icon(Icons.lightbulb_rounded,
                color: AppColors.secondary, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Pista: $_hint',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'Nunito',
                  color: AppColors.secondary,
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.md),
      ],

      // ── Campo de texto (solo antes de responder) ──────────────────────────
      if (!_submitted) ...[
        TextField(
          controller: _ctrl,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: 'Escribe tu respuesta aquí...',
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(AppRadius.large),
              borderSide: BorderSide(
                color: widget.exercise.difficulty.color,
                width: 2,
              ),
            ),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton(
          onPressed: _ctrl.text.trim().isNotEmpty ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: widget.exercise.difficulty.color,
            minimumSize: const Size(0, 52),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.large),
            ),
          ).copyWith(
            mouseCursor:
                const WidgetStatePropertyAll(SystemMouseCursors.click),
          ),
          child: const Text(
            'Confirmar respuesta',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],

      // ── Feedback: respuesta correcta cuando falló ──────────────────────────
      if (_submitted && !_correct!) ...[
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.08),
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(color: AppColors.success.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'La respuesta correcta es: $_answer',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ]),
        ),
      ],

      // ── Explicación ───────────────────────────────────────────────────────
      if (_submitted && _explanation != null) ...[
        const SizedBox(height: AppSpacing.md),
        _ExplanationBanner(text: _explanation!),
      ],

      // ── Botones Reintentar / Continuar ────────────────────────────────────
      if (_submitted) ...[
        const SizedBox(height: AppSpacing.lg),
        _ActionButtons(
          onRetry: widget.onRetry,
          onContinue: widget.onContinue,
        ),
      ],

      const SizedBox(height: AppSpacing.xl),
    ]);
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _PassageCard extends StatelessWidget {
  const _PassageCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.all(AppRadius.xl),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.menu_book_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Texto de lectura',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w500,
            height: 1.7,
          ),
        ),
      ]),
    );
  }
}

class _ExplanationBanner extends StatelessWidget {
  const _ExplanationBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.07),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.accent.withOpacity(0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lightbulb_rounded, color: AppColors.accent, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Nunito',
              height: 1.5,
            ),
          ),
        ),
      ]),
    );
  }
}

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
      ? (correct!
          ? AppColors.success.withOpacity(0.12)
          : AppColors.error.withOpacity(0.1))
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
      child: Text(
        _displayText,
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          color: _textColor,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({this.onRetry, this.onContinue});

  final VoidCallback? onRetry;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (onRetry != null) ...[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              mouseCursor:
                  const WidgetStatePropertyAll(SystemMouseCursors.click),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
      ],
      if (onContinue != null)
        Expanded(
          child: FilledButton.icon(
            onPressed: onContinue,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Continuar'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 15,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              mouseCursor:
                  const WidgetStatePropertyAll(SystemMouseCursors.click),
            ),
          ),
        ),
    ]);
  }
}