import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Badge visual que representa el grado de un estudiante.
/// Usa el color único de cada grado definido en AppColors.
class GradeBadge extends StatelessWidget {
  const GradeBadge({
    super.key,
    required this.grade,
    this.size = GradeBadgeSize.medium,
  });

  final int grade;
  final GradeBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGrade(grade);
    final label = AppConstants.gradeLabels[grade] ?? '$grade° grado';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == GradeBadgeSize.small ? 8 : 12,
        vertical: size == GradeBadgeSize.small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        size == GradeBadgeSize.small ? '$grade°' : label,
        style: TextStyle(
          color: color,
          fontSize: size == GradeBadgeSize.small ? 11 : 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

enum GradeBadgeSize { small, medium }

/// Avatar circular con iniciales del estudiante.
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    required this.initials,
    required this.grade,
    this.radius = 24,
  });

  final String initials;
  final int grade;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGrade(grade);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.15),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w800,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}
