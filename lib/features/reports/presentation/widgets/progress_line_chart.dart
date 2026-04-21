import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../mock/report_mock_data.dart';

/// Gráfico de línea con tooltip al pasar el cursor sobre cada punto.
class ProgressLineChart extends StatefulWidget {
  const ProgressLineChart({super.key, required this.points});

  final List<WeekPoint> points;

  @override
  State<ProgressLineChart> createState() => _ProgressLineChartState();
}

class _ProgressLineChartState extends State<ProgressLineChart> {
  int? _hovered;

  static const _padL = 36.0;
  static const _padR = 12.0;
  static const _padT = 12.0;
  static const _padB = 24.0;

  int? _indexAt(Offset pos, Size size) {
    if (widget.points.isEmpty) return null;
    final n      = widget.points.length;
    final chartW = size.width - _padL - _padR;
    for (var i = 0; i < n; i++) {
      final x = _padL + chartW * i / (n - 1);
      if ((pos.dx - x).abs() < 22) return i;
    }
    return null;
  }

  void _onHover(PointerEvent e, Size size) {
    final idx = _indexAt(e.localPosition, size);
    if (idx != _hovered) setState(() => _hovered = idx);
  }

  void _onExit(_) => setState(() => _hovered = null);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Row(
          children: [
            Expanded(
              child: Text(
                'Evolución del promedio',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Text(
              'últimas ${widget.points.length} semanas',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Gráfico
        SizedBox(
          height: 140,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, 140);
              return MouseRegion(
                cursor: _hovered != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                onHover: (e) => _onHover(e, size),
                onExit: _onExit,
                child: GestureDetector(
                  onTapDown: (d) {
                    final idx = _indexAt(d.localPosition, size);
                    setState(() => _hovered = idx);
                  },
                  onTapUp: (_) => setState(() => _hovered = null),
                  child: CustomPaint(
                    size: size,
                    painter: _ChartPainter(
                      points: widget.points,
                      hovered: _hovered,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _ChartPainter extends CustomPainter {
  const _ChartPainter({required this.points, required this.hovered});

  final List<WeekPoint> points;
  final int?            hovered;

  static const _minY = 30.0;
  static const _maxY = 100.0;
  static const _padL = 36.0;
  static const _padR = 12.0;
  static const _padT = 12.0;
  static const _padB = 24.0;

  double _toY(double v, double cH) =>
      _padT + cH * (1 - (v - _minY) / (_maxY - _minY));

  double _toX(int i, double cW) {
    if (points.length <= 1) return _padL + cW / 2;
    return _padL + cW * i / (points.length - 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cW = size.width - _padL - _padR;
    final cH = size.height - _padT - _padB;

    _drawGrid(canvas, size, cW, cH);
    _drawFill(canvas, size, cW, cH);
    _drawLine(canvas, size, cW, cH);
    _drawDots(canvas, size, cW, cH);
    if (hovered != null) _drawTooltip(canvas, size, cW, cH, hovered!);
  }

  void _drawGrid(Canvas canvas, Size size, double cW, double cH) {
    final gp = Paint()..color = AppColors.border..strokeWidth = 0.5;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (final pct in [40, 60, 80, 100]) {
      final y = _toY(pct.toDouble(), cH);
      canvas.drawLine(Offset(_padL, y), Offset(size.width - _padR, y), gp);
      tp.text = TextSpan(
        text: '$pct%',
        style: const TextStyle(
          fontSize: 9, color: AppColors.textHint, fontFamily: 'Nunito',
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(_padL - tp.width - 4, y - tp.height / 2));
    }

    for (var i = 0; i < points.length; i++) {
      tp.text = TextSpan(
        text: points[i].week,
        style: const TextStyle(
          fontSize: 9, color: AppColors.textHint, fontFamily: 'Nunito',
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(_toX(i, cW) - tp.width / 2, size.height - _padB + 4),
      );
    }
  }

  void _drawFill(Canvas canvas, Size size, double cW, double cH) {
    if (points.isEmpty) return;
    final path = Path()
      ..moveTo(_toX(0, cW), _toY(points[0].value.toDouble(), cH));
    for (var i = 1; i < points.length; i++) {
      final x0 = _toX(i - 1, cW); final y0 = _toY(points[i-1].value.toDouble(), cH);
      final x1 = _toX(i,     cW); final y1 = _toY(points[i  ].value.toDouble(), cH);
      path.cubicTo((x0+x1)/2, y0, (x0+x1)/2, y1, x1, y1);
    }
    path
      ..lineTo(_toX(points.length - 1, cW), size.height - _padB)
      ..lineTo(_toX(0, cW), size.height - _padB)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, _padT, size.width, cH)),
    );
  }

  void _drawLine(Canvas canvas, Size size, double cW, double cH) {
    if (points.isEmpty) return;
    final path = Path()
      ..moveTo(_toX(0, cW), _toY(points[0].value.toDouble(), cH));
    for (var i = 1; i < points.length; i++) {
      final x0 = _toX(i - 1, cW); final y0 = _toY(points[i-1].value.toDouble(), cH);
      final x1 = _toX(i,     cW); final y1 = _toY(points[i  ].value.toDouble(), cH);
      path.cubicTo((x0+x1)/2, y0, (x0+x1)/2, y1, x1, y1);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawDots(Canvas canvas, Size size, double cW, double cH) {
    for (var i = 0; i < points.length; i++) {
      final x   = _toX(i, cW);
      final y   = _toY(points[i].value.toDouble(), cH);
      final big = hovered == i;
      canvas.drawCircle(Offset(x, y), big ? 7.0 : 4.5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), big ? 5.0 : 3.5, Paint()..color = AppColors.primary);
    }
  }

  void _drawTooltip(Canvas canvas, Size size, double cW, double cH, int idx) {
    final x = _toX(idx, cW);
    final y = _toY(points[idx].value.toDouble(), cH);

    const tW = 64.0;
    const tH = 28.0;
    const r  = 6.0;

    double tx = x - tW / 2;
    double ty = y - tH - 10;
    if (tx < 2) tx = 2;
    if (tx + tW > size.width - 2) tx = size.width - tW - 2;
    if (ty < 0) ty = y + 10;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(tx, ty, tW, tH), const Radius.circular(r)),
      Paint()..color = AppColors.textPrimary,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${points[idx].value}%',
        style: const TextStyle(
          color: Colors.white, fontSize: 12,
          fontWeight: FontWeight.w700, fontFamily: 'Nunito',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(tx + (tW - tp.width) / 2, ty + (tH - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.hovered != hovered || old.points != points;
}