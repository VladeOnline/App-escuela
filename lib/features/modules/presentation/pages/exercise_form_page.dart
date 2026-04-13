import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../data/repositories/api_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/exercise_form/form_background.dart';
import '../widgets/exercise_form/form_chrome.dart';
import '../widgets/exercise_form/form_dropdowns.dart';
import '../widgets/exercise_form/form_shared.dart';
import '../widgets/exercise_form/multiple_choice_form.dart';
import '../widgets/exercise_form/other_forms.dart';
import '../widgets/exercise_form/resizable_text_area.dart';

class ExerciseFormPage extends StatefulWidget {
  const ExerciseFormPage({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.repository,
    this.preselectedLevel,
    this.exerciseToEdit,
  });

  final String moduleId;
  final String moduleTitle;
  final ApiModuleRepository repository; // CAMBIO: Api en vez de Mock
  final DifficultyLevel? preselectedLevel;

  /// Si no es null, la página entra en modo edición con estos datos cargados.
  final ExerciseEntity? exerciseToEdit;

  bool get isEditing => exerciseToEdit != null;

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  final _uuid = const Uuid();

  // --- Controllers comunes ---
  final _titleCtrl        = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  ExerciseType    _type       = ExerciseType.multipleChoice;
  DifficultyLevel _difficulty = DifficultyLevel.basic;
  Subject         _subject    = Subject.spanish;

  // --- Selección múltiple ---
  final _questionCtrl    = TextEditingController();
  List<TextEditingController> _optionCtrls = List.generate(3, (_) => TextEditingController());
  int  _correctIndex     = 0;
  final _explanationCtrl = TextEditingController();

  // --- Verdadero / Falso ---
  final _statementCtrl   = TextEditingController();
  bool _correctBool      = true;

