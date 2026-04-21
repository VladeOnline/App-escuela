import 'package:flutter/material.dart';
import '../../domain/entities/individual_report_entity.dart';
import '../../domain/entities/grade_report_entity.dart';
import '../../domain/entities/progress_chart_entity.dart';
import '../../domain/entities/historial_entity.dart';
import '../../domain/repositories/report_repository.dart';

/// Estado de la solicitud de reporte
enum ReportLoadState { idle, loading, success, error }

/// Notifier para gestionar el estado de reportes individuales
class IndividualReportNotifier extends ChangeNotifier {
  final ReportRepository _repository;

  IndividualReportNotifier(this._repository);

  IndividualReportEntity? _report;
  ReportLoadState _state = ReportLoadState.idle;
  String? _error;

  /// Getters
  IndividualReportEntity? get report => _report;
  ReportLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == ReportLoadState.loading;

  /// Obtener reporte individual de un estudiante
  Future<void> getIndividualReport(String estudianteId) async {
    _state = ReportLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _report = await _repository.getIndividualReport(estudianteId);
      _state = ReportLoadState.success;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _state = ReportLoadState.error;
      notifyListeners();
    }
  }

  /// Limpiar estado
  void clear() {
    _report = null;
    _state = ReportLoadState.idle;
    _error = null;
    notifyListeners();
  }
}

/// Notifier para reportes por grado
class GradeReportNotifier extends ChangeNotifier {
  final ReportRepository _repository;

  GradeReportNotifier(this._repository);

  GradeReportEntity? _report;
  ReportLoadState _state = ReportLoadState.idle;
  String? _error;

  GradeReportEntity? get report => _report;
  ReportLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == ReportLoadState.loading;

  Future<void> getGradeReport(int grado) async {
    _state = ReportLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _report = await _repository.getGradeReport(grado);
      _state = ReportLoadState.success;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _state = ReportLoadState.error;
      notifyListeners();
    }
  }

  void clear() {
    _report = null;
    _state = ReportLoadState.idle;
    _error = null;
    notifyListeners();
  }
}

/// Notifier para gráficas de progreso
class ProgressChartNotifier extends ChangeNotifier {
  final ReportRepository _repository;

  ProgressChartNotifier(this._repository);

  ProgressChartEntity? _chart;
  ReportLoadState _state = ReportLoadState.idle;
  String? _error;

  ProgressChartEntity? get chart => _chart;
  ReportLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == ReportLoadState.loading;

  Future<void> getProgressChart(String estudianteId) async {
    _state = ReportLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _chart = await _repository.getProgressChart(estudianteId);
      _state = ReportLoadState.success;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _state = ReportLoadState.error;
      notifyListeners();
    }
  }

  void clear() {
    _chart = null;
    _state = ReportLoadState.idle;
    _error = null;
    notifyListeners();
  }
}

/// Notifier para historial de evaluaciones
class HistorialNotifier extends ChangeNotifier {
  final ReportRepository _repository;

  HistorialNotifier(this._repository);

  HistorialEvaluacionesEntity? _historial;
  ReportLoadState _state = ReportLoadState.idle;
  String? _error;

  HistorialEvaluacionesEntity? get historial => _historial;
  ReportLoadState get state => _state;
  String? get error => _error;
  bool get isLoading => _state == ReportLoadState.loading;

  Future<void> getHistorial(String estudianteId) async {
    _state = ReportLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _historial = await _repository.getHistorialEvaluaciones(estudianteId);
      _state = ReportLoadState.success;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _state = ReportLoadState.error;
      notifyListeners();
    }
  }

  void clear() {
    _historial = null;
    _state = ReportLoadState.idle;
    _error = null;
    notifyListeners();
  }
}
