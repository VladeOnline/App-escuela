import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_theme.dart';

/// TextField multiline con handle visual de resize en la esquina inferior
/// derecha. Flutter no tiene resize nativo por drag en desktop â€” el campo
/// crece automáticamente al escribir gracias a [maxLines] nulo.
class ExFormResizableTextArea extends StatelessWidget {
  const ExFormResizableTextArea({
    super.key,
    required this.controller,
    required this.hintText,
    this.minLines = 3,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          mouseCursor: SystemMouseCursors.text,
          decoration: InputDecoration(
            hintText: hintText,
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          ),
        ),
        // Handle decorativo â€” 6 puntos en patrón diagonal (igual a HTML textarea)
        Positioned(
          right: 5,
          bottom: 5,
          child: CustomPaint(
            size: const Size(10, 10),
            painter: _ResizeHandlePainter(color: AppColors.textHint.withValues(alpha: 0.4)),
          ),
        ),
      ],
    );
  }
}

class _ResizeHandlePainter extends CustomPainter {
  const _ResizeHandlePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    const r = 1.5;
    canvas.drawCircle(Offset(size.width,       size.height),       r, paint);
    canvas.drawCircle(Offset(size.width - 3.5, size.height),       r, paint);
    canvas.drawCircle(Offset(size.width,       size.height - 3.5), r, paint);
    canvas.drawCircle(Offset(size.width - 3.5, size.height - 3.5), r, paint);
    canvas.drawCircle(Offset(size.width - 7,   size.height),       r, paint);
    canvas.drawCircle(Offset(size.width,       size.height - 7),   r, paint);
  }

  @override
  bool shouldRepaint(_ResizeHandlePainter old) => old.color != color;
}


