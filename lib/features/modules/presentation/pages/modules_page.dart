import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import 'module_detail_page.dart';

// ─── Temas visuales ───────────────────────────────────────────────────────────

enum _CardPattern { bubbles, waves, constellation, crystals, petals, mosaic }

class _CardTheme {
  const _CardTheme({
    required this.bg,
    required this.accent,
    required this.soft,
    required this.pattern,
  });
  final Color bg, accent, soft;
  final _CardPattern pattern;
}

const _cardThemes = [
  _CardTheme(bg: Color(0xFFF0FDF8), accent: Color(0xFF0D9488), soft: Color(0xFFCCFBF1), pattern: _CardPattern.bubbles),
  _CardTheme(bg: Color(0xFFFFFBEB), accent: Color(0xFFD97706), soft: Color(0xFFFDE68A), pattern: _CardPattern.waves),
  _CardTheme(bg: Color(0xFFEFF6FF), accent: Color(0xFF3B82F6), soft: Color(0xFFBFDBFE), pattern: _CardPattern.constellation),
  _CardTheme(bg: Color(0xFFFFF1F2), accent: Color(0xFFE11D48), soft: Color(0xFFFFCDD5), pattern: _CardPattern.crystals),
  _CardTheme(bg: Color(0xFFF5F3FF), accent: Color(0xFF7C3AED), soft: Color(0xFFDDD6FE), pattern: _CardPattern.petals),
  _CardTheme(bg: Color(0xFFFFF7ED), accent: Color(0xFFEA580C), soft: Color(0xFFFED7AA), pattern: _CardPattern.mosaic),
];

_CardTheme _themeFor(String id) =>
    _cardThemes[id.hashCode.abs() % _cardThemes.length];

// ─── Página ───────────────────────────────────────────────────────────────────

class ModulesPage extends StatelessWidget {
  const ModulesPage({
    super.key,
    required this.moduleType,
    required this.repository,
    this.isTeacher = true,
    this.studentGrade,
  });

  final ModuleType moduleType;
  final MockModuleRepository repository;
  final bool isTeacher;
  final int? studentGrade;

