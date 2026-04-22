import 'package:flutter/material.dart';

/// Entidad de un logro/badge que puede obtener un estudiante.
/// Los datos son mock porque el backend no tiene endpoint de logros aún.
@immutable
class AchievementEntity {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int pointsRequired;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.unlockedAt,
    required this.pointsRequired,
  });
}

/// Datos mock de logros mientras el backend los implementa.
/// Cuando exista el endpoint, reemplazar esta clase con un repositorio real.
abstract class AchievementsMockData {
  static List<AchievementEntity> forStudent({required int points}) {
    return [
      AchievementEntity(
        id: 'first_exercise',
        title: 'Primer paso',
        description: 'Completaste tu primer ejercicio',
        icon: Icons.star_rounded,
        color: const Color(0xFFF59E0B),
        isUnlocked: points >= 10,
        unlockedAt: points >= 10 ? DateTime(2026, 1, 15) : null,
        pointsRequired: 10,
      ),
      AchievementEntity(
        id: 'reader',
        title: 'Lector',
        description: 'Completaste 5 ejercicios de lectura',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF0D9488),
        isUnlocked: points >= 50,
        unlockedAt: points >= 50 ? DateTime(2026, 1, 20) : null,
        pointsRequired: 50,
      ),
      AchievementEntity(
        id: 'writer',
        title: 'Escritor',
        description: 'Completaste 5 ejercicios de escritura',
        icon: Icons.edit_rounded,
        color: const Color(0xFF8B5CF6),
        isUnlocked: points >= 100,
        unlockedAt: points >= 100 ? DateTime(2026, 2, 1) : null,
        pointsRequired: 100,
      ),
      AchievementEntity(
        id: 'mathematician',
        title: 'Matemático',
        description: 'Completaste 5 ejercicios de matemáticas',
        icon: Icons.calculate_rounded,
        color: const Color(0xFFF97316),
        isUnlocked: points >= 150,
        unlockedAt: points >= 150 ? DateTime(2026, 2, 10) : null,
        pointsRequired: 150,
      ),
      AchievementEntity(
        id: 'streak_3',
        title: 'En racha',
        description: '3 días seguidos practicando',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFEF4444),
        isUnlocked: points >= 200,
        unlockedAt: points >= 200 ? DateTime(2026, 2, 15) : null,
        pointsRequired: 200,
      ),
      AchievementEntity(
        id: 'perfect_score',
        title: 'Perfecto',
        description: 'Obtuviste 100% en un ejercicio',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFEC4899),
        isUnlocked: points >= 250,
        unlockedAt: points >= 250 ? DateTime(2026, 2, 20) : null,
        pointsRequired: 250,
      ),
      AchievementEntity(
        id: 'century',
        title: 'Centurión',
        description: 'Acumulaste 300 puntos',
        icon: Icons.military_tech_rounded,
        color: const Color(0xFF3B82F6),
        isUnlocked: points >= 300,
        unlockedAt: points >= 300 ? DateTime(2026, 3, 1) : null,
        pointsRequired: 300,
      ),
      AchievementEntity(
        id: 'explorer',
        title: 'Explorador',
        description: 'Intentaste los 3 tipos de materia',
        icon: Icons.explore_rounded,
        color: const Color(0xFF10B981),
        isUnlocked: points >= 400,
        unlockedAt: points >= 400 ? DateTime(2026, 3, 10) : null,
        pointsRequired: 400,
      ),
      AchievementEntity(
        id: 'champion',
        title: 'Campeón',
        description: 'Llegaste al top 3 del ranking',
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFF59E0B),
        isUnlocked: points >= 500,
        unlockedAt: points >= 500 ? DateTime(2026, 3, 15) : null,
        pointsRequired: 500,
      ),
      AchievementEntity(
        id: 'legend',
        title: 'Leyenda',
        description: 'Acumulaste 1000 puntos',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF8B5CF6),
        isUnlocked: points >= 1000,
        unlockedAt: null,
        pointsRequired: 1000,
      ),
    ];
  }
}
