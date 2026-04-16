import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_failure.dart';

enum RankingPeriod { semana, mes, total }

extension RankingPeriodX on RankingPeriod {
  String get value => name;
  String get label => switch (this) {
        RankingPeriod.semana => 'Esta semana',
        RankingPeriod.mes => 'Este mes',
        RankingPeriod.total => 'Total',
      };
}

class RankingEntry {
  final String estudianteId;
  final String nombre;
  final String? fotoUrl;
  final int puntos;
  final int posicion;

  const RankingEntry({
    required this.estudianteId,
    required this.nombre,
    this.fotoUrl,
    required this.puntos,
    required this.posicion,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) => RankingEntry(
        estudianteId: json['estudiante_id']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        fotoUrl: json['foto_url']?.toString(),
        puntos: json['puntos'] is int
            ? json['puntos'] as int
            : int.tryParse('${json['puntos'] ?? ''}') ?? 0,
        posicion: json['posicion'] is int
            ? json['posicion'] as int
            : int.tryParse('${json['posicion'] ?? ''}') ?? 0,
      );
}

class RankingResult {
  final List<RankingEntry> entries;
  final RankingPeriod period;
  final int grade;
  final int totalStudents;
  final AppFailure? failure;

  const RankingResult({
    required this.entries,
    required this.period,
    required this.grade,
    required this.totalStudents,
    this.failure,
  });

  static RankingResult empty(RankingPeriod period, int grade) => RankingResult(
        entries: [],
        period: period,
        grade: grade,
        totalStudents: 0,
      );
}

class StudentPosition {
  final int? posicion;
  final int puntos;
  final int totalEstudiantes;

  const StudentPosition({
    this.posicion,
    required this.puntos,
    required this.totalEstudiantes,
  });

  factory StudentPosition.fromJson(Map<String, dynamic> json) => StudentPosition(
        posicion: json['posicion'] is int
            ? json['posicion'] as int
            : int.tryParse('${json['posicion'] ?? ''}'),
        puntos: json['puntos'] is int
            ? json['puntos'] as int
            : int.tryParse('${json['puntos'] ?? ''}') ?? 0,
        totalEstudiantes: json['total_estudiantes'] is int
            ? json['total_estudiantes'] as int
            : int.tryParse('${json['total_estudiantes'] ?? ''}') ?? 0,
      );
}

class RankingRepository {
  final String token;
  RankingRepository({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<RankingResult> getRanking({
    required int grade,
    required RankingPeriod period,
    int top = 10,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/ranking').replace(
        queryParameters: {
          'grado': grade.toString(),
          'periodo': period.value,
          'top': top.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lista = (data['ranking'] as List).cast<Map<String, dynamic>>();
        final entries = lista.map(RankingEntry.fromJson).toList();
        return RankingResult(
          entries: entries,
          period: period,
          grade: grade,
          totalStudents: (data['total_estudiantes'] as int?) ?? entries.length,
        );
      }

      return RankingResult(
        entries: [],
        period: period,
        grade: grade,
        totalStudents: 0,
        failure: _failureFrom(response, 'Error al cargar el ranking'),
      );
    } catch (_) {
      return RankingResult(
        entries: [],
        period: period,
        grade: grade,
        totalStudents: 0,
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  Future<({Map<RankingPeriod, StudentPosition> positions, AppFailure? failure})>
      getStudentPositions({
    required String studentId,
    required int grade,
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseUrl}/ranking/posicion').replace(
        queryParameters: {
          'estudiante_id': studentId,
          'grado': grade.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final posData = (data['posiciones'] as Map).cast<String, dynamic>();
        final positions = <RankingPeriod, StudentPosition>{};

        for (final period in RankingPeriod.values) {
          final raw = (posData[period.value] as Map?)?.cast<String, dynamic>();
          if (raw != null) {
            positions[period] = StudentPosition.fromJson(raw);
          }
        }

        return (positions: positions, failure: null);
      }

      return (
        positions: <RankingPeriod, StudentPosition>{},
        failure: _failureFrom(response, 'Error al obtener posición'),
      );
    } catch (_) {
      return (
        positions: <RankingPeriod, StudentPosition>{},
        failure: const ServerFailure('Sin conexión al servidor'),
      );
    }
  }

  AppFailure _failureFrom(http.Response r, String fallback) {
    try {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final msg = data['mensaje']?.toString() ?? data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return ServerFailure(msg);
    } catch (_) {}
    return ServerFailure(fallback);
  }
}
