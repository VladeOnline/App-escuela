import 'package:flutter/material.dart';

import 'subject.dart';

export 'subject.dart';

// --- Enums ---

/// Tipo de módulo académico disponible en el sistema.
enum ModuleType { reading, writing, math }

/// Nivel de dificultad de un ejercicio.
enum DifficultyLevel { basic, intermediate, advanced }

/// Tipo de ejercicio (define qué widget de ejercicio se renderiza).
enum ExerciseType {
  multipleChoice,   // Selección múltiple
  fillInTheBlank,   // Completar el espacio
  trueOrFalse,      // Verdadero o falso
  ordering,         // Ordenar elementos
}

// --- Extensiones de conveniencia ---

extension ModuleTypeX on ModuleType {
  String get label => switch (this) {
        ModuleType.reading => 'Lectura',
        ModuleType.writing => 'Escritura',
        ModuleType.math    => 'Matemáticas',
      };
 
  IconData get icon => switch (this) {
        ModuleType.reading => Icons.chrome_reader_mode_outlined,
        ModuleType.writing => Icons.edit_note_rounded,
        ModuleType.math    => Icons.calculate_outlined,
      };
}

extension DifficultyLevelX on DifficultyLevel {
  String get label => switch (this) {
        DifficultyLevel.basic => 'Básico',
        DifficultyLevel.intermediate => 'Intermedio',
        DifficultyLevel.advanced => 'Avanzado',
      };

  Color get color => switch (this) {
        DifficultyLevel.basic => const Color(0xFF10B981),
        DifficultyLevel.intermediate => const Color(0xFFF59E0B),
        DifficultyLevel.advanced => const Color(0xFFEF4444),
      };

  /// Puntos base que otorga un ejercicio de este nivel.
  int get basePoints => switch (this) {
        DifficultyLevel.basic => 10,
        DifficultyLevel.intermediate => 20,
        DifficultyLevel.advanced => 30,
      };
}

extension ExerciseTypeX on ExerciseType {
  String get label => switch (this) {
        ExerciseType.multipleChoice => 'Selección múltiple',
        ExerciseType.fillInTheBlank => 'Completar el espacio',
        ExerciseType.trueOrFalse => 'Verdadero o falso',
        ExerciseType.ordering => 'Ordenar elementos',
      };
  IconData get icon => switch (this) {
        ExerciseType.multipleChoice => Icons.check_circle_outline_rounded,
        ExerciseType.fillInTheBlank => Icons.text_fields_rounded,
        ExerciseType.trueOrFalse    => Icons.thumbs_up_down_rounded,
        ExerciseType.ordering       => Icons.sort_rounded,
      };
}

// --- Entidades de dominio ---

/// Entidad de un módulo académico (Lectura o Escritura).
@immutable
class ModuleEntity {
  final String id;
  final String title;
  final String description;
  final ModuleType type;
  final int grade;
  final bool isActive;
  final int exerciseCount;
  final DateTime createdAt;

  const ModuleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.grade,
    this.isActive = true,
    this.exerciseCount = 0,
    required this.createdAt,
  });
}

/// Contiene el contenido y la lógica de corrección del ejercicio.
@immutable
class ExerciseEntity {
  final String id;
  final String moduleId;
  final String title;
  final String instructions;
  final ExerciseType type;
  final DifficultyLevel difficulty;
  final Subject subject;
  final bool isActive;
  final int studentAttempts;
  final int studentCorrectAttempts;

  /// Contenido específico del ejercicio según su tipo.
  /// Para multipleChoice: lista de opciones + índice de respuesta correcta.
  /// Para fillInTheBlank: texto con [BLANK] y respuesta correcta.
  /// Para trueOrFalse: afirmación + bool de respuesta.
  /// Para ordering: lista de elementos en orden correcto.
  final Map<String, dynamic> content;

  const ExerciseEntity({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.instructions,
    required this.type,
    required this.difficulty,
    required this.content,
    this.subject = Subject.spanish,
    this.isActive = true,
    this.studentAttempts = 0,
    this.studentCorrectAttempts = 0,
  });

  int get points => difficulty.basePoints;
}

@immutable
class ExerciseResult {
  final String exerciseId;
  final bool isCorrect;
  final int pointsEarned;
  final DateTime completedAt;
  final dynamic submittedAnswer;

  const ExerciseResult({
    required this.exerciseId,
    required this.isCorrect,
    required this.pointsEarned,
    required this.completedAt,
    this.submittedAnswer,
  });

  factory ExerciseResult.fromExercise({
    required ExerciseEntity exercise,
    required bool isCorrect,
    dynamic submittedAnswer,
    int? pointsEarned,
  }) => ExerciseResult(
    exerciseId: exercise.id,
    isCorrect: isCorrect,
    pointsEarned: pointsEarned ?? (isCorrect ? exercise.difficulty.basePoints : 0),
    completedAt: DateTime.now(),
    submittedAnswer: submittedAnswer,
  );

}

