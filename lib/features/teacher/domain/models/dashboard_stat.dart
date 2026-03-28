import 'package:flutter/material.dart';

/// Modelo puro de una estadística del dashboard del docente.
///
/// Es inmutable y sin dependencias de UI — solo datos.
/// El Back reemplazará los valores mock por los reales de la API.
@immutable
class DashboardStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  /// Texto opcional debajo del valor (ej: "este año")
  final String? sublabel;

  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sublabel,
  });
}
