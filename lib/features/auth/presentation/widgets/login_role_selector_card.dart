import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Panel de selección de rol
class LoginRoleSelectorCard extends StatelessWidget {
  const LoginRoleSelectorCard({super.key, required this.onRoleSelected});
  final ValueChanged<String> onRoleSelected;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return '¡Buenos días usuario 🌞!';
    if (hour >= 12 && hour < 19) return '¡Buenas tardes usuario ⛅!';
    return '¡Buenas noches usuario 🌛!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.xl),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.12),
            blurRadius: 60, spreadRadius: -4, offset: const Offset(0, 20)),
          BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 24, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(AppRadius.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SelectorHeader(greeting: _greeting),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl + 8,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _RoleCard(
                      role: AppConstants.roleTeacher,
                      imagePath: 'assets/images/buho_profesor.png',
                      title: 'Profesor',
                      subtitle: '¿Listo para enseñar?',
                      onTap: () => onRoleSelected(AppConstants.roleTeacher),
                    )),
                    const _Divider(),
                    Expanded(child: _RoleCard(
                      role: AppConstants.roleStudent,
                      imagePath: 'assets/images/buho_alumno.png',
                      title: 'Alumno',
                      subtitle: '¿Listo para aprender?',
                      onTap: () => onRoleSelected(AppConstants.roleStudent),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───

class _SelectorHeader extends StatelessWidget {
  const _SelectorHeader({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.xl + 8, AppSpacing.xl, AppSpacing.xl + 4,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -45, right: -55,
            child: Container(width: 110, height: 110,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08)))),
          Positioned(top: -15, left: -5,
            child: Container(width: 50, height: 50,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                color: Colors.transparent))),
          Positioned(bottom: -20, right: -10,
            child: Container(width: 70, height: 70,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1)))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, fontFamily: 'Nunito',
                  color: Colors.white, fontWeight: FontWeight.w800, height: 1.1)),
              const SizedBox(height: AppSpacing.xs),
              Text('¿Con quién ingresamos hoy?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontFamily: 'Nunito',
                  color: Colors.white.withOpacity(0.85))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Separador central ───

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Línea superior degradada
          Container(
            width: 1.5, height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.primary.withOpacity(0.3)],
              ),
            ),
          ),
          // Rombo decorativo central
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
            ),
            transform: Matrix4.rotationZ(0.785),
            transformAlignment: Alignment.center,
          ),
          // Línea inferior degradada
          Container(
            width: 1.5, height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [AppColors.primary.withOpacity(0.3), Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card individual de rol ───

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role, required this.imagePath,
    required this.title, required this.subtitle, required this.onTap,
  });
  final String role, imagePath, title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 253, 255, 255),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.primary.withOpacity(0.10), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Avatar búho
              Transform.translate(
                offset: const Offset(0, -15),
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.12),
                        blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18), width: 2.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath, fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.3),
                      errorBuilder: (_, __, ___) => Icon(
                        role == AppConstants.roleTeacher
                            ? Icons.person_rounded : Icons.face_rounded,
                        color: AppColors.primary, size: 44,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),
              Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito', color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, fontFamily: 'Nunito',
                  color: AppColors.textSecondary, height: 1.4)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SelectButton(onTap: onTap),
        ],
      ),
    );
  }
}

// ─── Botón de seleccionar ───

class _SelectButton extends StatefulWidget {
  const _SelectButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SelectButton> createState() => _SelectButtonState();
}

class _SelectButtonState extends State<_SelectButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primaryDark.withOpacity(0.85)
                : AppColors.primary,
            borderRadius: const BorderRadius.all(AppRadius.medium),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: const Text('Seleccionar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
              fontFamily: 'Nunito', color: Colors.white)),
        ),
      ),
    );
  }
}