  List<ModuleEntity> _modulesForGrade(int grade) =>
      repository.getModulesByType(moduleType).where((m) => m.grade == grade).toList();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ModulesHeader(moduleType: moduleType),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl,
              ),
              itemCount: AppConstants.grades.length,
              itemBuilder: (_, i) {
                final grade = AppConstants.grades[i];
                return _GradeSection(
                  grade: grade,
                  modules: _modulesForGrade(grade),
                  repository: repository,
                  isTeacher: isTeacher,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ModulesHeader extends StatelessWidget {
  const _ModulesHeader({required this.moduleType});
  final ModuleType moduleType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18, right: -12,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Positioned(
            bottom: 6, right: 80,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.10), width: 1.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: const BorderRadius.all(AppRadius.medium),
                ),
                child: Icon(moduleType.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Módulos de ${moduleType.label}',
                    style: const TextStyle(fontSize: 20, fontFamily: 'Nunito', color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Selecciona un módulo para comenzar',
                    style: TextStyle(fontSize: 12, fontFamily: 'Nunito', color: Colors.white.withOpacity(0.80))),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ─── Sección por grado ────────────────────────────────────────────────────────

class _GradeSection extends StatelessWidget {
  const _GradeSection({
    required this.grade,
    required this.modules,
    required this.repository,
    required this.isTeacher,
  });

  final int grade;
  final List<ModuleEntity> modules;
  final MockModuleRepository repository;
  final bool isTeacher;

  static const _gradeNames = {
    1: 'Primer grado',  2: 'Segundo grado', 3: 'Tercer grado',
    4: 'Cuarto grado',  5: 'Quinto grado',  6: 'Sexto grado',
  };

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGrade(grade);
    final name = _gradeNames[grade] ?? '$grade° grado';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: const BorderRadius.all(AppRadius.medium),
              ),
              child: Icon(Icons.school_rounded, color: color, size: 16),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: color)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withOpacity(0.35), Colors.transparent])),
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          if (modules.isEmpty)
            _EmptyGrade(color: color, gradeName: name)
          else
            LayoutBuilder(builder: (_, constraints) {
              const cols = 3;
              const spacing = AppSpacing.sm;
              final cardWidth = ((constraints.maxWidth - spacing * (cols - 1)) / cols) * 0.9;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  ...modules.map((m) => SizedBox(
                    width: cardWidth,
                    child: SizedBox(
                    height: 190,
                    child: _ModuleCard(
                      module: m,
                      repository: repository,
                      isTeacher: isTeacher,
                    ),
                  ),
                  )),
                  // Card "Crear módulo" — mismo ancho que las otras
                  SizedBox(
                    width: cardWidth,
                    child: SizedBox(
                    height: 190,
                    child: _CreateModuleCard(),
                  ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

// ─── Card de módulo ───────────────────────────────────────────────────────────

class _ModuleCard extends StatefulWidget {
  const _ModuleCard({required this.module, required this.repository, required this.isTeacher});
  final ModuleEntity module;
  final MockModuleRepository repository;
  final bool isTeacher;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> with TickerProviderStateMixin {
  bool _hovered = false;

  // Inicializados con valor seguro — evita LateInitializationError en hot reload
  AnimationController? _hoverCtrl;
  AnimationController? _dotsCtrl;
  Animation<double> _scale = const AlwaysStoppedAnimation(1.0);
  Animation<double> _shift = const AlwaysStoppedAnimation(0.0);

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
    _dotsCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _scale     = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _hoverCtrl!, curve: Curves.easeOut));
    _shift     = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _dotsCtrl!, curve: Curves.linear));
  }

  @override
  void dispose() {
    _hoverCtrl?.dispose();
    _dotsCtrl?.dispose();
    super.dispose();
  }

  void _onEnter(_) {
    setState(() => _hovered = true);
    _hoverCtrl?.forward();
    _dotsCtrl?.repeat(); // arranca el loop solo en hover
  }

  void _onExit(_) {
    setState(() => _hovered = false);
    _hoverCtrl?.reverse();
    _dotsCtrl?.stop();
    _dotsCtrl?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final t = _themeFor(widget.module.id);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ModuleDetailPage(module: widget.module, repository: widget.repository, isTeacher: widget.isTeacher),
        )),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius: const BorderRadius.all(AppRadius.large),
              border: Border.all(
                color: _hovered ? t.accent.withOpacity(0.55) : t.soft,
                width: _hovered ? 1.5 : 1.0,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(color: t.accent.withOpacity(0.16), blurRadius: 20, offset: const Offset(0, 6)),
                      BoxShadow(color: t.accent.withOpacity(0.07), blurRadius: 40, offset: const Offset(0, 16)),
                    ]
                  : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(AppRadius.large),
              child: Stack(children: [
                // Puntos animados — se mueven solo en hover
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: _hovered ? 0.6 : 0.3,
                    child: AnimatedBuilder(
                      animation: _dotsCtrl ?? const AlwaysStoppedAnimation(0),
                      builder: (_, __) => CustomPaint(
                        painter: _DotsPainter(
                          color: t.accent,
                          seed: widget.module.id.hashCode,
                          shift: _shift.value,
                        ),
                      ),
                    ),
                  ),
                ),
                // Patrón — esquina inferior derecha
                Positioned(
                  bottom: -6, right: -6,
                  child: SizedBox(
                    width: 80, height: 72,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _hovered ? 0.35 : 0.14,
                      child: CustomPaint(painter: _PatternPainter(pattern: t.pattern, color: t.accent)),
                    ),
                  ),
                ),
                // Contenido — intacto, igual que tu versión
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
                            child: Text(
                              widget.module.title,
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Nunito',
                                color: _hovered ? t.accent : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _hovered ? t.accent : t.accent.withOpacity(0.12),
                              borderRadius: const BorderRadius.all(AppRadius.medium),
                              boxShadow: _hovered ? [BoxShadow(color: t.accent.withOpacity(0.35), blurRadius: 8)] : [],
                            ),
                            child: Icon(widget.module.type.icon, color: _hovered ? Colors.white : t.accent, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.module.description,
                        style: TextStyle(
                          fontSize: 12, fontFamily: 'Nunito', height: 1.95,
                          color: _hovered ? t.accent.withOpacity(0.7) : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 19),
                      const Spacer(),
                      // Footer: pill + botón eliminar
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _hovered ? t.accent : t.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_note_rounded, size: 18, color: _hovered ? Colors.white : t.accent),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.module.exerciseCount} ejercicios',
                                  style: TextStyle(
                                    fontSize: 11, fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                                    color: _hovered ? Colors.white : t.accent,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(Icons.arrow_forward_rounded, size: 10, color: _hovered ? Colors.white : t.accent),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _DeleteButton(hovered: _hovered, moduleName: widget.module.title),
                        ],
                      ),
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

