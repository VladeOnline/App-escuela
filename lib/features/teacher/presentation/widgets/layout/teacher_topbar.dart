import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../modals/change_password_modal.dart';
import '../modals/help_modal.dart';

class TeacherTopbar extends StatelessWidget implements PreferredSizeWidget {
  const TeacherTopbar({
    super.key,
    required this.teacherName,
    required this.onLogout,
    required this.onChangePhoto,
  });

  final String teacherName;
  final VoidCallback onLogout;
  final VoidCallback onChangePhoto;

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
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(AppRadius.medium),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Sistema de Refuerzo Escolar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          _TopbarIconButton(icon: Icons.notifications_outlined, tooltip: 'Notificaciones (próximamente)', enabled: false, onTap: () {}),
          const SizedBox(width: AppSpacing.xs),
          _TopbarIconButton(icon: Icons.help_outline_rounded, tooltip: 'Ayuda', onTap: () => HelpModal.show(context)),
          const SizedBox(width: AppSpacing.sm),
          _UserMenuButton(
            teacherName: teacherName,
            onLogout: onLogout,
            onChangePassword: () => ChangePasswordModal.show(context),
            onChangePhoto: onChangePhoto,
          ),
        ],
      ),
    );
  }
}

class _TopbarIconButton extends StatelessWidget {
  const _TopbarIconButton({required this.icon, required this.tooltip, required this.onTap, this.enabled = true});
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: IconButton(
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 22, color: enabled ? AppColors.textSecondary : AppColors.textHint),
        ),
      );
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
      color: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.large),
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: (action) => switch (action) {
        _UserMenuAction.changePassword => onChangePassword(),
        _UserMenuAction.changePhoto    => onChangePhoto(),
        _UserMenuAction.logout         => onLogout(),
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                // TODO(back): reemplazar con la imagen de perfil real del docente desde la BD.
                child: ClipOval(child: Image.asset('assets/images/buho_profesor.png', fit: BoxFit.cover)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prof. $teacherName', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Nunito')),
                  const Text('Docente', style: TextStyle(color: AppColors.textHint, fontSize: 11, fontFamily: 'Nunito')),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        _menuItem(_UserMenuAction.changePhoto, Icons.photo_camera_outlined, 'Cambiar foto'),
        _menuItem(_UserMenuAction.changePassword, Icons.lock_outline_rounded, 'Cambiar contraseña'),
        const PopupMenuDivider(),
        _menuItem(_UserMenuAction.logout, Icons.logout_rounded, 'Cerrar sesión', color: AppColors.error),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.all(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28, height: 28,
              // TODO(back): reemplazar con la imagen de perfil real del docente desde la BD.
              child: ClipOval(child: Image.asset('assets/images/buho_profesor.png', fit: BoxFit.cover)),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<_UserMenuAction> _menuItem(_UserMenuAction value, IconData icon, String label, {Color? color}) {
    final c = color ?? AppColors.textSecondary;
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Nunito')),
        ],
      ),
    );
  }
}

enum _UserMenuAction { changePassword, changePhoto, logout }