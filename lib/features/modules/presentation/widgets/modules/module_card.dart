import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/repositories/api_module_repository.dart';
import '../../../domain/entities/module_entities.dart';
import '../../pages/module_detail_page.dart';
import 'delete_module_button.dart';
import 'module_card_themes.dart';

class ModuleCard extends StatefulWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.repository,
    required this.isTeacher,
    required this.onDeleted,
  });

  final ModuleEntity module;
  final ApiModuleRepository repository;
  final bool isTeacher;
  final VoidCallback onDeleted;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> with TickerProviderStateMixin {
  bool _hovered = false;
  AnimationController? _hoverCtrl;
  AnimationController? _dotsCtrl;
  Animation<double> _scale = const AlwaysStoppedAnimation(1.0);
  Animation<double> _shift = const AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _dotsCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _scale = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _hoverCtrl!, curve: Curves.easeOut));
    _shift = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _dotsCtrl!, curve: Curves.linear));
  }

  @override
  void dispose() {
    _hoverCtrl?.dispose();
    _dotsCtrl?.dispose();
    super.dispose();
  }

  void _onEnter(_) { setState(() => _hovered = true);  _hoverCtrl?.forward(); _dotsCtrl?.repeat(); }
  void _onExit(_)  { setState(() => _hovered = false); _hoverCtrl?.reverse(); _dotsCtrl?.stop(); _dotsCtrl?.reset(); }

  @override
  Widget build(BuildContext context) {
    final t = themeForModule(widget.module.id);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ModuleDetailPage(
                module: widget.module,
                repository: widget.repository,
                isTeacher: widget.isTeacher,
              ),
            ),
          );
          if (!mounted) return;
          widget.onDeleted();
        },
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius: const BorderRadius.all(AppRadius.large),
              border: Border.all(color: _hovered ? t.accent.withValues(alpha: 0.55) : t.soft, width: _hovered ? 1.5 : 1.0),
              boxShadow: _hovered
                  ? [BoxShadow(color: t.accent.withValues(alpha: 0.16), blurRadius: 20, offset: const Offset(0, 6)),
                     BoxShadow(color: t.accent.withValues(alpha: 0.07), blurRadius: 40, offset: const Offset(0, 16))]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(AppRadius.large),
              child: Stack(children: [
                // Puntos animados
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _hovered ? 0.6 : 0.3,
                    child: AnimatedBuilder(
                      animation: _dotsCtrl ?? const AlwaysStoppedAnimation(0),
                      builder: (_, child) => CustomPaint(
                        painter: DotsPainter(color: t.accent, seed: widget.module.id.hashCode, shift: _shift.value),
                      ),
                    ),
                  ),
                ),
                // Patrón esquina
                Positioned(
                  bottom: -6, right: -6,
                  child: SizedBox(
                    width: 80, height: 72,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _hovered ? 0.35 : 0.14,
                      child: CustomPaint(painter: PatternPainter(pattern: t.pattern, color: t.accent)),
                    ),
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(widget.module.title,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Nunito',
                                  color: _hovered ? t.accent : AppColors.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _hovered ? t.accent : t.accent.withValues(alpha: 0.12),
                              borderRadius: const BorderRadius.all(AppRadius.medium),
                              boxShadow: _hovered ? [BoxShadow(color: t.accent.withValues(alpha: 0.35), blurRadius: 8)] : [],
                            ),
                            child: Icon(widget.module.type.icon, color: _hovered ? Colors.white : t.accent, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(widget.module.description,
                        style: TextStyle(fontSize: 12, fontFamily: 'Nunito', height: 1.95,
                            color: _hovered ? t.accent.withValues(alpha: 0.7) : AppColors.textSecondary),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 19),
                      const Spacer(),
                      Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _hovered ? t.accent : t.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.edit_note_rounded, size: 18, color: _hovered ? Colors.white : t.accent),
                            const SizedBox(width: 3),
                            Text('${widget.module.exerciseCount} ejercicios',
                              style: TextStyle(fontSize: 11, fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                                  color: _hovered ? Colors.white : t.accent)),
                            const SizedBox(width: 3),
                            Icon(Icons.arrow_forward_rounded, size: 10, color: _hovered ? Colors.white : t.accent),
                          ]),
                        ),
                        const Spacer(),
                        DeleteModuleButton(
                          hovered: _hovered,
                          moduleName: widget.module.title,
                          moduleId: widget.module.id,
                          repository: widget.repository,
                          onDeleted: widget.onDeleted,
                        ),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

