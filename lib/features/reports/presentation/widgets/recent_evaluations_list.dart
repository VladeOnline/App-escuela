import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/report_result_entity.dart';
import '../mock/report_mock_data.dart';

/// Lista de últimas evaluaciones.
/// El dot de cada fila usa el color de la materia (igual que en ejercicios).
class RecentEvaluationsList extends StatelessWidget {
  const RecentEvaluationsList({
    super.key,
    required this.results,
    this.maxItems = 5,
  });

  final List<ReportResultEntity> results;
  final int maxItems;

  static const _months = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    final items = results.take(maxItems).toList();

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          'No hay evaluaciones registradas',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ÚLTIMAS EVALUACIONES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((r) => _EvalRow(result: r, dateStr: _fmtDate(r.fecha))),
      ],
    );
  }
}

class _EvalRow extends StatelessWidget {
  const _EvalRow({required this.result, required this.dateStr});

  final ReportResultEntity result;
  final String dateStr;

  @override
  Widget build(BuildContext context) {
    // Color del dot = color de la materia del design system
    final dotColor = SubjectColors.forName(result.materia);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.evaluacionTitulo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  '${result.materia} · $dateStr',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textHint,
                      ),
                ),
              ],
            ),
          ),
          _ScoreBadge(score: result.puntuacion),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (score >= 75) {
      bg = const Color(0xFFD1FAE5); fg = const Color(0xFF065F46);
    } else if (score >= 60) {
      bg = const Color(0xFFFEF3C7); fg = const Color(0xFF92400E);
    } else {
      bg = const Color(0xFFFEE2E2); fg = const Color(0xFF991B1B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(AppRadius.full),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: fg, fontFamily: 'Nunito',
        ),
      ),
    );
  }
}