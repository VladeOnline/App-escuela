import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/exercise_detail/exercise_instructions_dialog.dart';
import '../widgets/exercise_detail/exercise_result_dialog.dart';
import '../widgets/exercise_detail/exercise_timer_bar.dart';
import '../widgets/exercise_detail/exercise_type_content.dart';

/// Flujo del estudiante:
///   1. [answering]  → lee el texto, responde, toca "Verificar"
///   2. [reviewing]  → ve respuestas coloreadas + explicación inline
///                     puede Reintentar (sin puntos) o Continuar
///   3. Al Continuar → popup de celebración con búho + puntos
class ExerciseDetailPage extends StatefulWidget {
  const ExerciseDetailPage({super.key, required this.exercise});
  final ExerciseEntity exercise;

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  ExerciseResult? _result;
  ExercisePhase   _phase = ExercisePhase.answering;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => ExerciseInstructionsDialog.show(context, exercise: widget.exercise));
  }

  void _showInstructions() =>
      ExerciseInstructionsDialog.show(context, exercise: widget.exercise);

  void _onVerify(ExerciseResult result) {
    if (_phase != ExercisePhase.answering) return;
    setState(() { _result = result; _phase = ExercisePhase.reviewing; });
  }

  void _onRetry() => setState(() { _result = null; _phase = ExercisePhase.answering; });

  Future<void> _onContinue() async {
    setState(() => _phase = ExercisePhase.celebrating);
    await ExerciseResultDialog.show(context, result: _result!, exercise: widget.exercise);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF8),
      body: Column(
        children: [
          _ExerciseHeader(exercise: widget.exercise, onShowInstructions: _showInstructions),
          ExerciseTimerBar(running: _phase == ExercisePhase.answering),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ExerciseTypeContent(
                    exercise: widget.exercise,
                    phase: _phase,
                    result: _result,
                    onVerify: _onVerify,
                    onRetry: _onRetry,
                    onContinue: _onContinue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ExercisePhase { answering, reviewing, celebrating }

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader({required this.exercise, required this.onShowInstructions});
  final ExerciseEntity exercise;
  final VoidCallback onShowInstructions;

  @override
  Widget build(BuildContext context) {
    final color = exercise.difficulty.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.all(AppRadius.medium),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: const BorderRadius.all(AppRadius.medium),
          ),
          child: Icon(exercise.type.icon, color: color, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(exercise.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: const BorderRadius.all(AppRadius.full),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.signal_cellular_alt_rounded, color: color, size: 14),
            const SizedBox(width: 4),
            Text(exercise.difficulty.label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700,
                    fontSize: 12, fontFamily: 'Nunito')),
          ]),
        ),
        const SizedBox(width: AppSpacing.sm),
        Tooltip(
          message: 'Ver instrucciones',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onShowInstructions,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 18),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}