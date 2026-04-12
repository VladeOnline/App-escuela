import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/exercise_detail/exercise_instructions_dialog.dart';
import '../widgets/exercise_detail/exercise_result_dialog.dart';
import '../widgets/exercise_detail/exercise_timer_bar.dart';
import '../widgets/exercise_detail/exercise_type_content.dart';

/// Flujo del estudiante:
///   1. [waiting]     â†’ dialog de instrucciones visible, timer pausado
///   2. [answering]   â†’ lee el texto, responde, toca "Confirmar respuesta"
///   3. [reviewing]   â†’ ve respuestas coloreadas + explicación inline
///                      · Reintentar â†’ dialog de aviso "sin puntos" â†’ resetea
///                      · Continuar  â†’ popup de resultado con búho + puntos
///   4. [celebrating] â†’ popup de resultado, luego pop de la página
class ExerciseDetailPage extends StatefulWidget {
  const ExerciseDetailPage({super.key, required this.exercise});
  final ExerciseEntity exercise;

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  ExerciseResult? _result;
  // Inicia en [waiting] para que el timer no corra hasta cerrar el dialog.
  ExercisePhase _phase = ExercisePhase.waiting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ExerciseInstructionsDialog.show(context, exercise: widget.exercise);
      // Timer arranca solo después de que el estudiante toca "¡Listo, empecemos!"
      if (mounted) setState(() => _phase = ExercisePhase.answering);
    });
  }

  void _showInstructions() =>
      ExerciseInstructionsDialog.show(context, exercise: widget.exercise);

  void _onVerify(ExerciseResult result) {
    if (_phase != ExercisePhase.answering) return;
    setState(() {
      _result = result;
      _phase = ExercisePhase.reviewing;
    });
  }

  /// Muestra el dialog de aviso antes de reintentar.
  /// El niño puede reintentar cuantas veces quiera, pero ya no gana puntos.
  Future<void> _onRetry() async {
    final confirmed = await _RetryConfirmDialog.show(context);
    if (!mounted || confirmed != true) return;
    setState(() {
      _result = null;
      _phase = ExercisePhase.answering;
    });
  }

  /// Avanza al popup de resultado.
  /// Guard: si _result es null por alguna razón, no hace nada.
  Future<void> _onContinue() async {
    if (_result == null) return;
    setState(() => _phase = ExercisePhase.celebrating);
    await ExerciseResultDialog.show(
      context,
      result: _result!,
      exercise: widget.exercise,
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF8),
      body: Column(
        children: [
          _ExerciseHeader(
            exercise: widget.exercise,
            onShowInstructions: _showInstructions,
          ),
          // El timer solo avanza cuando la fase es [answering]
          ExerciseTimerBar(running: _phase == ExercisePhase.answering),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ExerciseTypeContent(
                    exercise: widget.exercise,
                    onResult: _onVerify,
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

enum ExercisePhase { waiting, answering, reviewing, celebrating }

// --- Dialog de confirmación de reintento --------------------------------------

class _RetryConfirmDialog extends StatelessWidget {
  const _RetryConfirmDialog();

  /// Retorna [true] si el estudiante confirmó el reintento, [false] o null si canceló.
  static Future<bool?> show(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (_, __, ___) => const _RetryConfirmDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -- Cabecera --------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
              ),
              child: Column(children: [
                const Text('Cargando...', style: TextStyle(fontSize: 20)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '¿Quieres intentarlo de nuevo?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
              ]),
            ),

            // -- Cuerpo ----------------------------------------------------
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(children: [
                Text(
                  '¡Puedes reintentar cuantas veces quieras! Pero recuerda: los puntos ya no se cuentan en este intento.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Pill informativo
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.all(AppRadius.full),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Este intento no suma puntos',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.lg),

                // -- Botones -----------------------------------------------
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(AppRadius.large),
                        ),
                      ).copyWith(
                        mouseCursor: const WidgetStatePropertyAll(
                          SystemMouseCursors.click,
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Reintentar',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(AppRadius.large),
                        ),
                      ).copyWith(
                        mouseCursor: const WidgetStatePropertyAll(
                          SystemMouseCursors.click,
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Header de la página ------------------------------------------------------

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader({
    required this.exercise,
    required this.onShowInstructions,
  });

  final ExerciseEntity exercise;
  final VoidCallback onShowInstructions;

  @override
  Widget build(BuildContext context) {
    final color = exercise.difficulty.color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.all(AppRadius.medium),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.all(AppRadius.medium),
          ),
          child: Icon(exercise.type.icon, color: color, size: 18),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            exercise.title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.all(AppRadius.full),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.signal_cellular_alt_rounded, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              exercise.difficulty.label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'Nunito',
              ),
            ),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

