import 'package:flutter/material.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

/// Tipo de módulo académico disponible en el sistema.
enum ModuleType { reading, writing }

/// Nivel de dificultad de un ejercicio (RF-11).
enum DifficultyLevel { basic, intermediate, advanced }

/// Tipo de ejercicio (define qué widget de ejercicio se renderiza).
enum ExerciseType {
  multipleChoice,   // Selección múltiple
  fillInTheBlank,   // Completar el espacio
  trueOrFalse,      // Verdadero o falso
  ordering,         // Ordenar elementos
}

// ─── Extensiones de conveniencia ─────────────────────────────────────────────

extension ModuleTypeX on ModuleType {
  String get label => switch (this) {
        ModuleType.reading => 'Lectura',
        ModuleType.writing => 'Escritura',
      };

  IconData get icon => switch (this) {
        ModuleType.reading => Icons.chrome_reader_mode_outlined,
        ModuleType.writing => Icons.edit_note_rounded,
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

  /// Puntos base que otorga un ejercicio de este nivel (RF-20).
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
}

// ─── Entidades de dominio ─────────────────────────────────────────────────────

/// Entidad de un módulo académico (Lectura o Escritura).
/// Agrupa ejercicios de una materia específica por grado (RF-07, RF-08).
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

/// Entidad de un ejercicio interactivo (RF-09, RF-11, RF-12).
/// Contiene el contenido y la lógica de corrección del ejercicio.
@immutable
class ExerciseEntity {
  final String id;
  final String moduleId;
  final String title;
  final String instructions;
  final ExerciseType type;
  final DifficultyLevel difficulty;
  final bool isActive;

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
    this.isActive = true,
  });

  /// Puntos que otorga este ejercicio al completarlo correctamente.
  int get points => difficulty.basePoints;
}

/// Resultado de un intento de ejercicio (RF-13, RF-14, RF-35).
@immutable
class ExerciseResult {
  final String exerciseId;
  final bool isCorrect;
  final int pointsEarned;
  final DateTime completedAt;

  const ExerciseResult({
    required this.exerciseId,
    required this.isCorrect,
    required this.pointsEarned,
    required this.completedAt,
  });
}
