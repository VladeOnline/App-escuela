import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/historial_entity.dart';

/// Tabla de historial de evaluaciones con el design system del proyecto.
class HistorialTable extends StatelessWidget {
  const HistorialTable({super.key, required this.historial});

  final HistorialEvaluacionesEntity historial;

  static const _months = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${_months[d.month]}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (historial.historial.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Center(
          child: Text(
            'Sin evaluaciones registradas',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textHint,
                ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(AppRadius.large),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surface),
          dividerThickness: 0.5,
          columnSpacing: AppSpacing.lg,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            fontSize: 12,
            fontFamily: 'Nunito',
          ),
          dataTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontFamily: 'Nunito',
          ),
          columns: const [
            DataColumn(label: Text('Evaluación')),
            DataColumn(label: Text('Materia')),
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Puntuación'), numeric: true),
            DataColumn(label: Text('Preguntas'), numeric: true),
            DataColumn(label: Text('Intento'), numeric: true),
            DataColumn(label: Text('Estado')),
          ],
          rows: historial.historial
              .map((item) => _buildRow(item))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(HistorialItemEntity item) {
    return DataRow(
      cells: [
        DataCell(Text(
          item.evaluacionNombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        )),
        DataCell(Text(item.materia)),
        DataCell(Text(_formatDate(item.fecha))),
        DataCell(_ScoreBadge(score: item.puntuacion)),
        DataCell(Center(
          child: Text('${item.preguntasCorrectas}/${item.totalPreguntas}'),
        )),
        DataCell(Center(child: Text('${item.intento}'))),
        DataCell(_StatusBadge(approved: item.aprobado)),
      ],
    );
  }
}

// ── Badge de puntuación ────────────────────────────────────────────────────────

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (score >= 75) {
      bg = const Color(0xFFD1FAE5);
      fg = const Color(0xFF065F46);
    } else if (score >= 60) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFF92400E);
    } else {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(AppRadius.full),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: fg,
          fontSize: 12,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

// ── Badge de estado ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.approved});
  final bool approved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: approved
            ? const Color(0xFFD1FAE5)
            : const Color(0xFFFEE2E2),
        borderRadius: const BorderRadius.all(AppRadius.full),
      ),
      child: Text(
        approved ? 'Aprobado' : 'No aprobado',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: approved
              ? const Color(0xFF065F46)
              : const Color(0xFF991B1B),
          fontSize: 12,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}