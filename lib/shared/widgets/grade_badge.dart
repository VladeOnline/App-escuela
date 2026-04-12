import 'dart:convert';

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
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

/// Avatar circular del estudiante. Si hay foto, la muestra; si no, usa iniciales.
class StudentAvatar extends StatelessWidget {
  const StudentAvatar({
    super.key,
    required this.initials,
    required this.grade,
    this.radius = 24,
    this.photoUrl,
  });

  final String initials;
  final int grade;
  final double radius;
  final String? photoUrl;

  ImageProvider? _resolvePhotoProvider(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final trimmed = value.trim();
    if (trimmed.startsWith('data:image/')) {
      final comma = trimmed.indexOf(',');
      if (comma > 0 && comma < trimmed.length - 1) {
        try {
          return MemoryImage(base64Decode(trimmed.substring(comma + 1)));
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return NetworkImage(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGrade(grade);
    final provider = _resolvePhotoProvider(photoUrl);

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      backgroundImage: provider,
      child: provider == null
          ? Text(
              initials,
              style: TextStyle(
                color: color,
                fontSize: radius * 0.65,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
              ),
            )
          : null,
    );
  }
}