// ─── Card "Crear módulo" ──────────────────────────────────────────────────────
// Mismo padding/estructura que _ModuleCard para que IntrinsicHeight las iguale

class _CreateModuleCard extends StatefulWidget {
  const _CreateModuleCard({super.key});

  @override
  State<_CreateModuleCard> createState() => _CreateModuleCardState();
}

class _CreateModuleCardState extends State<_CreateModuleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta función aún no está disponible 🚧'), behavior: SnackBarBehavior.floating),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.primary.withOpacity(0.04) : Colors.white,
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(
              color: _hovered ? AppColors.primary : AppColors.primary.withOpacity(0.35),
              width: _hovered ? 1.5 : 1.0,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          // Mismo padding que _ModuleCard para que mida igual
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Fila superior vacía — mantiene la altura del título + ícono
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hovered
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.12),
                    boxShadow: _hovered
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)]
                        : [],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 26,
                    color: _hovered ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                // Texto centrado en lugar de descripción
                SizedBox(
                  // height aprox de 2 líneas de descripción (height: 1.95 * fontSize 12 * 2)
                  height: 12 * 1.95 * 2,
                  child: Center(
                    child: Text(
                      '¡Crea otro módulo haciendo click aquí!',
                      style: TextStyle(
                        fontSize: 14, fontFamily: 'Nunito', fontWeight: FontWeight.w700,
                        color: _hovered
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                // Fila inferior vacía — mantiene la altura del pill
                const SizedBox(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Botón eliminar ───────────────────────────────────────────────────────────

class _DeleteButton extends StatefulWidget {
  const _DeleteButton({required this.hovered, required this.moduleName});
  final bool hovered;
  final String moduleName;

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  bool _deleteHovered = false;

  Future<void> _showConfirmDialog(BuildContext context) async {
    final ctrl = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final confirmed = ctrl.text.trim() == widget.moduleName;
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.large)),
            backgroundColor: AppColors.surfaceCard,
            title: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text('Eliminar módulo',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.06),
                      borderRadius: const BorderRadius.all(AppRadius.medium),
                      border: Border.all(color: AppColors.error.withOpacity(0.2)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Esta acción es irreversible. Se eliminarán el módulo y todos sus ejercicios permanentemente.',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 12, height: 1.45,
                            color: AppColors.error.withOpacity(0.85)),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Para confirmar, escribe el nombre del módulo:',
                    style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.all(AppRadius.medium),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(widget.moduleName,
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: ctrl,
                    autofocus: true,
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Escribe el nombre exacto...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                      ),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                  style: TextStyle(fontFamily: 'Nunito', color: AppColors.textSecondary)),
              ),
              FilledButton(
                onPressed: confirmed
                    ? () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Eliminar módulo (próximamente) 🚧'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  disabledBackgroundColor: AppColors.error.withOpacity(0.3),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.medium)),
                ),
                child: const Text('Eliminar',
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
    ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: widget.hovered ? 1.0 : 0.0,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _deleteHovered = true),
        onExit:  (_) => setState(() => _deleteHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showConfirmDialog(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34, height: 34,   // era 28 — un poco más grande
            decoration: BoxDecoration(
              color: _deleteHovered ? AppColors.error : AppColors.error.withOpacity(0.1),
              borderRadius: const BorderRadius.all(AppRadius.medium),
              boxShadow: _deleteHovered
                  ? [BoxShadow(color: AppColors.error.withOpacity(0.3), blurRadius: 8)]
                  : [],
            ),
            child: Icon(Icons.delete_outline_rounded, size: 18,
              color: _deleteHovered ? Colors.white : AppColors.error),
          ),
        ),
      ),
    );
  }
}

// ─── Puntos de luz dispersos ──────────────────────────────────────────────────

class _DotsPainter extends CustomPainter {
  const _DotsPainter({required this.color, required this.seed, required this.shift});
  final Color color;
  final int seed;
  final double shift; // 0.0 → 1.0 en loop

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 14; i++) {
      final baseX  = rng.nextDouble() * size.width;
      final baseY  = rng.nextDouble() * size.height;
      final radius = 1.2 + rng.nextDouble() * 2.8;
      final speed  = 0.4 + rng.nextDouble() * 0.8;

      paint.color = color.withOpacity(0.08 + rng.nextDouble() * 0.16);

      // Desplazamiento horizontal con wrapping
      final x = (baseX + shift * size.width * speed) % size.width;
      // Flote vertical suave
      final y = baseY + sin(shift * 2 * pi + i) * 2.0;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => old.shift != shift || old.color != color;
}

