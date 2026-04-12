import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../domain/entities/module_entities.dart';

class InfoPanel extends StatelessWidget {
  const InfoPanel({
    super.key,
    required this.exercises,
    required this.isTeacher,
    required this.onCreateExercise,
  });

  final List<ExerciseEntity> exercises;
  final bool isTeacher;
  final VoidCallback onCreateExercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoTable(exercises: exercises),
        if (isTeacher) ...[
          const SizedBox(height: 12),
          _CreateButton(onPressed: onCreateExercise),
        ],
      ],
    );
  }
}

// --- Estilos ---

class _TableStyles {
  static const _base = TextStyle(fontFamily: 'Nunito');

  static TextStyle headerLabel(BuildContext context) => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  static final rowLabel    = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static final valueActive = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary);
  static final valueInact  = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
  static final valueTotal  = _base.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle cardTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.3,
          ) ??
      const TextStyle();

  static TextStyle cardSubtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ) ??
      const TextStyle();
}

// --- Info Table ---

class _InfoTable extends StatelessWidget {
  const _InfoTable({required this.exercises});

  final List<ExerciseEntity> exercises;

  int _activeD(DifficultyLevel d)   => exercises.where((e) => e.difficulty == d && e.isActive).length;
  int _inactiveD(DifficultyLevel d) => exercises.where((e) => e.difficulty == d && !e.isActive).length;
  int _totalD(DifficultyLevel d)    => exercises.where((e) => e.difficulty == d).length;

  int _activeS(Subject s)   => exercises.where((e) => e.subject == s && e.isActive).length;
  int _inactiveS(Subject s) => exercises.where((e) => e.subject == s && !e.isActive).length;
  int _totalS(Subject s)    => exercises.where((e) => e.subject == s).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(),
          const SizedBox(height: 14),
          _SectionTable(
            icon: Icons.signal_cellular_alt_rounded,
            label: 'Por Dificultad',
            colLabel: 'Dificultad',
            rows: DifficultyLevel.values
                .map((d) => _RowData(
                      label: d.label,
                      color: d.color,
                      active: _activeD(d),
                      inactive: _inactiveD(d),
                      total: _totalD(d),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          _SectionTable(
            icon: Icons.school_rounded,
            label: 'Por Materia',
            colLabel: 'Materia',
            emptyText: 'Sin ejercicios aún',
            rows: Subject.values
                .where((s) => _totalS(s) > 0)
                .map((s) => _RowData(
                      label: s.shortLabel,
                      color: s.color,
                      active: _activeS(s),
                      inactive: _inactiveS(s),
                      total: _totalS(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// --- Card Header ---

class _CardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.all(AppRadius.small),
          ),
          child: const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Información General', style: _TableStyles.cardTitle(context)),
              Text('Resumen de ejercicios', style: _TableStyles.cardSubtitle(context)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Tabla (dificultad y materia) ---

class _RowData {
  const _RowData({
    required this.label,
    required this.color,
    required this.active,
    required this.inactive,
    required this.total,
  });
  final String label;
  final Color color;
  final int active, inactive, total;
}

class _SectionTable extends StatelessWidget {
  const _SectionTable({
    required this.icon,
    required this.label,
    required this.colLabel,
    required this.rows,
    this.emptyText,
  });

  final IconData icon;
  final String label;
  final String colLabel;
  final List<_RowData> rows;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                fontFamily: 'Nunito',
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(flex: 3, child: Text(colLabel, style: _TableStyles.headerLabel(context))),
            Expanded(flex: 2, child: Center(child: Text('Activos', style: _TableStyles.headerLabel(context)))),
            Expanded(flex: 2, child: Center(child: Text('Inact.',  style: _TableStyles.headerLabel(context)))),
            Expanded(flex: 2, child: Center(child: Text('Total',   style: _TableStyles.headerLabel(context)))),
          ],
        ),
        const SizedBox(height: 4),
        Divider(color: Colors.grey.withValues(alpha: 0.15), height: 1, thickness: 1),
        if (rows.isNotEmpty)
          ...rows.map((r) => _TableRow(data: r))
        else if (emptyText != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              emptyText!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'Nunito',
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

// --- Fila de tabla ---

class _TableRow extends StatelessWidget {
  const _TableRow({required this.data});

  final _RowData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: data.color),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    data.label,
                    overflow: TextOverflow.ellipsis,
                    style: _TableStyles.rowLabel,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Center(child: Text('${data.active}',   style: _TableStyles.valueActive))),
          Expanded(flex: 2, child: Center(child: Text('${data.inactive}', style: _TableStyles.valueInact))),
          Expanded(flex: 2, child: Center(child: Text('${data.total}',    style: _TableStyles.valueTotal))),
        ],
      ),
    );
  }
}

// --- Botón crear ejercicio ---

class _CreateButton extends StatefulWidget {
  const _CreateButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPress() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.97).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
        ),
        child: ElevatedButton(
          onPressed: _onPress,
          style: ButtonStyle(
            mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click), // ðŸ‘ˆ
            backgroundColor: WidgetStateProperty.all(AppColors.primary),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 14),
            ),
            elevation: WidgetStateProperty.all(0),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.medium),
              ),
            ),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
                letterSpacing: 0.3,
              ),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_rounded, size: 18),
              SizedBox(width: 6),
              Text('Crear ejercicio'),
            ],
          ),
        ),
      ),
    );
  }
}

