import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

// --- Modelos ---

class NavItem {
  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.index,
    this.children = const [],
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? index;
  final List<NavSubItem> children;
  bool get hasChildren => children.isNotEmpty;
}

class NavSubItem {
  const NavSubItem({
    required this.icon,
    required this.label,
    required this.index,
  });
  final IconData icon;
  final String label;
  final int index;
}

// --- Sidebar ---

class TeacherSidebar extends StatefulWidget {
  const TeacherSidebar({
    super.key,
    required this.selectedIndex,
    required this.teacherName,
    required this.teacherPhotoUrl,
    required this.onSelectIndex,
    required this.onLogout,
  });
  final int selectedIndex;
  final String teacherName;
  final String? teacherPhotoUrl;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onLogout;

  static const double expandedWidth = 260;
  static const double collapsedWidth = 72;

  @override
  State<TeacherSidebar> createState() => _TeacherSidebarState();
}

class _TeacherSidebarState extends State<TeacherSidebar> {
  bool _collapsed = false;
  String? _expandedGroup;

  static const _navItems = [
    NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Inicio', index: 0),
    NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Módulos',
      children: [
        NavSubItem(icon: Icons.chrome_reader_mode_outlined, label: 'Lectura', index: 1),
        NavSubItem(icon: Icons.edit_note_rounded, label: 'Escritura', index: 2),
        NavSubItem(icon: Icons.calculate_outlined, label: 'Matemáticas',  index: 3), 
      ],
    ),
    NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart_rounded, label: 'Reportes', index: 4),
    NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Ajustes', index: 5),
  ];

  void _toggleCollapse() => setState(() {
        _collapsed = !_collapsed;
        if (_collapsed) _expandedGroup = null;
      });

  void _toggleGroup(String label) => setState(() {
        if (_collapsed) {
          _collapsed = false;
          _expandedGroup = label;
        } else {
          _expandedGroup = _expandedGroup == label ? null : label;
        }
      });

  bool _isGroupActive(NavItem item) =>
      item.children.any((s) => s.index == widget.selectedIndex);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: _collapsed ? TeacherSidebar.collapsedWidth : TeacherSidebar.expandedWidth,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _TeacherAvatarHeader(
            teacherName: widget.teacherName,
            teacherPhotoUrl: widget.teacherPhotoUrl,
            collapsed: _collapsed,
            onToggle: _toggleCollapse,
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              children: _navItems.map((item) {
                if (item.hasChildren) {
                  return _GroupNavItem(
                    item: item,
                    collapsed: _collapsed,
                    isExpanded: _expandedGroup == item.label,
                    isGroupActive: _isGroupActive(item),
                    selectedIndex: widget.selectedIndex,
                    onToggle: () => _toggleGroup(item.label),
                    onSelectIndex: widget.onSelectIndex,
                  );
                }
                return _SingleNavItem(
                  item: item,
                  collapsed: _collapsed,
                  isActive: widget.selectedIndex == item.index,
                  onTap: () => widget.onSelectIndex(item.index!),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _LogoutButton(collapsed: _collapsed, onLogout: widget.onLogout),
        ],
      ),
    );
  }
}

// --- Avatar header ---

