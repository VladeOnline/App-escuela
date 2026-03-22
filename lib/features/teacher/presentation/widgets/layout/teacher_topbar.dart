import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../modals/change_password_modal.dart';
import '../modals/help_modal.dart';

/// Topbar del panel del docente.
///
/// Contiene: título de la sección activa | notificaciones (deshabilitado) |
/// ayuda (?) | menú de usuario (cerrar sesión, cambiar contraseña, foto).
///
/// No tiene estado propio de negocio — recibe callbacks del shell.
class TeacherTopbar extends StatelessWidget implements PreferredSizeWidget {
  const TeacherTopbar({
    super.key,
    required this.title,
    required this.teacherName,
    required this.onLogout,
  });

  final String title;
  final String teacherName;
  final VoidCallback onLogout;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Título de la sección activa
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),

          // Notificaciones (deshabilitado por ahora)
          _TopbarIconButton(
            icon: Icons.notifications_outlined,
            tooltip: 'Notificaciones (próximamente)',
            enabled: false,
            onTap: () {},
          ),

          const SizedBox(width: AppSpacing.xs),

          // Ayuda "?"
          _TopbarIconButton(
            icon: Icons.help_outline_rounded,
            tooltip: 'Ayuda',
            onTap: () => HelpModal.show(context),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Menú de usuario
          _UserMenuButton(
            teacherName: teacherName,
            onLogout: onLogout,
            onChangePassword: () => ChangePasswordModal.show(context),
            onChangePhoto: () => _onChangePhoto(context),
          ),
        ],
      ),
    );
  }

  void _onChangePhoto(BuildContext context) {
    // TODO(back): integrar con file picker + servicio de subida de imagen.
    // Por ahora solo muestra un snackbar informativo.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de cambio de foto próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─── Subwidgets privados ──────────────────────────────────────────────────────

class _TopbarIconButton extends StatelessWidget {
  const _TopbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: enabled ? onTap : null,
        icon: Icon(
          icon,
          size: 22,
          color: enabled ? AppColors.textSecondary : AppColors.textHint,
        ),
      ),
    );
  }
}

class _UserMenuButton extends StatelessWidget {
  const _UserMenuButton({
    required this.teacherName,
    required this.onLogout,
    required this.onChangePassword,
    required this.onChangePhoto,
  });

  final String teacherName;
  final VoidCallback onLogout;
  final VoidCallback onChangePassword;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_UserMenuAction>(
      tooltip: 'Opciones de usuario',
      offset: const Offset(0, 48),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.large),
      ),
      onSelected: (action) {
        switch (action) {
          case _UserMenuAction.changePassword:
            onChangePassword();
          case _UserMenuAction.changePhoto:
            onChangePhoto();
          case _UserMenuAction.logout:
            onLogout();
        }
      },
      itemBuilder: (_) => [
        // Cabecera informativa (no seleccionable)
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/buho_profesor.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prof. $teacherName',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const Text(
                    'Docente',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        _menuItem(
          value: _UserMenuAction.changePhoto,
          icon: Icons.photo_camera_outlined,
          label: 'Cambiar foto',
        ),
        _menuItem(
          value: _UserMenuAction.changePassword,
          icon: Icons.lock_outline_rounded,
          label: 'Cambiar contraseña',
        ),
        const PopupMenuDivider(),
        _menuItem(
          value: _UserMenuAction.logout,
          icon: Icons.logout_rounded,
          label: 'Cerrar sesión',
          color: AppColors.error,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.all(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/buho_profesor.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_UserMenuAction> _menuItem({
    required _UserMenuAction value,
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final itemColor = color ?? AppColors.textSecondary;
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: itemColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: itemColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}

enum _UserMenuAction { changePassword, changePhoto, logout }
