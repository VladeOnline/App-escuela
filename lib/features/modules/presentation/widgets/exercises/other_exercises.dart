import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

// --- Verdadero o Falso --------------------------------------------------------

/// Ejercicio de verdadero o falso (RF-09, RF-24).
class TrueOrFalseExercise extends StatefulWidget {
  const TrueOrFalseExercise({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;

  @override
  State<TrueOrFalseExercise> createState() => _TrueOrFalseExerciseState();
}

class _TrueOrFalseExerciseState extends State<TrueOrFalseExercise> {
  bool? _selected;
  bool _answered = false;

  Map<String, dynamic> get _content => widget.exercise.content;

  void _onSelect(bool value) {
    if (_answered) return;

    final correct = _content['correctAnswer'] as bool;
    final isCorrect = value == correct;

    setState(() {
      _selected = value;
      _answered = true;
    });

    widget.onResult(ExerciseResult(
      exerciseId: widget.exercise.id,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.exercise.points : 0,
      completedAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final passage = _content['passage'] as String?;
    final statement = _content['statement'] as String;
    final correct = _content['correctAnswer'] as bool;
    final explanation = _content['explanation'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto de contexto opcional
        if (passage != null) ...[
          _PassageCard(text: passage),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Afirmación
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '"$statement"',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),
        Text(
          '¿Es verdadero o falso?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),

        // Botones V/F
        Row(
          children: [
            Expanded(
              child: _TruthButton(
                label: 'Verdadero',
                icon: Icons.check_circle_outline_rounded,
                value: true,
                selected: _selected == true,
                answered: _answered,
                isCorrect: correct == true,
                onTap: () => _onSelect(true),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _TruthButton(
                label: 'Falso',
                icon: Icons.cancel_outlined,
                value: false,
                selected: _selected == false,
                answered: _answered,
                isCorrect: correct == false,
                onTap: () => _onSelect(false),
              ),
            ),
          ],
        ),

        // Explicación
        if (_answered && explanation != null) ...[
          const SizedBox(height: AppSpacing.md),
          _ExplanationBanner(text: explanation),
        ],
      ],
    );
  }
}

class _TruthButton extends StatelessWidget {
  const _TruthButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.answered,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool value;
  final bool selected;
  final bool answered;
  final bool isCorrect;
  final VoidCallback onTap;

  Color _color() {
    if (!answered) return selected ? AppColors.primary : AppColors.textHint;
    if (isCorrect) return AppColors.success;
    if (selected && !isCorrect) return AppColors.error;
    return AppColors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: _color().withValues(alpha: 0.08),
          borderRadius: const BorderRadius.all(AppRadius.large),
          border: Border.all(color: _color(), width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: _color(), size: 36),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: _color(),
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Completar el espacio -----------------------------------------------------

/// Ejercicio de completar el espacio (RF-09).
/// El estudiante escribe la palabra que falta.
class FillInTheBlankExercise extends StatefulWidget {
  const FillInTheBlankExercise({
    super.key,
    required this.exercise,
    required this.onResult,
  });

  final ExerciseEntity exercise;
  final ValueChanged<ExerciseResult> onResult;

  @override
  State<FillInTheBlankExercise> createState() =>
      _FillInTheBlankExerciseState();
}

class _FillInTheBlankExerciseState extends State<FillInTheBlankExercise> {
  final _controller = TextEditingController();
  bool _answered = false;
  bool _isCorrect = false;

  Map<String, dynamic> get _content => widget.exercise.content;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_answered || _controller.text.trim().isEmpty) return;

    final answer = _controller.text.trim().toLowerCase();
    final correct =
        (_content['correctAnswer'] as String).toLowerCase();
    final isCorrect = answer == correct;

    setState(() {
      _answered = true;
      _isCorrect = isCorrect;
    });

    widget.onResult(ExerciseResult(
      exerciseId: widget.exercise.id,
      isCorrect: isCorrect,
      pointsEarned: isCorrect ? widget.exercise.points : 0,
      completedAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final passage = _content['passage'] as String?;
    final template = _content['template'] as String;
    final hint = _content['hint'] as String?;
    final correct = _content['correctAnswer'] as String;

    // Divide el template en partes antes/después del [BLANK]
    final parts = template.split('[BLANK]');
    final before = parts.isNotEmpty ? parts[0] : '';
    final after = parts.length > 1 ? parts[1] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto de contexto
        if (passage != null) ...[
          _PassageCard(text: passage),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Oración con espacio
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(color: AppColors.border),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                before,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 100),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _answered
                      ? (_isCorrect
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1))
                      : AppColors.primary.withValues(alpha: 0.07),
                  borderRadius: const BorderRadius.all(AppRadius.small),
                  border: Border(
                    bottom: BorderSide(
                      color: _answered
                          ? (_isCorrect ? AppColors.success : AppColors.error)
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _answered ? correct : '___________',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _answered
                            ? (_isCorrect ? AppColors.success : AppColors.error)
                            : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                after,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Pista
        if (hint != null && !_answered) ...[
          Row(
            children: [
              const Icon(Icons.tips_and_updates_outlined,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Pista: $hint',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Campo de texto
        if (!_answered) ...[
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Escribe tu respuesta aquí...',
              prefixIcon: Icon(Icons.edit_outlined, size: 18),
            ),
            textCapitalization: TextCapitalization.none,
            onSubmitted: (_) => _onSubmit(),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSubmit,
              child: const Text('Comprobar respuesta'),
            ),
          ),
        ],

        // Feedback
        if (_answered) ...[
          const SizedBox(height: AppSpacing.md),
          _FeedbackBanner(
            isCorrect: _isCorrect,
            userAnswer: _controller.text.trim(),
            correctAnswer: correct,
          ),
        ],
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
  });

  final bool isCorrect;
  final String userAnswer;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isCorrect ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(
          color:
              (isCorrect ? AppColors.success : AppColors.error).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: isCorrect ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: isCorrect
                ? Text(
                    '¡Correcto! La respuesta es "$correctAnswer".',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    ),
                  )
                : Text(
                    'Incorrecto. Escribiste "$userAnswer". La respuesta correcta es "$correctAnswer".',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Widgets compartidos ------------------------------------------------------

class _PassageCard extends StatelessWidget {
  const _PassageCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Texto de referencia',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(height: 1.6),
          ),
        ],
      ),
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
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.all(AppRadius.medium),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: AppColors.info, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.info,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


