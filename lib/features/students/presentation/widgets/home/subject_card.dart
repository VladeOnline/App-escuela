import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../modules/domain/entities/module_entities.dart';

// ---------------------------------------------------------------------------
// Configuración visual por tipo de materia
// ---------------------------------------------------------------------------

const _subjectColors = {
  ModuleType.reading: Color(0xFF0D9488),
  ModuleType.writing: Color(0xFF8B5CF6),
  ModuleType.math: Color(0xFFF59E0B),
};

const _subjectGradients = {
  ModuleType.reading: [Color(0xFF0D9488), Color(0xFF14B8A6)],
  ModuleType.writing: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  ModuleType.math: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
};

const _subjectIcons = {
  ModuleType.reading: Icons.menu_book_rounded,
  ModuleType.writing: Icons.edit_rounded,
  ModuleType.math: Icons.calculate_rounded,
};

// ---------------------------------------------------------------------------
// SubjectCard — card para lectura, escritura o matemáticas
// ---------------------------------------------------------------------------

class SubjectCard extends StatefulWidget {
  const SubjectCard({
    super.key,
    required this.moduleType,
    required this.pendingCount,
    required this.onTap,
  });

  final ModuleType moduleType;
  final int pendingCount;
  final VoidCallback onTap;

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.04).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color => _subjectColors[widget.moduleType]!;
  List<Color> get _gradient => _subjectGradients[widget.moduleType]!;
  IconData get _icon => _subjectIcons[widget.moduleType]!;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scale,
          child: _CardShell(
            color: _color,
            hovered: _hovered,
            topSection: _CardTop(
              gradient: _gradient,
              icon: _icon,
              pendingCount: widget.pendingCount,
              accentColor: _color,
            ),
            bottomSection: _CardBottom(
              label: widget.moduleType.label,
              accentColor: _color,
              pendingCount: widget.pendingCount,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AchievementsCard — card de logros (color fijo rosa)
// ---------------------------------------------------------------------------

class AchievementsCard extends StatefulWidget {
  const AchievementsCard({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<AchievementsCard> createState() => _AchievementsCardState();
}

class _AchievementsCardState extends State<AchievementsCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.04).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
  );

  static const _color = Color(0xFFEC4899);
  static const _gradient = [Color(0xFFEC4899), Color(0xFFF472B6)];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scale,
          child: _CardShell(
            color: _color,
            hovered: _hovered,
            topSection: _CardTop(
              gradient: _gradient,
              icon: Icons.emoji_events_rounded,
              pendingCount: -1,
              accentColor: _color,
            ),
            bottomSection: _CardBottom(
              label: 'Logros',
              accentColor: _color,
              pendingCount: -1,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subwidgets compartidos entre cards
// ---------------------------------------------------------------------------

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.color,
    required this.hovered,
    required this.topSection,
    required this.bottomSection,
  });

  final Color color;
  final bool hovered;
  final Widget topSection;
  final Widget bottomSection;

  @override
  Widget build(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.all(AppRadius.xl),
      border: Border.all(
        color: hovered ? color.withValues(alpha: 0.5) : AppColors.border,
        width: hovered ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: hovered
              ? color.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.06),
          blurRadius: hovered ? 24 : 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: topSection),
        SizedBox(height: 72, child: bottomSection),
      ],
    ),
  );
}
}

class _CardTop extends StatelessWidget {
  const _CardTop({
    required this.gradient,
    required this.icon,
    required this.pendingCount,
    required this.accentColor,
  });

  final List<Color> gradient;
  final IconData icon;
  final int pendingCount;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: const BorderRadius.vertical(top: AppRadius.xl),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -16, right: -16,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -8, left: -8,
            child: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Center(child: Icon(icon, size: 52, color: Colors.white)),
          if (pendingCount >= 0)
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _PendingBadge(
                count: pendingCount,
                accentColor: accentColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardBottom extends StatelessWidget {
  const _CardBottom({
    required this.label,
    required this.accentColor,
    required this.pendingCount,
  });

  final String label;
  final Color accentColor;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_rounded, size: 11, color: accentColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.count, required this.accentColor});
  final int count;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.all(AppRadius.full),
      ),
      child: Text(
        count == 0 ? '¡Al día! 🎉' : '$count ejercicio${count != 1 ? 's' : ''}',
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          color: accentColor,
        ),
      ),
    );
  }
}