import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

// ─── Modelo de ítem de navegación ────────────────────────────────────────────

/// Representa una entrada del menú lateral.
/// Puede tener subitems (submenu desplegable).
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

  /// null si el ítem tiene subitems (es un grupo, no una página).
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

// ─── Sidebar ──────────────────────────────────────────────────────────────────

/// Sidebar colapsable del panel docente.
///
/// Estado de colapso: [ValueNotifier<bool>] local porque es estado
/// puramente de UI (no afecta al negocio ni a otros widgets).
/// Regla: si el estado no cruza el árbol de widgets ni tiene lógica
/// de negocio → queda en el widget, no en un Notifier global.
class TeacherSidebar extends StatefulWidget {
  const TeacherSidebar({
    super.key,
    required this.selectedIndex,
    required this.teacherName,
    required this.onSelectIndex,
    required this.onLogout,
  });

  final int selectedIndex;
  final String teacherName;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onLogout;

  /// Ancho cuando está expandido.
  static const double expandedWidth = 220;

  /// Ancho cuando está colapsado (solo íconos).
  static const double collapsedWidth = 68;

  @override
  State<TeacherSidebar> createState() => _TeacherSidebarState();
}

class _TeacherSidebarState extends State<TeacherSidebar> {
  /// Estado de colapso — local porque es puramente UI.
  bool _collapsed = false;

  /// Qué grupo de subitems está expandido (por label del NavItem padre).
  String? _expandedGroup;

  static const _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Inicio',
      index: 0,
    ),
    NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Módulos',
      children: [
        NavSubItem(
          icon: Icons.chrome_reader_mode_outlined,
          label: 'Lectura',
          index: 1,
        ),
        NavSubItem(
          icon: Icons.edit_note_rounded,
          label: 'Escritura',
          index: 2,
        ),
      ],
    ),
    NavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Reportes',
      index: 3,
    ),
    NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Ajustes',
      index: 4,
    ),
  ];

  void _toggleCollapse() => setState(() {
        _collapsed = !_collapsed;
        // Al colapsar cerramos cualquier submenu abierto.
        if (_collapsed) _expandedGroup = null;
      });

  void _toggleGroup(String label) => setState(() {
        _expandedGroup = _expandedGroup == label ? null : label;
      });

  bool _isGroupActive(NavItem item) {
    return item.children.any((sub) => sub.index == widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final width =
        _collapsed ? TeacherSidebar.collapsedWidth : TeacherSidebar.expandedWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // ── Header: logo + botón de colapso ──
          _SidebarHeader(
            collapsed: _collapsed,
            onToggle: _toggleCollapse,
          ),

          // ── Saludo + avatar ──
          if (!_collapsed)
            _TeacherGreeting(teacherName: widget.teacherName),

          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.sm),

          // ── Navegación ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
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

          // ── Botón de cerrar sesión ──
          _LogoutButton(
            collapsed: _collapsed,
            onLogout: widget.onLogout,
          ),
        ],
      ),
    );
  }
}

// ─── Header con logo y toggle ─────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({
    required this.collapsed,
    required this.onToggle,
  });

  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          // Logo de la app
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(AppRadius.medium),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
          ),
          if (!collapsed) ...[
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Refuerzo Escolar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
          // Botón de colapso
          IconButton(
            onPressed: onToggle,
            tooltip: collapsed ? 'Expandir menú' : 'Colapsar menú',
            icon: AnimatedRotation(
              turns: collapsed ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textHint,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Saludo del docente ───────────────────────────────────────────────────────

class _TeacherGreeting extends StatelessWidget {
  const _TeacherGreeting({required this.teacherName});

  final String teacherName;

  /// Devuelve el saludo según la hora del día.
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días';
    if (hour < 18) return '¡Buenas tardes';
    return '¡Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Avatar del docente
          Container(
            width: 44,
            height: 44,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                      ),
                ),
                Text(
                  'Prof. $teacherName',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ítem de navegación simple ────────────────────────────────────────────────

class _SingleNavItem extends StatelessWidget {
  const _SingleNavItem({
    required this.item,
    required this.collapsed,
    required this.isActive,
    required this.onTap,
  });

  final NavItem item;
  final bool collapsed;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? item.label : '',
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.medium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: collapsed ? AppSpacing.sm : 10,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.10)
                : Colors.transparent,
            borderRadius: const BorderRadius.all(AppRadius.medium),
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppColors.primary : AppColors.textHint,
                size: 20,
              ),
              if (!collapsed) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ítem de grupo (con subitems desplegables) ────────────────────────────────

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
    // Cuando está colapsado, el grupo se muestra como un ícono simple
    // que expande el sidebar y luego muestra los subitems.
    if (collapsed) {
      return Tooltip(
        message: item.label,
        preferBelow: false,
        child: InkWell(
          onTap: onToggle,
          borderRadius: const BorderRadius.all(AppRadius.medium),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Icon(
              isGroupActive ? item.activeIcon : item.icon,
              color: isGroupActive ? AppColors.primary : AppColors.textHint,
              size: 20,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabecera del grupo
        InkWell(
          onTap: onToggle,
          borderRadius: const BorderRadius.all(AppRadius.medium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isGroupActive
                  ? AppColors.primary.withOpacity(0.10)
                  : Colors.transparent,
              borderRadius: const BorderRadius.all(AppRadius.medium),
            ),
            child: Row(
              children: [
                Icon(
                  isGroupActive ? item.activeIcon : item.icon,
                  color:
                      isGroupActive ? AppColors.primary : AppColors.textHint,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isGroupActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isGroupActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isGroupActive
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Subitems animados
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _SubItemList(
            children: item.children,
            selectedIndex: selectedIndex,
            onSelectIndex: onSelectIndex,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─── Lista de subitems ────────────────────────────────────────────────────────

class _SubItemList extends StatelessWidget {
  const _SubItemList({
    required this.children,
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  final List<NavSubItem> children;
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Indentación visual para indicar jerarquía.
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: Column(
        children: children.map((sub) {
          final isActive = selectedIndex == sub.index;
          return InkWell(
            onTap: () => onSelectIndex(sub.index),
            borderRadius: const BorderRadius.all(AppRadius.medium),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: const BorderRadius.all(AppRadius.medium),
              ),
              child: Row(
                children: [
                  Icon(
                    sub.icon,
                    color: isActive ? AppColors.primary : AppColors.textHint,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    sub.label,
                    style: TextStyle(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Botón de cerrar sesión ───────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.collapsed, required this.onLogout});

  final bool collapsed;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? 'Cerrar sesión' : '',
      preferBelow: false,
      child: InkWell(
        onTap: onLogout,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
              if (!collapsed) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
