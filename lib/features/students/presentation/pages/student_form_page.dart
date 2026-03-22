import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/grade_badge.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/validate_student_usecase.dart';
import '../notifiers/students_notifier.dart';

/// Formulario para crear (RF-01) o editar (RF-02) un estudiante.
/// Con validaciones en tiempo real y feedback visual claro.
class StudentFormPage extends StatefulWidget {
  const StudentFormPage({
    super.key,
    required this.notifier,
    this.student,
  });

  final StudentsNotifier notifier;
  final StudentEntity? student;

  bool get isEditing => student != null;

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _validator = const ValidateStudentUseCase();

  int? _selectedGrade;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nameController.text = widget.student!.fullName;
      _ageController.text = widget.student!.age.toString();
      _selectedGrade = widget.student!.grade;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGrade == null) {
      AppSnackbar.showWarning(context, 'Selecciona un grado académico');
      return;
    }

    setState(() => _isLoading = true);

    bool success;
    if (widget.isEditing) {
      success = await widget.notifier.updateStudent(
        id: widget.student!.id,
        fullName: _nameController.text,
        ageText: _ageController.text,
        grade: _selectedGrade,
      );
    } else {
      success = await widget.notifier.createStudent(
        fullName: _nameController.text,
        ageText: _ageController.text,
        grade: _selectedGrade,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final failure = widget.notifier.state.failure;
      if (failure != null) {
        AppSnackbar.showError(context, failure.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Editar estudiante' : 'Nuevo estudiante';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header del formulario
                      _FormHeader(isEditing: widget.isEditing),
                      const SizedBox(height: AppSpacing.xl),

                      // Campo nombre completo
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          hintText: 'Ej: María González Pérez',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          final failure = _validator.validateField(
                              'fullName', value ?? '');
                          return failure?.message;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Campo edad
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Edad',
                          hintText:
                              '${AppConstants.minAge} - ${AppConstants.maxAge} años',
                          prefixIcon:
                              const Icon(Icons.cake_outlined),
                          suffixText: 'años',
                        ),
                        validator: (value) {
                          final failure =
                              _validator.validateField('age', value ?? '');
                          return failure?.message;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Selector de grado (RF-04)
                      Text(
                        'Grado académico',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _GradeSelector(
                        selectedGrade: _selectedGrade,
                        onChanged: (grade) =>
                            setState(() => _selectedGrade = grade),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onSubmit,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(widget.isEditing
                                      ? 'Guardar cambios'
                                      : 'Registrar estudiante'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header del formulario ────────────────────────────────────────────────────

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.isEditing});
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.all(AppRadius.medium),
          ),
          child: Icon(
            isEditing
                ? Icons.edit_rounded
                : Icons.person_add_alt_1_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar información' : 'Registrar estudiante',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                isEditing
                    ? 'Modifica los datos del estudiante'
                    : 'Completa todos los campos obligatorios',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Selector de grado ────────────────────────────────────────────────────────

class _GradeSelector extends StatelessWidget {
  const _GradeSelector({
    required this.selectedGrade,
    required this.onChanged,
  });

  final int? selectedGrade;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppConstants.grades.map((grade) {
        final isSelected = selectedGrade == grade;
        final color = AppColors.forGrade(grade);
        final label =
            AppConstants.gradeLabels[grade] ?? '$grade° grado';

        return GestureDetector(
          onTap: () => onChanged(grade),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.12) : Colors.white,
              borderRadius: const BorderRadius.all(AppRadius.full),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: Icon(Icons.check_circle_rounded,
                        size: 14, color: color),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
