import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';

/// Página para crear un nuevo ejercicio (RF-09, RF-11, RF-12).
///
/// El docente elige tipo de ejercicio y completa los campos correspondientes.
/// Cuando el Back esté listo, el repositorio mock se reemplaza con la API real.
class ExerciseFormPage extends StatefulWidget {
  const ExerciseFormPage({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.repository,
  });

  final String moduleId;
  final String moduleTitle;
  final MockModuleRepository repository;

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  final _uuid = const Uuid();

  // Campos comunes
  final _titleController = TextEditingController();
  final _instructionsController = TextEditingController();
  ExerciseType _type = ExerciseType.multipleChoice;
  DifficultyLevel _difficulty = DifficultyLevel.basic;

  // Campos de selección múltiple
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  int _correctOptionIndex = 0;
  final _explanationController = TextEditingController();

  // Campos de V/F
  final _statementController = TextEditingController();
  bool _correctBoolAnswer = true;

  // Campos de completar espacio
  final _templateController = TextEditingController();
  final _blankAnswerController = TextEditingController();
  final _hintController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    _explanationController.dispose();
    _statementController.dispose();
    _templateController.dispose();
    _blankAnswerController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildContent() {
    return switch (_type) {
      ExerciseType.multipleChoice => {
          'question': _questionController.text.trim(),
          'options':
              _optionControllers.map((c) => c.text.trim()).toList(),
          'correctIndex': _correctOptionIndex,
          if (_explanationController.text.trim().isNotEmpty)
            'explanation': _explanationController.text.trim(),
        },
      ExerciseType.trueOrFalse => {
          'statement': _statementController.text.trim(),
          'correctAnswer': _correctBoolAnswer,
        },
      ExerciseType.fillInTheBlank => {
          'template': _templateController.text.trim(),
          'correctAnswer': _blankAnswerController.text.trim(),
          if (_hintController.text.trim().isNotEmpty)
            'hint': _hintController.text.trim(),
        },
      ExerciseType.ordering => {
          // TODO: implementar UI de ordenamiento en sprint futuro
          'words': <String>[],
          'correctOrder': <String>[],
        },
    };
  }

  String? _validate() {
    if (_titleController.text.trim().isEmpty) {
      return 'El título del ejercicio es obligatorio.';
    }
    if (_instructionsController.text.trim().isEmpty) {
      return 'Las instrucciones son obligatorias.';
    }
    switch (_type) {
      case ExerciseType.multipleChoice:
        if (_questionController.text.trim().isEmpty) {
          return 'La pregunta es obligatoria.';
        }
        if (_optionControllers.any((c) => c.text.trim().isEmpty)) {
          return 'Todas las opciones deben tener texto.';
        }
      case ExerciseType.trueOrFalse:
        if (_statementController.text.trim().isEmpty) {
          return 'La afirmación es obligatoria.';
        }
      case ExerciseType.fillInTheBlank:
        if (!_templateController.text.contains('[BLANK]')) {
          return 'El texto debe contener [BLANK] para indicar el espacio.';
        }
        if (_blankAnswerController.text.trim().isEmpty) {
          return 'La respuesta correcta es obligatoria.';
        }
      case ExerciseType.ordering:
        break;
    }
    return null;
  }

  Future<void> _onSave() async {
    final error = _validate();
    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }

    setState(() => _isLoading = true);

    final exercise = ExerciseEntity(
      id: _uuid.v4(),
      moduleId: widget.moduleId,
      title: _titleController.text.trim(),
      instructions: _instructionsController.text.trim(),
      type: _type,
      difficulty: _difficulty,
      content: _buildContent(),
    );

    await widget.repository.createExercise(exercise);

