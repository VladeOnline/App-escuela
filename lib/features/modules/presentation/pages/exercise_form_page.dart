import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/app_snackbar.dart';
import '../../data/repositories/mock_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/exercise_form/form_background.dart';
import '../widgets/exercise_form/form_chrome.dart';
import '../widgets/exercise_form/form_dropdowns.dart';
import '../widgets/exercise_form/form_shared.dart';
import '../widgets/exercise_form/multiple_choice_form.dart';
import '../widgets/exercise_form/other_forms.dart';
import '../widgets/exercise_form/resizable_text_area.dart';

/// Página para crear un nuevo ejercicio (RF-09, RF-11, RF-12).
class ExerciseFormPage extends StatefulWidget {
  const ExerciseFormPage({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.repository,
    this.preselectedLevel,
  });

  final String moduleId;
  final String moduleTitle;
  final MockModuleRepository repository;
  final DifficultyLevel? preselectedLevel;

  @override
  State<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends State<ExerciseFormPage> {
  final _uuid = const Uuid();

  final _titleCtrl        = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  ExerciseType    _type       = ExerciseType.multipleChoice;
  DifficultyLevel _difficulty = DifficultyLevel.basic;
  Subject         _subject    = Subject.spanish;

  final _questionCtrl    = TextEditingController();
  final List<TextEditingController> _optionCtrls =
      List.generate(3, (_) => TextEditingController());
  int  _correctIndex     = 0;
  final _explanationCtrl = TextEditingController();

  final _statementCtrl   = TextEditingController();
  bool _correctBool      = true;

  final _templateCtrl    = TextEditingController();
  final _blankAnswerCtrl = TextEditingController();
  final _hintCtrl        = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedLevel != null) _difficulty = widget.preselectedLevel!;
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

  void _addOption() =>
      setState(() => _optionCtrls.add(TextEditingController()));

  void _removeOption(int i) {
    if (_optionCtrls.length <= 2) return;
    setState(() {
      _optionCtrls[i].dispose();
      _optionCtrls.removeAt(i);
      if (_correctIndex >= _optionCtrls.length) {
        _correctIndex = _optionCtrls.length - 1;
      }
    });
  }

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

  Map<String, dynamic> _buildContent() => switch (_type) {
        ExerciseType.multipleChoice => {
            'question': _questionCtrl.text.trim(),
            'options': _optionCtrls.map((c) => c.text.trim()).toList(),
            'correctIndex': _correctIndex,
            if (_explanationCtrl.text.trim().isNotEmpty)
              'explanation': _explanationCtrl.text.trim(),
          },
        ExerciseType.trueOrFalse => {
            'statement': _statementCtrl.text.trim(),
            'correctAnswer': _correctBool,
          },
        ExerciseType.fillInTheBlank => {
            'template': _templateCtrl.text.trim(),
            'correctAnswer': _blankAnswerCtrl.text.trim(),
            if (_hintCtrl.text.trim().isNotEmpty) 'hint': _hintCtrl.text.trim(),
          },
        ExerciseType.ordering => {
            'words': <String>[],
            'correctOrder': <String>[],
          },
      };

  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) return 'El título del ejercicio es obligatorio.';
    if (_instructionsCtrl.text.trim().isEmpty) return 'Las instrucciones son obligatorias.';
    switch (_type) {
      case ExerciseType.multipleChoice:
        if (_questionCtrl.text.trim().isEmpty) return 'La pregunta es obligatoria.';
        if (_optionCtrls.any((c) => c.text.trim().isEmpty)) {
          return 'Todas las opciones deben tener texto.';
        }
      case ExerciseType.trueOrFalse:
        if (_statementCtrl.text.trim().isEmpty) return 'La afirmación es obligatoria.';
      case ExerciseType.fillInTheBlank:
        if (!_templateCtrl.text.contains('[BLANK]')) {
          return 'El texto debe contener [BLANK].';
        }
        if (_blankAnswerCtrl.text.trim().isEmpty) {
          return 'La respuesta correcta es obligatoria.';
        }
      case ExerciseType.ordering:
        break;
    }
    return null;
  }

  Future<void> _onSave() async {
    final error = _validate();
    if (error != null) { AppSnackbar.showError(context, error); return; }
    setState(() => _isLoading = true);
    await widget.repository.createExercise(ExerciseEntity(
      id: _uuid.v4(),
      moduleId: widget.moduleId,
      title: _titleCtrl.text.trim(),
      instructions: _instructionsCtrl.text.trim(),
      type: _type,
      difficulty: _difficulty,
      subject: _subject,
      content: _buildContent(),
    ));
    if (!mounted) return;
    setState(() => _isLoading = false);
    AppSnackbar.showSuccess(context, 'Ejercicio creado correctamente');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const ExFormBackground(),
          Column(
            children: [
              ExFormHeader(moduleTitle: widget.moduleTitle),
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
            label: 'Título del ejercicio',
            required: true,
            child: TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej: ¿De qué trata el cuento?'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ExFormFieldLabel(
            label: 'Instrucciones para el estudiante',
            required: true,
            child: ExFormResizableTextArea(
              controller: _instructionsCtrl,
              hintText:
                  'Ej: Lee el texto con atención y selecciona la respuesta correcta.',
              minLines: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ExFormFieldLabel(
            label: 'Materia',
            required: true,
            child: ExFormSubjectDropdown(
              value: _subject,
              onChanged: (v) => setState(() => _subject = v!),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(
              child: ExFormFieldLabel(
                label: 'Tipo de ejercicio',
                required: true,
                child: ExFormTypeDropdown(
                  value: _type,
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ExFormFieldLabel(
                label: 'Nivel de dificultad',
                required: true,
                child: ExFormDifficultyDropdown(
                  value: _difficulty,
                  onChanged: (v) => setState(() => _difficulty = v!),
                ),
              ),
            ),
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