// ─── Patrones decorativos ─────────────────────────────────────────────────────

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.pattern, required this.color});
  final _CardPattern pattern;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    final stroke = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.6..strokeCap = StrokeCap.round;

    switch (pattern) {
      case _CardPattern.bubbles:
        canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.25), 22, stroke);
        canvas.drawCircle(Offset(size.width * 1.0,  size.height * 0.55), 16, fill);
        canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.90), 10, stroke);
        canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.88), 6, fill..color = color.withOpacity(0.5));

      case _CardPattern.waves:
        for (int i = 0; i < 3; i++) {
          final path = Path();
          final y = size.height * (0.3 + i * 0.28);
          path.moveTo(size.width * 0.3, y);
          path.cubicTo(size.width * 0.55, y - 14, size.width * 0.75, y + 14, size.width * 1.05, y);
          canvas.drawPath(path, stroke..strokeWidth = 2.0 - i * 0.4..color = color.withOpacity(1 - i * 0.2));
        }

      case _CardPattern.constellation:
        final pts = [
          Offset(size.width * 0.6,  size.height * 0.15),
          Offset(size.width * 0.9,  size.height * 0.35),
          Offset(size.width * 0.75, size.height * 0.65),
          Offset(size.width * 0.5,  size.height * 0.85),
          Offset(size.width * 1.0,  size.height * 0.80),
        ];
        final line = Paint()..color = color.withOpacity(0.4)..strokeWidth = 1.0;
        for (int i = 0; i < pts.length - 1; i++) canvas.drawLine(pts[i], pts[i + 1], line);
        for (final p in pts) canvas.drawCircle(p, 3.0, fill);

      case _CardPattern.crystals:
        void drawHex(Offset c, double r, double a) {
          final path = Path();
          for (int i = 0; i < 6; i++) {
            final pt = Offset(c.dx + r * cos(a + i * pi / 3), c.dy + r * sin(a + i * pi / 3));
            i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
          }
          path.close();
          canvas.drawPath(path, stroke..strokeWidth = 1.4);
        }
        drawHex(Offset(size.width * 0.75, size.height * 0.35), 18, 0.2);
        drawHex(Offset(size.width * 0.95, size.height * 0.75), 11, 0.5);
        canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.75), 5, fill);

      case _CardPattern.petals:
        final c = Offset(size.width * 0.82, size.height * 0.55);
        for (int i = 0; i < 5; i++) {
          final a   = i * 2 * pi / 5;
          final tip = Offset(c.dx + 22 * cos(a), c.dy + 22 * sin(a));
          canvas.drawPath(
            Path()
              ..moveTo(c.dx, c.dy)
              ..quadraticBezierTo(c.dx + 15 * cos(a - 0.5), c.dy + 15 * sin(a - 0.5), tip.dx, tip.dy)
              ..quadraticBezierTo(c.dx + 15 * cos(a + 0.5), c.dy + 15 * sin(a + 0.5), c.dx, c.dy),
            stroke..strokeWidth = 1.3,
          );
        }
        canvas.drawCircle(c, 4, fill);

      case _CardPattern.mosaic:
        for (int xi = 0; xi < 3; xi++) {
          for (int yi = 0; yi < 3; yi++) {
            canvas.save();
            canvas.translate(size.width * (0.42 + xi * 0.22), size.height * (0.15 + yi * 0.32));
            canvas.rotate(0.3 + xi * 0.15 + yi * 0.1);
            final h = 6.0 - xi * 1.2;
            canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: h * 2, height: h * 2), const Radius.circular(2)),
              fill..color = color.withOpacity(0.3 + xi * 0.15),
            );
            canvas.restore();
          }
        }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) => old.color != color || old.pattern != pattern;
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyGrade extends StatelessWidget {
  const _EmptyGrade({required this.color, required this.gradeName});
  final Color color;
  final String gradeName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withOpacity(0.08), shape: BoxShape.circle),
            child: Icon(Icons.sentiment_dissatisfied_rounded, size: 26, color: color.withOpacity(0.5)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No hay ejercicios para $gradeName',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Esta función aún no está disponible 🚧'), behavior: SnackBarBehavior.floating),
              ),
              child: Text('¡Empieza a crearlos →!',
                style: TextStyle(
                  color: color.withOpacity(0.8), fontSize: 13,
                  fontWeight: FontWeight.w600, fontFamily: 'Nunito',
                  decoration: TextDecoration.underline,
                  decorationColor: color.withOpacity(0.3),
                )),
            ),
          ),
        ],
      ),
    );
  }
}