// TODO(back): reemplazar [teacherName] con el nombre real desde AuthNotifier.state.
class _TeacherAvatarHeader extends StatelessWidget {
  const _TeacherAvatarHeader({
    required this.teacherName,
    required this.teacherPhotoUrl,
    required this.collapsed,
    required this.onToggle,
  });
  final String teacherName;
  final String? teacherPhotoUrl;
  final bool collapsed;
  final VoidCallback onToggle;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return '¡Buenos días,';
    if (h < 18) return '¡Buenas tardes,';
    return '¡Buenas noches,';
  }

  ImageProvider _resolvePhotoProvider(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const AssetImage('assets/images/buho_profesor.png');
    }

    final trimmed = value.trim();
    if (trimmed.startsWith('data:image/')) {
      final comma = trimmed.indexOf(',');
      if (comma > 0 && comma < trimmed.length - 1) {
        final dataPart = trimmed.substring(comma + 1);
        try {
          final bytes = base64Decode(dataPart);
          return MemoryImage(bytes);
        } catch (_) {
          return const AssetImage('assets/images/buho_profesor.png');
        }
      }
    }

    return NetworkImage(trimmed);
  }

  Widget _avatar(double size) {
    final photoProvider = _resolvePhotoProvider(teacherPhotoUrl);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Image(
          image: photoProvider,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Image.asset(
            'assets/images/buho_profesor.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _collapseBtn({required bool expanded}) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: onToggle,
          tooltip: expanded ? 'Colapsar menú' : 'Expandir menú',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: AnimatedRotation(
            turns: expanded ? 0 : 0.5,
            duration: const Duration(milliseconds: 220),
            child: const Icon(Icons.chevron_left_rounded, color: AppColors.textHint, size: 22),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Column(
        children: [
          SizedBox(height: 36, child: Center(child: _collapseBtn(expanded: false))),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(child: _avatar(50)),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.xs, AppSpacing.md),
      child: Row(
        children: [
          _avatar(64),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5, color: AppColors.textHint)),
                const SizedBox(height: 2),
                Text(
                  'Prof. $teacherName!',
                  // TODO(back): reemplazar con el nombre real desde AuthNotifier.state.
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _collapseBtn(expanded: true),
        ],
      ),
    );
  }
}

// --- Nav items ---

class _SingleNavItem extends StatelessWidget {
  const _SingleNavItem({required this.item, required this.collapsed, required this.isActive, required this.onTap});
  final NavItem item;
  final bool collapsed;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? item.label : '',
      preferBelow: false,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          borderRadius: const BorderRadius.all(AppRadius.medium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: collapsed ? AppSpacing.sm : 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withValues(alpha: 0.10) : Colors.transparent,
              borderRadius: const BorderRadius.all(AppRadius.medium),
            ),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(isActive ? item.activeIcon : item.icon, color: isActive ? AppColors.primary : AppColors.textHint, size: 20),
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(item.label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textSecondary, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, fontSize: 14, fontFamily: 'Nunito')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupNavItem extends StatelessWidget {
  const _GroupNavItem({
    required this.item,
    required this.collapsed,
    required this.isExpanded,
    required this.isGroupActive,
    required this.selectedIndex,
    required this.onToggle,
    required this.onSelectIndex,
  });
  final NavItem item;
  final bool collapsed;
  final bool isExpanded;
  final bool isGroupActive;
  final int selectedIndex;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelectIndex;

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Tooltip(
        message: item.label,
        preferBelow: false,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.all(AppRadius.medium),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
              child: Center(child: Icon(isGroupActive ? item.activeIcon : item.icon, color: isGroupActive ? AppColors.primary : AppColors.textHint, size: 20)),
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: onToggle,
            borderRadius: const BorderRadius.all(AppRadius.medium),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10),
              decoration: BoxDecoration(
                color: isGroupActive ? AppColors.primary.withValues(alpha: 0.10) : Colors.transparent,
                borderRadius: const BorderRadius.all(AppRadius.medium),
              ),
              child: Row(
                children: [
                  Icon(isGroupActive ? item.activeIcon : item.icon, color: isGroupActive ? AppColors.primary : AppColors.textHint, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(item.label, style: TextStyle(color: isGroupActive ? AppColors.primary : AppColors.textSecondary, fontWeight: isGroupActive ? FontWeight.w700 : FontWeight.w500, fontSize: 14, fontFamily: 'Nunito'))),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: isGroupActive ? AppColors.primary : AppColors.textHint, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _SubItemList(children: item.children, selectedIndex: selectedIndex, onSelectIndex: onSelectIndex),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _SubItemList extends StatelessWidget {
  const _SubItemList({required this.children, required this.selectedIndex, required this.onSelectIndex});
  final List<NavSubItem> children;
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.xs),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 12, child: CustomPaint(painter: _BranchLinePainter(color: AppColors.primary.withValues(alpha: 0.55)))),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                children: children.map((sub) {
                  final isActive = selectedIndex == sub.index;
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: () => onSelectIndex(sub.index),
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: const BorderRadius.all(AppRadius.medium),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 9),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: const BorderRadius.all(AppRadius.medium),
                        ),
                        child: Row(
                          children: [
                            Icon(sub.icon, color: isActive ? AppColors.primary : AppColors.textHint, size: 16),
                            const SizedBox(width: AppSpacing.sm),
                            Text(sub.label, style: TextStyle(color: isActive ? AppColors.primary : AppColors.textSecondary, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, fontSize: 13, fontFamily: 'Nunito')),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Painter ---

class _BranchLinePainter extends CustomPainter {
  const _BranchLinePainter({required this.color});
  final Color color;
  static const double _d = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.fill;
    final cx = size.width / 2;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 1, 7.0, 2, size.height * 0.58), const Radius.circular(2)), paint);
    final dt = size.height - _d * 4;
    canvas.drawPath(Path()..moveTo(cx, dt)..lineTo(cx + _d, dt + _d)..lineTo(cx, dt + _d * 2)..lineTo(cx - _d, dt + _d)..close(), paint);
  }

  @override
  bool shouldRepaint(_BranchLinePainter old) => old.color != color;
}

// --- Logout ---

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.collapsed, required this.onLogout});
  final bool collapsed;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? 'Cerrar sesión' : '',
      preferBelow: false,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onLogout,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                if (!collapsed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text('Cerrar sesión', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Nunito')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}






