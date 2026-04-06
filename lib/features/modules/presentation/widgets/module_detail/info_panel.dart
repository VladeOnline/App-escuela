import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

/// Tablita amarilla de info: cuenta ejercicios por nivel y por materia.
/// Debajo va el botón principal "Crear ejercicio".
class InfoPanel extends StatelessWidget {
  const InfoPanel({
    super.key,
    required this.exercises,
    required this.isTeacher,
    required this.onCreateExercise,
  });

  final List<ExerciseEntity> exercises;
  final bool isTeacher;
  final VoidCallback onCreateExercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(exercises: exercises),
        if (isTeacher) ...[
          const SizedBox(height: AppSpacing.md),
          _CreateButton(onPressed: onCreateExercise),
        ],
      ],
    );
  }
}

// ─── Card amarilla con conteos ───────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.exercises});
  final List<ExerciseEntity> exercises;

  static const _yellowBg = Color(0xFFFEF9C3);
  static const _yellowBorder = Color(0xFFEAB308);
  static const _yellowText = Color(0xFF854D0E);

  int _countByDifficulty(DifficultyLevel d) =>
      exercises.where((e) => e.difficulty == d).length;

  int _countBySubject(Subject s) =>
      exercises.where((e) => e.subject == s).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _yellowBg,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: _yellowBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: _yellowBorder.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 16, color: _yellowText),
              SizedBox(width: 6),
              Text(
                'Info general',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _yellowText,
                  fontFamily: 'Nunito',
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: _yellowBorder),
          const SizedBox(height: AppSpacing.sm),
          // Por dificultad
          ...DifficultyLevel.values.map(
            (d) => _InfoRow(
              label: d.label,
              value: _countByDifficulty(d),
              accent: d.color,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1, color: _yellowBorder),
          const SizedBox(height: 6),
          // Por materia (solo las que tengan al menos 1)
          ...Subject.values
              .where((s) => _countBySubject(s) > 0)
              .map(
                (s) => _InfoRow(
                  label: s.shortLabel,
                  value: _countBySubject(s),
                  accent: s.color,
                ),
              ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, required this.accent});
  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF854D0E),
                fontFamily: 'Nunito',
              ),
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF854D0E),
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botón crear ejercicio ───────────────────────────────────────────────────

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Crear ejercicio'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.medium),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}
