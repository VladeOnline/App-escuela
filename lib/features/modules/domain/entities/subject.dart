import 'package:flutter/material.dart';

/// Materias académicas que puede tener un ejercicio.
///
/// Cada materia tiene un color asociado para usarse como etiqueta visual
/// dentro de las cards de ejercicios (RF-08).
enum Subject {
  spanish,
  socialStudies,
  civics,
  math,
  science,
}

extension SubjectX on Subject {
  String get label => switch (this) {
        Subject.spanish => 'Español',
        Subject.socialStudies => 'Estudios Sociales',
        Subject.civics => 'Cívica',
        Subject.math => 'Matemática',
        Subject.science => 'Ciencias',
      };

  /// Versión corta para chips compactos.
  String get shortLabel => switch (this) {
        Subject.spanish => 'Español',
        Subject.socialStudies => 'E. Sociales',
        Subject.civics => 'Cívica',
        Subject.math => 'Mate',
        Subject.science => 'Ciencias',
      };

  /// Color primario de la etiqueta de materia.
  Color get color => switch (this) {
        Subject.spanish => const Color(0xFFEF4444), // Rojo
        Subject.socialStudies => const Color(0xFF2563EB), // Azul
        Subject.civics => const Color(0xFF38BDF8), // Celeste
        Subject.math => const Color(0xFFF59E0B), // Amarillo
        Subject.science => const Color(0xFF10B981), // Verde
      };

  IconData get icon => switch (this) {
        Subject.spanish => Icons.menu_book_rounded,
        Subject.socialStudies => Icons.public_rounded,
        Subject.civics => Icons.account_balance_rounded,
        Subject.math => Icons.calculate_rounded,
        Subject.science => Icons.science_rounded,
      };
}
