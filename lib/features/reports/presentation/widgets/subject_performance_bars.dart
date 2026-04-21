import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../mock/report_mock_data.dart';

/// Barras de rendimiento por materia.
///   1ª barra (sólida)   → Lectura
///   2ª barra (punteada) → Escritura
class SubjectPerformanceBars extends StatelessWidget {
  const SubjectPerformanceBars({super.key, required this.subjects});

  final List<SubjectPerformance> subjects;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(),
        const SizedBox(height: AppSpacing.md),
        ...subjects.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SubjectRow(subject: s),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Rendimiento por materia',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        _LegendItem(label: 'Lectura',   dashed: false),
        const SizedBox(width: AppSpacing.md),
        _LegendItem(label: 'Escritura', dashed: true),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.dashed});
  final String label;
  final bool   dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 8,
          child: CustomPaint(painter: _LegendLinePainter(dashed: dashed)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});
  final SubjectPerformance subject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            subject.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _SolidBar(percent: subject.reading / 100, color: subject.color),
              const SizedBox(height: 5),
              _DashedBar(percent: subject.writing / 100, color: subject.color),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 36,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${subject.reading}%',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: subject.color,
                ),
              ),
              Text(
                '${subject.writing}%',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: subject.color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SolidBar extends StatelessWidget {
  const _SolidBar({required this.percent, required this.color});
  final double percent;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(AppRadius.full),
      child: SizedBox(
        height: 7,
        child: Stack(
          children: [
            Container(color: AppColors.border),
            FractionallySizedBox(
              widthFactor: percent.clamp(0.0, 1.0),
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBar extends StatelessWidget {
  const _DashedBar({required this.percent, required this.color});
  final double percent;
  final Color  color;

  static const _dashW = 6.0;
  static const _gapW  = 4.0;
  static const _barH  = 7.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barH,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final totalW    = constraints.maxWidth;
          final fillW     = totalW * percent.clamp(0.0, 1.0);
          final stepW     = _dashW + _gapW;
          final dashCount = (fillW / stepW).ceil();

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: const BorderRadius.all(AppRadius.full),
                ),
              ),
              Row(
                children: List.generate(dashCount, (i) {
                  final dashStart = i * stepW;
                  final dashEnd   = dashStart + _dashW;
                  final visible   = dashEnd <= fillW
                      ? _dashW
                      : (fillW - dashStart).clamp(0.0, _dashW);

                  return Row(
                    children: [
                      Container(
                        width:  visible,
                        height: _barH,
                        // Opacidad bajada a 0.45 — más suave a la vista
                        color: color.withValues(alpha: 0.45),
                      ),
                      if (dashEnd < fillW)
                        SizedBox(width: _gapW, height: _barH),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendLinePainter extends CustomPainter {
  const _LegendLinePainter({required this.dashed});
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;

    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    const dashW = 4.0;
    const gapW  = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dashW).clamp(0.0, size.width), y),
        paint,
      );
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_LegendLinePainter old) => old.dashed != dashed;
}