  // --- Completar espacio ---
  final _templateCtrl    = TextEditingController();
  final _blankAnswerCtrl = TextEditingController();
  final _hintCtrl        = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final ex = widget.exerciseToEdit;
    if (ex != null) {
      _loadExerciseData(ex);
    } else if (widget.preselectedLevel != null) {
      _difficulty = widget.preselectedLevel!;
    }
  }

  /// Carga los datos del ejercicio a editar en todos los controllers y estado.
  void _loadExerciseData(ExerciseEntity ex) {
    _titleCtrl.text        = ex.title;
    _instructionsCtrl.text = ex.instructions;
    _type                  = ex.type;
    _difficulty            = ex.difficulty;
    _subject               = ex.subject;

    final c = ex.content;
    switch (ex.type) {
      case ExerciseType.multipleChoice:
        _questionCtrl.text = c['question'] as String? ?? '';
        final opts = (c['options'] as List?)?.cast<String>() ?? [];
        // Disponer los controllers anteriores y crear nuevos con los valores
        for (final ctrl in _optionCtrls) ctrl.dispose();
        _optionCtrls = opts.isEmpty
            ? List.generate(3, (_) => TextEditingController())
            : opts.map((o) => TextEditingController(text: o)).toList();
        _correctIndex      = c['correctIndex'] as int? ?? 0;
        _explanationCtrl.text = c['explanation'] as String? ?? '';

      case ExerciseType.trueOrFalse:
        _statementCtrl.text = c['statement'] as String? ?? '';
        _correctBool        = c['correctAnswer'] as bool? ?? true;

      case ExerciseType.fillInTheBlank:
        _templateCtrl.text    = c['template'] as String? ?? '';
        _blankAnswerCtrl.text = c['correctAnswer'] as String? ?? '';
        _hintCtrl.text        = c['hint'] as String? ?? '';

      case ExerciseType.ordering:
        break;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl, _instructionsCtrl, _questionCtrl, _explanationCtrl,
      _statementCtrl, _templateCtrl, _blankAnswerCtrl, _hintCtrl,
      ..._optionCtrls,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // --- Opciones dinámicas ---

  void _addOption() => setState(() => _optionCtrls.add(TextEditingController()));

  void _removeOption(int i) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls[i].dispose();
      _optionCtrls.removeAt(i);
      if (_correctIndex >= _optionCtrls.length) _correctIndex = _optionCtrls.length - 1;
    });
  }

  // --- Limpiar ---

  void _onClear() {
    for (final c in [
      _titleCtrl, _instructionsCtrl, _questionCtrl, _explanationCtrl,
      _statementCtrl, _templateCtrl, _blankAnswerCtrl, _hintCtrl,
      ..._optionCtrls,
    ]) {
      c.clear();
    }
    setState(() { _correctIndex = 0; _correctBool = true; });
  }

  // --- Validación y guardado ---

  Map<String, dynamic> _buildContent() => switch (_type) {
        ExerciseType.multipleChoice => {
            'question': _questionCtrl.text.trim(),
            'options': _optionCtrls.map((c) => c.text.trim()).toList(),
            'correctIndex': _correctIndex,
            if (_explanationCtrl.text.trim().isNotEmpty)
              'explanation': _explanationCtrl.text.trim(),
          },
        ExerciseType.trueOrFalse    => {
            'statement': _statementCtrl.text.trim(),
            'correctAnswer': _correctBool,
          },
        ExerciseType.fillInTheBlank => {
            'template': _templateCtrl.text.trim(),
            'correctAnswer': _blankAnswerCtrl.text.trim(),
            if (_hintCtrl.text.trim().isNotEmpty) 'hint': _hintCtrl.text.trim(),
          },
        ExerciseType.ordering       => {
            'words': <String>[],
            'correctOrder': <String>[],
          },
      };

  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty)        return 'El título del ejercicio es obligatorio.';
    if (_instructionsCtrl.text.trim().isEmpty) return 'Las instrucciones son obligatorias.';
    switch (_type) {
      case ExerciseType.multipleChoice:
        if (_questionCtrl.text.trim().isEmpty)              return 'La pregunta es obligatoria.';
        if (_optionCtrls.any((c) => c.text.trim().isEmpty)) return 'Todas las opciones deben tener texto.';
      case ExerciseType.trueOrFalse:
        if (_statementCtrl.text.trim().isEmpty)             return 'La afirmación es obligatoria.';
      case ExerciseType.fillInTheBlank:
        if (!_templateCtrl.text.contains('[BLANK]'))        return 'El texto debe contener [BLANK].';
        if (_blankAnswerCtrl.text.trim().isEmpty)           return 'La respuesta correcta es obligatoria.';
      case ExerciseType.ordering:
        break;
    }
    return null;
  }

  Future<void> _onSave() async {
    final error = _validate();
    if (error != null) { AppSnackbar.showError(context, error); return; }
    setState(() => _isLoading = true);

    final exercise = ExerciseEntity(
      id: widget.exerciseToEdit?.id ?? _uuid.v4(),
      moduleId: widget.moduleId,
      title: _titleCtrl.text.trim(),
      instructions: _instructionsCtrl.text.trim(),
      type: _type,
      difficulty: _difficulty,
      subject: _subject,
      isActive: widget.exerciseToEdit?.isActive ?? true,
      content: _buildContent(),
    );

    if (widget.isEditing) {
      final result = await widget.repository.updateExercise(exercise);
      if (!mounted) return;
      if (result.failure != null) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, result.failure!.message);
        return;
      }
    } else {
      final result = await widget.repository.createExercise(exercise);
      if (!mounted) return;
      if (result.failure != null) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, result.failure!.message);
        return;
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    AppSnackbar.showSuccess(
      context,
      widget.isEditing ? 'Ejercicio actualizado correctamente' : 'Ejercicio creado correctamente',
    );
    Navigator.of(context).pop(true);
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ExFormBackground(),
          Column(
            children: [
              ExFormHeader(
                moduleTitle: widget.moduleTitle,
                isEditing: widget.isEditing,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - AppSpacing.lg,
                        ),
                        child: Align(
                          alignment: const Alignment(-0.2, 0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: constraints.maxWidth > 700
                                ? _buildWide()
                                : _buildNarrow(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ExFormFooter(
                isLoading: _isLoading,
                isEditing: widget.isEditing,
                onClear: _onClear,
                onSave: _onSave,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWide() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: ExFormBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(flex: 5, child: _generalCard()),
          const SizedBox(width: AppSpacing.lg),
          Flexible(flex: 5, child: _contentCard()),
        ],
      );

  Widget _buildNarrow() => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ExFormBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          const SizedBox(height: AppSpacing.md),
          _generalCard(),
          const SizedBox(height: AppSpacing.lg),
          _contentCard(),
          const SizedBox(height: AppSpacing.xl),
        ],
      );

  Widget _generalCard() => ExFormSectionCard(
        title: 'Datos generales',
        icon: Icons.info_outline_rounded,
        children: [
          ExFormFieldLabel(
            label: 'Título del ejercicio', required: true,
            child: TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Ej: ¿De qué trata el cuento?'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ExFormFieldLabel(
            label: 'Instrucciones para el estudiante', required: true,
            child: ExFormResizableTextArea(
              controller: _instructionsCtrl,
              hintText: 'Ej: Lee el texto con atención y selecciona la respuesta correcta.',
              minLines: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ExFormFieldLabel(
            label: 'Materia', required: true,
            child: ExFormSubjectDropdown(
              value: _subject,
              onChanged: (v) => setState(() => _subject = v!),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: ExFormFieldLabel(
              label: 'Tipo de ejercicio', required: true,
              child: ExFormTypeDropdown(
                value: _type,
                onChanged: (v) => setState(() => _type = v!),
              ),
            )),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: ExFormFieldLabel(
              label: 'Nivel de dificultad', required: true,
              child: ExFormDifficultyDropdown(
                value: _difficulty,
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
            )),
          ]),
          const SizedBox(height: AppSpacing.sm),
          ExFormDifficultyBadge(level: _difficulty),
        ],
      );

  Widget _contentCard() => ExFormSectionCard(
        title: 'Contenido del ejercicio',
        icon: Icons.edit_note_rounded,
        children: [_buildContentSection()],
      );

  Widget _buildContentSection() => switch (_type) {
        ExerciseType.multipleChoice => ExFormMultipleChoice(
            questionCtrl: _questionCtrl,
            optionCtrls: _optionCtrls,
            correctIndex: _correctIndex,
            onCorrectChanged: (i) => setState(() => _correctIndex = i),
            onAddOption: _addOption,
            onRemoveOption: _removeOption,
            explanationCtrl: _explanationCtrl,
          ),
        ExerciseType.trueOrFalse => ExFormTrueOrFalse(
            statementCtrl: _statementCtrl,
            correctAnswer: _correctBool,
            onAnswerChanged: (v) => setState(() => _correctBool = v),
          ),
        ExerciseType.fillInTheBlank => ExFormFillInBlank(
            templateCtrl: _templateCtrl,
            answerCtrl: _blankAnswerCtrl,
            hintCtrl: _hintCtrl,
          ),
        ExerciseType.ordering => const ExFormOrderingComingSoon(),
      };
}
