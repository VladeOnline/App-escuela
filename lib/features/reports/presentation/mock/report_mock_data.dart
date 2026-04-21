import 'package:flutter/material.dart';

import '../../domain/entities/individual_report_entity.dart';
import '../../domain/entities/report_result_entity.dart';

// ── Colores de materia — coinciden con Subject.color del módulo ejercicios ────
abstract class SubjectColors {
  static const spanish       = Color(0xFFEF4444);
  static const socialStudies = Color(0xFF2563EB);
  static const civics        = Color(0xFF38BDF8);
  static const math          = Color(0xFFF59E0B);
  static const science       = Color(0xFF10B981);

  static Color forName(String name) => switch (name) {
        'Español'        => spanish,
        'Est. Sociales'  => socialStudies,
        'Cívica'         => civics,
        'Matemáticas'    => math,
        'Ciencias'       => science,
        _                => const Color(0xFF94A3B8),
      };
}

/// Datos quemados para desarrollo.
/// TODO(back): reemplazar con IndividualReportNotifier cuando el endpoint esté listo.
abstract class ReportMockData {
  // ── Materias con doble barra ──────────────────────────────────────────────
  static const List<SubjectPerformance> subjectPerformance = [
    SubjectPerformance(name: 'Español',       color: SubjectColors.spanish,       reading: 78, writing: 60),
    SubjectPerformance(name: 'Est. Sociales', color: SubjectColors.socialStudies, reading: 88, writing: 80),
    SubjectPerformance(name: 'Cívica',        color: SubjectColors.civics,        reading: 70, writing: 55),
    SubjectPerformance(name: 'Ciencias',      color: SubjectColors.science,       reading: 65, writing: 50),
    SubjectPerformance(name: 'Matemáticas',   color: SubjectColors.math,          reading: 68, writing: 72),
  ];

  // ── Evolución del promedio ────────────────────────────────────────────────
  static const List<WeekPoint> progressHistory = [
    WeekPoint(week: 'Sem 1', value: 55),
    WeekPoint(week: 'Sem 2', value: 60),
    WeekPoint(week: 'Sem 3', value: 58),
    WeekPoint(week: 'Sem 4', value: 65),
    WeekPoint(week: 'Sem 5', value: 70),
    WeekPoint(week: 'Sem 6', value: 73),
  ];

  // ── Reporte individual ────────────────────────────────────────────────────
  static IndividualReportEntity get individualReport => IndividualReportEntity(
        estudianteId: 's1',
        estudianteNombre: 'Amy Morales',
        estudianteGrado: 1,
        totalEvaluaciones: 8,
        promedio: 73,
        resultados: _mockResults,
      );

  static final List<ReportResultEntity> _mockResults = [
    ReportResultEntity(
      id: 'r1', estudianteId: 's1', evaluacionId: 'e1',
      evaluacionTitulo: 'Países', materia: 'Est. Sociales',
      puntuacion: 92, fecha: DateTime(2026, 4, 8), aprobado: true, intentos: 1,
    ),
    ReportResultEntity(
      id: 'r2', estudianteId: 's1', evaluacionId: 'e2',
      evaluacionTitulo: 'Sumas y restas', materia: 'Matemáticas',
      puntuacion: 42, fecha: DateTime(2026, 4, 5), aprobado: false, intentos: 2,
    ),
    ReportResultEntity(
      id: 'r3', estudianteId: 's1', evaluacionId: 'e3',
      evaluacionTitulo: 'Letras', materia: 'Español',
      puntuacion: 68, fecha: DateTime(2026, 4, 1), aprobado: true, intentos: 1,
    ),
    ReportResultEntity(
      id: 'r4', estudianteId: 's1', evaluacionId: 'e4',
      evaluacionTitulo: 'Seres vivos', materia: 'Ciencias',
      puntuacion: 85, fecha: DateTime(2026, 3, 28), aprobado: true, intentos: 1,
    ),
    ReportResultEntity(
      id: 'r5', estudianteId: 's1', evaluacionId: 'e5',
      evaluacionTitulo: 'Símbolos patrios', materia: 'Cívica',
      puntuacion: 74, fecha: DateTime(2026, 3, 20), aprobado: true, intentos: 1,
    ),
  ];

  // ── Gamificación — xpPoints debe coincidir con lo que muestra ReportStatCards
  static const int xpPoints    = 340;
  static const int ranking     = 2;
  static const String levelName = 'Explorador';

  static const List<BadgeData> badges = [
    BadgeData(icon: Icons.star_rounded,                  label: 'Lector Estrella', color: Color(0xFFF59E0B)),
    BadgeData(icon: Icons.local_fire_department_rounded, label: 'Racha 5 días',    color: Color(0xFFEF4444)),
  ];
}

// ── Value objects de presentación ─────────────────────────────────────────────

class SubjectPerformance {
  final String name;
  final Color  color;
  final int    reading; // barra superior (sólida)
  final int    writing; // barra inferior (punteada)
  const SubjectPerformance({
    required this.name,
    required this.color,
    required this.reading,
    required this.writing,
  });
}

class WeekPoint {
  final String week;
  final int    value;
  const WeekPoint({required this.week, required this.value});
}

class BadgeData {
  final IconData icon;
  final String   label;
  final Color    color;
  const BadgeData({required this.icon, required this.label, required this.color});
}