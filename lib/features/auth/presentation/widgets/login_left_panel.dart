import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LoginLeftPanel extends StatelessWidget {
  const LoginLeftPanel({super.key});

  static const _features = [
    (Icons.people_alt_rounded,   'Gestión de estudiantes', 'Registra, edita y organiza por grado'),
    (Icons.menu_book_rounded,    'Contenido por grado',    'Ejercicios y evaluaciones digitales'),
    (Icons.emoji_events_rounded, 'Gamificación educativa', 'Puntos, insignias y rankings internos'),
    (Icons.bar_chart_rounded,    'Seguimiento académico',  'Reportes y progreso individual'),
  ];

  static const _decorCircles = [
    (bottom: -60.0,  right: -60.0, left: double.nan, size: 220.0, opacity: 0.06),
    (bottom: 180.0,  right: double.nan, left: -40.0,  size: 130.0, opacity: 0.05),
    (bottom: 80.0,   right: 30.0,  left: double.nan, size: 60.0,  opacity: 0.07),
    (bottom: 320.0,  right: -20.0, left: double.nan, size: 90.0,  opacity: 0.04),
  ];

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final panelW  = _panelWidth(MediaQuery.of(context).size.width);
    final imageH  = screenH * 0.47;

    return SizedBox(
      width: panelW,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.primary, AppColors.primaryDark],
            stops: [0.44, 0.50, 1.0],
          ),
          boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(4, 0))],
        ),
        child: Stack(
          children: [
            // Decoración
            ..._buildDecor(),

            // Contenido
            Column(children: [
              _ClassroomImage(height: imageH, width: panelW),
              const Expanded(child: _InfoSection()),
            ]),

            // Ola
            Positioned(
              top: imageH - 150, left: 0, right: 0,
              child: _WaveTransition(width: panelW),
            ),

            // Logo
            Positioned(
              top: imageH - 90,
              left: panelW * 0.16,
              child: const _AppLogo(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecor() => [
    const Positioned(bottom: -60, right: -60, child: _DecorShape(size: 220, opacity: 0.06)),
    const Positioned(bottom: 180, left: -40,  child: _DecorShape(size: 130, opacity: 0.05)),
    const Positioned(bottom: 80,  right: 30,  child: _DecorShape(size: 60,  opacity: 0.07)),
    const Positioned(bottom: 320, right: -20, child: _DecorShape(size: 90,  opacity: 0.04)),
    Positioned(
      bottom: 260, left: 20,
      child: Transform.rotate(angle: 0.4, child: const _DecorShape(size: 40, opacity: 0.05, isRect: true)),
    ),
    Positioned(
      bottom: 140, right: 60,
      child: Transform.rotate(angle: -0.6, child: const _DecorShape(size: 24, opacity: 0.06, isRect: true)),
    ),
  ];

  double _panelWidth(double w) => w < 900 ? w * 0.38 : w < 1200 ? 420 : 480;
}

// ─── Decoración ───

class _DecorShape extends StatelessWidget {
  const _DecorShape({required this.size, required this.opacity, this.isRect = false});
  final double size;
  final double opacity;
  final bool isRect;

  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: isRect ? BoxShape.rectangle : BoxShape.circle,
      borderRadius: isRect ? BorderRadius.circular(4) : null,
      border: Border.all(color: Colors.white.withOpacity(opacity * 1.5), width: 1.5),
      color: Colors.white.withOpacity(opacity),
    ),
  );
}

// ─── Imagen ───

class _ClassroomImage extends StatelessWidget {
  const _ClassroomImage({required this.height, required this.width});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height, width: width,
    child: Image.asset(
      'assets/images/classroom.png',
      fit: BoxFit.cover,
      alignment: const Alignment(0, 0.2),
      errorBuilder: (_, __, ___) => Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primaryLight],
          ),
        ),
        child: const Center(child: Icon(Icons.school_rounded, color: Colors.white, size: 64)),
      ),
    ),
  );
}

// ─── Ola ───

class _WaveTransition extends StatelessWidget {
  const _WaveTransition({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width, height: 200,
    child: CustomPaint(painter: _WavePainter()),
  );
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
    final base  = size.height * 0.42;
    final dotX  = size.width  * 0.80;
    final dotDip = size.height * 0.14;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, base * 0.6)
      ..cubicTo(size.width * 0.90, base * 0.6,  size.width * 0.90, base + dotDip,        dotX,              base + dotDip)
      ..cubicTo(size.width * 0.68, base + dotDip, size.width * 0.62, base - size.height * 0.12, size.width * 0.52, base - size.height * 0.12)
      ..cubicTo(size.width * 0.42, base - size.height * 0.12, size.width * 0.39, base + size.height * 0.25, size.width * 0.21, base + size.height * 0.25)
      ..cubicTo(size.width * 0.14, base + size.height * 0.25, 0, base * 0.8, 0, base * 0.8)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(dotX, base + dotDip * 0.1), 13,
      Paint()..color = const Color(0xFFF1F8F8)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) => false;
}

// ─── Logo ───

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) => Container(
    width: 64, height: 64,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: const BorderRadius.all(AppRadius.large),
      boxShadow: [BoxShadow(color: AppColors.primaryDark.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
    ),
    child: const Icon(Icons.school_rounded, color: Colors.white, size: 36),
  );
}

// ─── Info ───

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  static const _features = [
    (Icons.people_alt_rounded,   'Gestión de estudiantes', 'Registra, edita y organiza por grado'),
    (Icons.menu_book_rounded,    'Contenido por grado',    'Ejercicios y evaluaciones digitales'),
    (Icons.emoji_events_rounded, 'Gamificación educativa', 'Puntos, insignias y rankings internos'),
    (Icons.bar_chart_rounded,    'Seguimiento académico',  'Reportes y progreso individual'),
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sistema de Refuerzo Escolar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Nunito', color: Colors.white, height: 1.2)),
        const SizedBox(height: AppSpacing.sm),
        Text('Aprendiendo juntos cada día',
          style: TextStyle(fontSize: 13, fontFamily: 'Nunito', color: Colors.white.withOpacity(0.75), fontStyle: FontStyle.italic)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(children: [
            _dividerLine(82), const SizedBox(width: AppSpacing.sm),
            _dot(), const SizedBox(width: AppSpacing.sm),
            _dividerLine(82),
          ]),
        ),
        Text('Una herramienta pensada para apoyar a docentes y estudiantes de escuelas unidocentes en Costa Rica.',
          style: TextStyle(fontSize: 13, fontFamily: 'Nunito', color: Colors.white.withOpacity(0.85), height: 1.6)),
        const SizedBox(height: AppSpacing.xl),
        Text('TODO LO QUE NECESITAS',
          style: TextStyle(fontSize: 11, fontFamily: 'Nunito', color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w700, letterSpacing: 1.8)),
        const SizedBox(height: AppSpacing.md),
        ..._features.map(_buildFeature),
      ],
    ),
  );

  Widget _buildFeature((IconData, String, String) item) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: const BorderRadius.all(AppRadius.medium),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(item.$1, color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: Colors.white)),
            Text(item.$3, style: TextStyle(fontSize: 11, fontFamily: 'Nunito', color: Colors.white.withOpacity(0.65), height: 1.4)),
          ],
        )),
      ],
    ),
  );

  Widget _dividerLine(double w) => Container(
    width: w, height: 2,
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
  );

  Widget _dot() => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
  );
}