    if (!mounted) return;
    setState(() => _isLoading = false);
    AppSnackbar.showSuccess(context, 'Ejercicio creado correctamente');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Nuevo ejercicio — ${widget.moduleTitle}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _onSave,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: const Text('Guardar ejercicio'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Sección 1: Datos generales ──
                _SectionCard(
                  title: 'Datos generales',
                  icon: Icons.info_outline_rounded,
                  children: [
                    _FormField(
                      label: 'Título del ejercicio *',
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: 'Ej: ¿De qué trata el cuento?',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _FormField(
                      label: 'Instrucciones para el estudiante *',
                      child: TextField(
                        controller: _instructionsController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText:
                              'Ej: Lee el texto con atención y selecciona la respuesta correcta.',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                            label: 'Tipo de ejercicio *',
                            child: _TypeDropdown(
                              value: _type,
                              onChanged: (v) =>
                                  setState(() => _type = v!),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _FormField(
                            label: 'Nivel de dificultad *',
                            child: _DifficultyDropdown(
                              value: _difficulty,
                              onChanged: (v) =>
                                  setState(() => _difficulty = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DifficultyPointsBadge(level: _difficulty),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Sección 2: Contenido según tipo ──
                _SectionCard(
                  title: 'Contenido del ejercicio',
                  icon: Icons.edit_note_rounded,
                  children: [_buildContentSection()],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return switch (_type) {
      ExerciseType.multipleChoice => _MultipleChoiceForm(
          questionController: _questionController,
          optionControllers: _optionControllers,
          correctIndex: _correctOptionIndex,
          onCorrectChanged: (i) =>
              setState(() => _correctOptionIndex = i),
          explanationController: _explanationController,
        ),
      ExerciseType.trueOrFalse => _TrueOrFalseForm(
          statementController: _statementController,
          correctAnswer: _correctBoolAnswer,
          onAnswerChanged: (v) =>
              setState(() => _correctBoolAnswer = v),
        ),
      ExerciseType.fillInTheBlank => _FillInTheBlankForm(
          templateController: _templateController,
          answerController: _blankAnswerController,
          hintController: _hintController,
        ),
      ExerciseType.ordering => _OrderingComingSoon(),
    };
  }
}

// ─── Formularios por tipo de ejercicio ────────────────────────────────────────

class _MultipleChoiceForm extends StatelessWidget {
  const _MultipleChoiceForm({
    required this.questionController,
    required this.optionControllers,
    required this.correctIndex,
    required this.onCorrectChanged,
    required this.explanationController,
  });

  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  final int correctIndex;
  final ValueChanged<int> onCorrectChanged;
  final TextEditingController explanationController;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormField(
          label: 'Pregunta *',
          child: TextField(
            controller: questionController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Ej: ¿Qué hizo el personaje al llegar a la escuela?',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Opciones de respuesta *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Selecciona cuál es la respuesta correcta con el botón de la izquierda.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(4, (i) {
          final isCorrect = correctIndex == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                // Radio de selección correcta
                GestureDetector(
                  onTap: () => onCorrectChanged(i),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCorrect
                          ? AppColors.success
                          : Colors.transparent,
                      border: Border.all(
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isCorrect
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : Center(
                            child: Text(
                              _letters[i],
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: optionControllers[i],
                    decoration: InputDecoration(
                      hintText: 'Opción ${_letters[i]}',
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(AppRadius.medium),
                        borderSide: BorderSide(
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        _FormField(
          label: 'Explicación (opcional)',
          hint: 'Se mostrará al estudiante después de responder.',
          child: TextField(
            controller: explanationController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Ej: La letra mayúscula se usa al inicio de oración.',
            ),
          ),
        ),
      ],
    );
  }
}

class _TrueOrFalseForm extends StatelessWidget {
  const _TrueOrFalseForm({
    required this.statementController,
    required this.correctAnswer,
    required this.onAnswerChanged,
  });

  final TextEditingController statementController;
  final bool correctAnswer;
  final ValueChanged<bool> onAnswerChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormField(
          label: 'Afirmación *',
          hint: 'Escribe la oración que el estudiante debe evaluar.',
          child: TextField(
            controller: statementController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Ej: Los nombres propios siempre se escriben con mayúscula.',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Respuesta correcta *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _SelectableTile(
                label: 'Verdadero',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                selected: correctAnswer,
                onTap: () => onAnswerChanged(true),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SelectableTile(
                label: 'Falso',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                selected: !correctAnswer,
                onTap: () => onAnswerChanged(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FillInTheBlankForm extends StatelessWidget {
  const _FillInTheBlankForm({
    required this.templateController,
    required this.answerController,
    required this.hintController,
  });

  final TextEditingController templateController;
  final TextEditingController answerController;
  final TextEditingController hintController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormField(
          label: 'Texto con espacio en blanco *',
          hint: 'Usa [BLANK] para indicar dónde va el espacio.',
          child: TextField(
            controller: templateController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Ej: Lucía caminó hacia la [BLANK] después de desayunar.',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _FormField(
          label: 'Respuesta correcta *',
          child: TextField(
            controller: answerController,
            decoration: const InputDecoration(
              hintText: 'Ej: escuela',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _FormField(
          label: 'Pista para el estudiante (opcional)',
          child: TextField(
            controller: hintController,
            decoration: const InputDecoration(
              hintText: 'Ej: Es el lugar donde van los niños a aprender.',
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderingComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.06),
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.construction_rounded,
              color: AppColors.secondary, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ordenamiento — Próximo sprint',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.secondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Este tipo de ejercicio estará disponible en el siguiente sprint.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Widgets de UI compartidos ────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: const BorderRadius.all(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                  top: AppRadius.large),
              border: Border(
                  bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.child,
    this.hint,
  });

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  )),
        ],
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.value, required this.onChanged});
  final ExerciseType value;
  final ValueChanged<ExerciseType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ExerciseType>(
      value: value,
      onChanged: onChanged,
      decoration: const InputDecoration(),
      items: ExerciseType.values
          .map((t) => DropdownMenuItem(
                value: t,
                child: Text(t.label),
              ))
          .toList(),
    );
  }
}

class _DifficultyDropdown extends StatelessWidget {
  const _DifficultyDropdown(
      {required this.value, required this.onChanged});
  final DifficultyLevel value;
  final ValueChanged<DifficultyLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DifficultyLevel>(
      value: value,
      onChanged: onChanged,
      decoration: const InputDecoration(),
      items: DifficultyLevel.values
          .map((d) => DropdownMenuItem(
                value: d,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: d.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(d.label),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _DifficultyPointsBadge extends StatelessWidget {
  const _DifficultyPointsBadge({required this.level});
  final DifficultyLevel level;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.stars_rounded, color: AppColors.secondary, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Este ejercicio otorgará ${level.basePoints} puntos al completarlo correctamente.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.10) : Colors.transparent,
          borderRadius: const BorderRadius.all(AppRadius.medium),
          border: Border.all(
              color: selected ? color : AppColors.border, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? color : AppColors.textHint),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: selected ? color : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
