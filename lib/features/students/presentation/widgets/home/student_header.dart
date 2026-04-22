import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({
    super.key,
    required this.greeting,
    required this.name,
    required this.grade,
    required this.points,
    required this.photoUrl,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onLogout,
  });

  final String greeting;
  final String name;
  final int grade;
  final int points;
  final String? photoUrl;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  static String _gradeLabel(int grade) {
    const labels = {
      1: 'Primer grado',
      2: 'Segundo grado',
      3: 'Tercer grado',
      4: 'Cuarto grado',
      5: 'Quinto grado',
      6: 'Sexto grado',
    };
    return labels[grade] ?? 'Grado $grade';
  }

  ImageProvider _resolvePhotoProvider(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const AssetImage('assets/images/buho_alumno.png');
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('data:image/')) {
      final comma = trimmed.indexOf(',');
      if (comma > 0 && comma < trimmed.length - 1) {
        try {
          return MemoryImage(base64Decode(trimmed.substring(comma + 1)));
        } catch (_) {
          return const AssetImage('assets/images/buho_alumno.png');
        }
      }
    }
    return NetworkImage(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              left: 60,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  _Avatar(provider: _resolvePhotoProvider(photoUrl)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _GreetingText(greeting: greeting, name: name),
                  ),
                  _HeaderPill(
                    icon: Icons.school_rounded,
                    label: _gradeLabel(grade),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _HeaderPill(
                    icon: Icons.stars_rounded,
                    label: '$points pts',
                    iconColor: AppColors.secondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _HeaderIconButton(
                    tooltip: isRefreshing ? 'Actualizando...' : 'Actualizar',
                    onTap: isRefreshing ? null : onRefresh,
                    child: isRefreshing
                        ? const Padding(
                            padding: EdgeInsets.all(11),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _HeaderIconButton(
                    tooltip: 'Salir',
                    onTap: onLogout,
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Subwidgets privados del header ---

class _Avatar extends StatelessWidget {
  const _Avatar({required this.provider});
  final ImageProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: Image(
          image: provider,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.3),
          errorBuilder: (_, _, _) => const Icon(
            Icons.face_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _GreetingText extends StatelessWidget {
  const _GreetingText({required this.greeting, required this.name});
  final String greeting;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡$greeting, $name!',
          style: const TextStyle(
            fontSize: 22,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '¿Listo/a para aprender hoy?',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Nunito',
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.onTap,
    required this.child,
  });

  final String tooltip;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.all(AppRadius.medium),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}