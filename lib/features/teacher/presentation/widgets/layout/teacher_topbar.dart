import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../features/auth/presentation/auth_notifier.dart';
import '../modals/change_password_modal.dart';
import '../modals/help_modal.dart';

class TeacherTopbar extends StatelessWidget implements PreferredSizeWidget {
  const TeacherTopbar({
    super.key,
    required this.teacherName,
    this.teacherPhotoUrl,
    required this.onLogout,
  });

  final String teacherName;
  final String? teacherPhotoUrl;
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
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(AppRadius.medium),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 18,
            ),
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
          _TopbarIconButton(
            icon: Icons.notifications_outlined,
            tooltip: 'Notificaciones (proximamente)',
            enabled: false,
            onTap: () {},
          ),
          const SizedBox(width: AppSpacing.xs),
          _TopbarIconButton(
            icon: Icons.help_outline_rounded,
            tooltip: 'Ayuda',
            onTap: () => HelpModal.show(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          _UserMenuButton(
            teacherName: teacherName,
            teacherPhotoUrl: teacherPhotoUrl,
            onLogout: onLogout,
            onChangePassword: () => ChangePasswordModal.show(context),
            onChangePhoto: () => _pickAndUploadPhoto(context),
            onRemovePhoto: () => _removeProfilePhoto(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (!context.mounted) return;

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo leer el archivo seleccionado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (bytes.length > 2 * 1024 * 1024) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('La imagen debe pesar maximo 2 MB.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final mime = _mimeFromFileName(file.name);
    final encoded = base64Encode(bytes);
    final dataUrl = 'data:$mime;base64,$encoded';

    final authNotifier = context.read<AuthNotifier>();
    final ok = await authNotifier.updateProfilePhoto(dataUrl);
    if (!context.mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil actualizada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          authNotifier.state.failure?.message ??
              'No se pudo actualizar la foto.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _mimeFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _removeProfilePhoto(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final authNotifier = context.read<AuthNotifier>();

    final ok = await authNotifier.removeProfilePhoto();
    if (!context.mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil eliminada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          authNotifier.state.failure?.message ??
              'No se pudo eliminar la foto de perfil.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

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
    required this.teacherPhotoUrl,
    required this.onLogout,
    required this.onChangePassword,
    required this.onChangePhoto,
    required this.onRemovePhoto,
  });

  final String teacherName;
  final String? teacherPhotoUrl;
  final VoidCallback onLogout;
  final VoidCallback onChangePassword;
  final VoidCallback onChangePhoto;
  final VoidCallback onRemovePhoto;
  static final Map<String, ImageProvider> _photoProviderCache = {};

  ImageProvider _resolvePhotoProvider(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const AssetImage('assets/images/buho_profesor.png');
    }
    final trimmed = value.trim();
    final cached = _photoProviderCache[trimmed];
    if (cached != null) return cached;

    if (trimmed.startsWith('data:image/')) {
      final comma = trimmed.indexOf(',');
      if (comma > 0 && comma < trimmed.length - 1) {
        try {
          final bytes = base64Decode(trimmed.substring(comma + 1));
          final provider = MemoryImage(bytes);
          _photoProviderCache[trimmed] = provider;
          return provider;
        } catch (_) {
          return const AssetImage('assets/images/buho_profesor.png');
        }
      }
    }
    final provider = NetworkImage(trimmed);
    _photoProviderCache[trimmed] = provider;
    return provider;
  }

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
      onSelected: (action) {
        switch (action) {
          case _UserMenuAction.changePhoto:
            onChangePhoto();
            break;
          case _UserMenuAction.removePhoto:
            onRemovePhoto();
            break;
          case _UserMenuAction.changePassword:
            onChangePassword();
            break;
          case _UserMenuAction.logout:
            onLogout();
            break;
        }
      },
      itemBuilder: (_) => [
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
                  child: Image(
                    image: _resolvePhotoProvider(teacherPhotoUrl),
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/buho_profesor.png',
                      fit: BoxFit.cover,
                    ),
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
          _UserMenuAction.changePhoto,
          Icons.photo_camera_outlined,
          'Cambiar foto',
        ),
        _menuItem(
          _UserMenuAction.removePhoto,
          Icons.delete_outline_rounded,
          'Quitar foto',
          color: AppColors.error,
        ),
        _menuItem(
          _UserMenuAction.changePassword,
          Icons.lock_outline_rounded,
          'Cambiar contrasena',
        ),
        const PopupMenuDivider(),
        _menuItem(
          _UserMenuAction.logout,
          Icons.logout_rounded,
          'Cerrar sesion',
          color: AppColors.error,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.all(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: ClipOval(
                child: Image(
                  image: _resolvePhotoProvider(teacherPhotoUrl),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/buho_profesor.png',
                    fit: BoxFit.cover,
                  ),
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

  PopupMenuItem<_UserMenuAction> _menuItem(
    _UserMenuAction value,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final textColor = color ?? AppColors.textSecondary;
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: textColor,
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

enum _UserMenuAction { changePhoto, removePhoto, changePassword, logout }
