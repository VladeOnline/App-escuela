import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

class ExercisePreviewWidget extends StatelessWidget {
  const ExercisePreviewWidget({super.key, required this.exercise});

  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(AppRadius.medium),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: exercise.subject.color.withOpacity(0.04),
          border: Border.all(color: exercise.subject.color.withOpacity(0.18)),
          borderRadius: const BorderRadius.all(AppRadius.medium),
        ),
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxHeight: double.infinity,
          child: _buildPreviewByType(),
        ),
      ),
    );
  }

  Widget _buildPreviewByType() => switch (exercise.type) {
        ExerciseType.multipleChoice => _MultipleChoicePreview(exercise: exercise),
        ExerciseType.trueOrFalse    => _TrueFalsePreview(exercise: exercise),
        ExerciseType.fillInTheBlank => _FillBlankPreview(exercise: exercise),
        ExerciseType.ordering       => _OrderingPreview(exercise: exercise),
      };
}

// ─── Previews por tipo ───

class _MultipleChoicePreview extends StatelessWidget {
  const _MultipleChoicePreview({required this.exercise});
  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final question = exercise.content['question'] as String? ?? '';
    final options = (exercise.content['options'] as List?)?.cast<String>() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _PreviewQuestion(text: question),
        const SizedBox(height: 6),
        ...options.take(3).map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: _PreviewOptionPill(label: opt),
            )),
      ],
    );
  }
}

class _TrueFalsePreview extends StatelessWidget {
  const _TrueFalsePreview({required this.exercise});
  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final statement = exercise.content['statement'] as String? ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _PreviewQuestion(text: statement),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(child: _MiniPill(label: '✓ Verdadero', color: AppColors.success)),
            SizedBox(width: 6),
            Expanded(child: _MiniPill(label: '✗ Falso', color: AppColors.error)),
          ],
        ),
      ],
    );
  }
}

class _FillBlankPreview extends StatelessWidget {
  const _FillBlankPreview({required this.exercise});
  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final template = (exercise.content['template'] as String? ?? '')
        .replaceAll('[BLANK]', '_____');
    return _PreviewQuestion(text: template, maxLines: 5);
  }
}

class _OrderingPreview extends StatelessWidget {
  const _OrderingPreview({required this.exercise});
  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    final words = (exercise.content['words'] as List?)?.cast<String>() ?? const [];
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: words
          .take(5)
          .map((w) => _MiniPill(label: w, color: exercise.subject.color))
          .toList(),
    );
  }
}

// ─── Helpers ───

class _PreviewQuestion extends StatelessWidget {
  const _PreviewQuestion({required this.text, this.maxLines = 3});
  final String text;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Nunito',
      ),
    );
  }
}

class _PreviewOptionPill extends StatelessWidget {
  const _PreviewOptionPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: const BorderRadius.all(AppRadius.small),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontFamily: 'Nunito'),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: const BorderRadius.all(AppRadius.small),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}