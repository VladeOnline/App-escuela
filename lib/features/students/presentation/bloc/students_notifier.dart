import 'package:flutter/foundation.dart';

import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/validate_student_usecase.dart';
import '../../../../core/errors/app_failure.dart';

// ─────────────────────────────────────────────
// Estado
// ─────────────────────────────────────────────

enum StudentsStatus { initial, loading, success, failure }

@immutable
class StudentsState {
  final StudentsStatus status;
  final List<StudentEntity> students;
  final String searchQuery;
  final int? gradeFilter;
  final AppFailure? failure;
  final String? successMessage;

  const StudentsState({
    this.status = StudentsStatus.initial,
    this.students = const [],
    this.searchQuery = '',
    this.gradeFilter,
    this.failure,
    this.successMessage,
  });

  StudentsState copyWith({
    StudentsStatus? status,
    List<StudentEntity>? students,
    String? searchQuery,
    int? Function()? gradeFilter,
    AppFailure? failure,
    String? successMessage,
  }) {
    return StudentsState(
      status: status ?? this.status,
      students: students ?? this.students,
      searchQuery: searchQuery ?? this.searchQuery,
      gradeFilter: gradeFilter != null ? gradeFilter() : this.gradeFilter,
      failure: failure,
      successMessage: successMessage,
    );
  }

  bool get isEmpty => students.isEmpty;
  bool get isLoading => status == StudentsStatus.loading;
}

// ─────────────────────────────────────────────
// Notifier (ChangeNotifier — sin dependencias extra de BLoC pkg)
// El equipo puede migrarlo a flutter_bloc si ya lo tienen instalado.
// ─────────────────────────────────────────────

class StudentsNotifier extends ChangeNotifier {
  StudentsNotifier({
    required StudentRepository repository,
    required ValidateStudentUseCase validator,
  })  : _repository = repository,
        _validator = validator;

  final StudentRepository _repository;
  final ValidateStudentUseCase _validator;

  StudentsState _state = const StudentsState();
  StudentsState get state => _state;

  void _emit(StudentsState next) {
    _state = next;
    notifyListeners();
  }

  // ── RF-01 / RF-31: Cargar y buscar estudiantes ──

  Future<void> loadStudents() async {
    _emit(_state.copyWith(status: StudentsStatus.loading));
    final result = await _repository.getAll();
    if (result.failure != null) {
      _emit(_state.copyWith(
        status: StudentsStatus.failure,
        failure: result.failure,
      ));
    } else {
      _emit(_state.copyWith(
        status: StudentsStatus.success,
        students: result.students,
      ));
    }
  }

  Future<void> search({String? name, int? grade}) async {
    _emit(_state.copyWith(
      status: StudentsStatus.loading,
      searchQuery: name ?? _state.searchQuery,
      gradeFilter: () => grade,
    ));

    final result = await _repository.search(
      name: name ?? _state.searchQuery,
      grade: grade,
    );

    if (result.failure != null) {
      _emit(_state.copyWith(
        status: StudentsStatus.failure,
        failure: result.failure,
      ));
    } else {
      _emit(_state.copyWith(
        status: StudentsStatus.success,
        students: result.students,
      ));
    }
  }

  void clearFilters() {
    _emit(_state.copyWith(
      searchQuery: '',
      gradeFilter: () => null,
    ));
    loadStudents();
  }

  // ── RF-01: Registrar estudiante ──

  Future<bool> createStudent({
    required String fullName,
    required String ageText,
    required int? grade,
  }) async {
    final errors = _validator.validate(
      fullName: fullName,
      ageText: ageText,
      grade: grade,
    );
    if (errors.isNotEmpty) return false;

    _emit(_state.copyWith(status: StudentsStatus.loading));

    final result = await _repository.create(
      fullName: fullName,
      grade: grade!,
      age: int.parse(ageText.trim()),
    );

    if (result.failure != null) {
      _emit(_state.copyWith(
        status: StudentsStatus.failure,
        failure: result.failure,
      ));
      return false;
    }

    await loadStudents();
    _emit(_state.copyWith(
      successMessage: 'Estudiante registrado correctamente',
    ));
    return true;
  }

  // ── RF-02: Editar estudiante ──

  Future<bool> updateStudent({
    required String id,
    required String fullName,
    required String ageText,
    required int? grade,
  }) async {
    final errors = _validator.validate(
      fullName: fullName,
      ageText: ageText,
      grade: grade,
    );
    if (errors.isNotEmpty) return false;

    _emit(_state.copyWith(status: StudentsStatus.loading));

    final result = await _repository.update(
      id: id,
      fullName: fullName,
      grade: grade!,
      age: int.parse(ageText.trim()),
    );

    if (result.failure != null) {
      _emit(_state.copyWith(
        status: StudentsStatus.failure,
        failure: result.failure,
      ));
      return false;
    }

    await loadStudents();
    _emit(_state.copyWith(
      successMessage: 'Información actualizada correctamente',
    ));
    return true;
  }

  // ── RF-03: Eliminar estudiante ──

  Future<bool> deleteStudent(String id) async {
    _emit(_state.copyWith(status: StudentsStatus.loading));
    final result = await _repository.delete(id);

    if (result.failure != null) {
      _emit(_state.copyWith(
        status: StudentsStatus.failure,
        failure: result.failure,
      ));
      return false;
    }

    await loadStudents();
    _emit(_state.copyWith(
      successMessage: 'Estudiante eliminado del sistema',
    ));
    return true;
  }

  // ── RF-42: Desactivar estudiante ──

  Future<bool> deactivateStudent(String id) async {
    _emit(_state.copyWith(status: StudentsStatus.loading));
    final result = await _repository.deactivate(id);

    if (result.failure != null) {
      _emit(_state.copyWith(
        status: StudentsStatus.failure,
        failure: result.failure,
      ));
      return false;
    }

    await loadStudents();
    _emit(_state.copyWith(
      successMessage: 'Estudiante desactivado',
    ));
    return true;
  }

  void clearMessage() {
    _emit(_state.copyWith());
  }
}
