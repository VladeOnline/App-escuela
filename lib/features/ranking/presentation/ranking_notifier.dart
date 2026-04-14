import 'package:flutter/foundation.dart';

import '../data/ranking_repository.dart';

enum RankingStatus { idle, loading, loaded, failure }

@immutable
class RankingState {
  final RankingStatus status;
  final List<RankingEntry> entries;
  final RankingPeriod selectedPeriod;
  final int grade;
  final int totalStudents;
  final String? errorMessage;

  // Posición del estudiante actual (se carga aparte para el home del alumno)
  final Map<RankingPeriod, StudentPosition> studentPositions;

  const RankingState({
    this.status = RankingStatus.idle,
    this.entries = const [],
    this.selectedPeriod = RankingPeriod.semana,
    this.grade = 1,
    this.totalStudents = 0,
    this.errorMessage,
    this.studentPositions = const {},
  });

  RankingState copyWith({
    RankingStatus? status,
    List<RankingEntry>? entries,
    RankingPeriod? selectedPeriod,
    int? grade,
    int? totalStudents,
    String? errorMessage,
    Map<RankingPeriod, StudentPosition>? studentPositions,
  }) =>
      RankingState(
        status: status ?? this.status,
        entries: entries ?? this.entries,
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
        grade: grade ?? this.grade,
        totalStudents: totalStudents ?? this.totalStudents,
        errorMessage: errorMessage,
        studentPositions: studentPositions ?? this.studentPositions,
      );
}

class RankingNotifier extends ChangeNotifier {
  final RankingRepository _repo;

  RankingNotifier({required RankingRepository repository}) : _repo = repository;

  RankingState _state = const RankingState();
  RankingState get state => _state;

  void _emit(RankingState next) {
    _state = next;
    notifyListeners();
  }

  /// Carga el ranking para el grado y período actuales.
  Future<void> loadRanking({required int grade, RankingPeriod? period}) async {
    final targetPeriod = period ?? _state.selectedPeriod;

    _emit(
      _state.copyWith(
        status: RankingStatus.loading,
        grade: grade,
        selectedPeriod: targetPeriod,
        errorMessage: null,
      ),
    );

    final result = await _repo.getRanking(grade: grade, period: targetPeriod);

    if (result.failure != null) {
      _emit(
        _state.copyWith(
          status: RankingStatus.failure,
          errorMessage: result.failure!.message,
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        status: RankingStatus.loaded,
        entries: result.entries,
        totalStudents: result.totalStudents,
        grade: grade,
        selectedPeriod: targetPeriod,
      ),
    );
  }

  /// Cambia el período y recarga el ranking.
  Future<void> changePeriod(RankingPeriod period) async {
    if (_state.selectedPeriod == period && _state.status == RankingStatus.loaded) {
      return;
    }
    await loadRanking(grade: _state.grade, period: period);
  }

  /// Carga la posición del estudiante en los 3 períodos (para StudentHomePage).
  Future<void> loadStudentPositions({
    required String studentId,
    required int grade,
  }) async {
    final result = await _repo.getStudentPositions(
      studentId: studentId,
      grade: grade,
    );
    if (result.failure == null) {
      _emit(_state.copyWith(studentPositions: result.positions));
    }
  }
}
