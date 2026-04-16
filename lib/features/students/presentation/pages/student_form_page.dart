import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/usecases/validate_student_usecase.dart';
import '../notifiers/students_notifier.dart';

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key, required this.notifier, this.student});
  final StudentsNotifier notifier;
  final StudentEntity? student;
  bool get isEditing => student != null;
  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl  = TextEditingController();
  final _validator = const ValidateStudentUseCase();
  int? _grade;
  String? _photoDataUrl;
  bool _gradeError = false, _isLoading = false, _conditionsExpanded = false;
  final Set<String> _selectedConditions = {};

  static const _conditions = [
    ('TEA', 'Trastorno del Espectro Autista'),
    ('TDAH', 'Trastorno por Déficit de Atención'),
    ('Dislexia', 'Dificultad en lectoescritura'),
    ('Discalculia', 'Dificultad con números'),
    ('Hipoacusia', 'Pérdida parcial de audición'),
    ('Baja visión', 'Dificultad visual parcial'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nameCtrl.text = widget.student!.fullName;
      _ageCtrl.text  = widget.student!.age.toString();
      _grade         = widget.student!.grade;
      _selectedConditions.addAll(widget.student!.conditions);
      _photoDataUrl = widget.student!.photoUrl;
    }
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _nameCtrl.dispose(); _ageCtrl.dispose(); super.dispose(); }

  Future<void> _onSubmit() async {
    final formValid = _formKey.currentState!.validate();
    if (_grade == null) setState(() => _gradeError = true);
    if (!formValid || _grade == null) return;
    setState(() => _isLoading = true);
    final ok = widget.isEditing
        ? await widget.notifier.updateStudent(id: widget.student!.id, fullName: _nameCtrl.text, ageText: _ageCtrl.text, grade: _grade, conditions: _selectedConditions.toList(), photoDataUrl: _photoDataUrl)
        : await widget.notifier.createStudent(fullName: _nameCtrl.text, ageText: _ageCtrl.text, grade: _grade, conditions: _selectedConditions.toList(), photoDataUrl: _photoDataUrl);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) { Navigator.of(context).pop(true); return; }
    final f = widget.notifier.state.failure;
    if (f != null) AppSnackbar.showError(context, f.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _FormBackground(),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.lg,
            child: _BackButton(onTap: () => Navigator.of(context).pop()),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: _FormCard(
                  isEditing: widget.isEditing, formKey: _formKey,
                  nameCtrl: _nameCtrl, ageCtrl: _ageCtrl, validator: _validator,
                  grade: _grade, gradeError: _gradeError,
                  onGradeChanged: (g) => setState(() { _grade = g; _gradeError = false; }),
                  conditionsExpanded: _conditionsExpanded,
                  onToggleConditions: () => setState(() => _conditionsExpanded = !_conditionsExpanded),
                  selectedConditions: _selectedConditions,
                  onToggleCondition: (c) => setState(() => _selectedConditions.contains(c) ? _selectedConditions.remove(c) : _selectedConditions.add(c)),
                  conditions: _conditions, isLoading: _isLoading,
                  photoDataUrl: _photoDataUrl,
                  onPhotoChanged: (value) => setState(() => _photoDataUrl = value),
                  onSubmit: _onSubmit, onCancel: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Fondo ---

class _FormBackground extends StatefulWidget {
  const _FormBackground();
  @override
  State<_FormBackground> createState() => _FormBackgroundState();
}

class _FormBackgroundState extends State<_FormBackground> with TickerProviderStateMixin {
  late final AnimationController _ctrlA = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  late final AnimationController _ctrlB = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500))..repeat(reverse: true);
  late final Animation<double> _pulseA = CurvedAnimation(parent: _ctrlA, curve: Curves.easeInOut);
  late final Animation<double> _pulseB = CurvedAnimation(parent: _ctrlB, curve: Curves.easeInOut);

  @override
  void dispose() { _ctrlA.dispose(); _ctrlB.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return Stack(children: [
      Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEEFAF8), Color(0xFFF6FDFC), Color(0xFFEDF9F6)]))),
      CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
      AnimatedBuilder(
        animation: Listenable.merge([_pulseA, _pulseB]),
        builder: (_, _) => Stack(children: [
          Positioned(top: -s.height * 0.15, left: -s.width * 0.08, child: _GlowOrb(size: s.width * 0.55 + _pulseA.value * 40, color: AppColors.primary, opacity: 0.14 + _pulseA.value * 0.06)),
          Positioned(top: s.height * 0.05, right: -s.width * 0.05, child: _GlowOrb(size: s.width * 0.35 + _pulseB.value * 30, color: AppColors.primaryLight, opacity: 0.11 + _pulseB.value * 0.05)),
          Positioned(bottom: -s.height * 0.12, right: -s.width * 0.06, child: _GlowOrb(size: s.width * 0.45 + _pulseB.value * 35, color: AppColors.primaryDark, opacity: 0.12 + _pulseB.value * 0.05)),
          Positioned(bottom: s.height * 0.08, left: s.width * 0.20, child: _GlowOrb(size: s.width * 0.20 + _pulseA.value * 15, color: AppColors.primaryLight, opacity: 0.09 + _pulseA.value * 0.04)),
        ]),
      ),
    ]);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppColors.primary.withValues(alpha: 0.055)..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(_GridPainter _) => false;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color, required this.opacity});
  final double size; final Color color; final double opacity;
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(
      colors: [color.withValues(alpha: opacity), color.withValues(alpha: opacity * 0.4), color.withValues(alpha: 0)],
      stops: const [0.0, 0.5, 1.0],
    )),
  );
}

// --- Botón volver ---

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: const BorderRadius.all(AppRadius.full), border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text('Volver', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ]),
      ),
    ),
  );
}

// --- Card principal ---

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.isEditing, required this.formKey, required this.nameCtrl,
    required this.ageCtrl, required this.validator, required this.grade,
    required this.gradeError, required this.onGradeChanged, required this.conditionsExpanded,
    required this.onToggleConditions, required this.selectedConditions,
    required this.onToggleCondition, required this.conditions,
    required this.isLoading, required this.photoDataUrl, required this.onPhotoChanged,
    required this.onSubmit, required this.onCancel,
  });
  final bool isEditing, gradeError, conditionsExpanded, isLoading;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, ageCtrl;
  final ValidateStudentUseCase validator;
  final int? grade;
  final ValueChanged<int?> onGradeChanged;
  final VoidCallback onToggleConditions, onSubmit, onCancel;
  final Set<String> selectedConditions;
  final ValueChanged<String> onToggleCondition;
  final List<(String, String)> conditions;
  final String? photoDataUrl;
  final ValueChanged<String?> onPhotoChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: const BorderRadius.all(AppRadius.xl),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.10), blurRadius: 40, offset: const Offset(0, 12)), BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AvatarSection(isEditing: isEditing, nameCtrl: nameCtrl, grade: grade, photoDataUrl: photoDataUrl, onPhotoChanged: onPhotoChanged),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _SectionLabel(text: 'Información', required: true),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  Expanded(flex: 3, child: TextFormField(
                    controller: nameCtrl, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Nombre completo', prefixIcon: Icon(Icons.person_outline_rounded)),
                    validator: (v) => validator.validateField('fullName', v ?? '')?.message,
                  )),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(flex: 2, child: TextFormField(
                    controller: ageCtrl, keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                    decoration: const InputDecoration(labelText: 'Edad', prefixIcon: Icon(Icons.cake_outlined), suffixText: 'años'),
                    validator: (v) => validator.validateField('age', v ?? '')?.message,
                  )),
                ]),
                const SizedBox(height: AppSpacing.lg),
                _SectionLabel(text: 'Grado académico', required: true),
                const SizedBox(height: AppSpacing.sm),
                _GradeSelector(selectedGrade: grade, onChanged: onGradeChanged),
                if (gradeError) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    const Text('Selecciona un grado académico', style: TextStyle(color: AppColors.error, fontSize: 12, fontFamily: 'Nunito', fontWeight: FontWeight.w500)),
                  ]),
                ],
              ]),
            ),
            const Divider(height: 1, color: AppColors.border),
            _ConditionsSection(expanded: conditionsExpanded, onToggle: onToggleConditions, selected: selectedConditions, onToggleCondition: onToggleCondition, conditions: conditions),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(children: [
                RichText(text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: AppColors.textHint),
                  children: const [TextSpan(text: '* ', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)), TextSpan(text: 'Campos obligatorios')],
                )),
                const Spacer(),
                OutlinedButton(onPressed: isLoading ? null : onCancel,
                  style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.medium)), minimumSize: const Size(0, 44)),
                  child: const Text('Cancelar')),
                const SizedBox(width: AppSpacing.md),
                FilledButton(onPressed: isLoading ? null : onSubmit,
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.medium)), minimumSize: const Size(0, 44)),
                  child: isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(isEditing ? 'Guardar cambios' : 'Registrar estudiante')),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Avatar con preview en tiempo real ---

class _AvatarSection extends StatefulWidget {
  const _AvatarSection({required this.isEditing, required this.nameCtrl, required this.grade, required this.photoDataUrl, required this.onPhotoChanged});
  final bool isEditing;
  final TextEditingController nameCtrl;
  final int? grade;
  final String? photoDataUrl;
  final ValueChanged<String?> onPhotoChanged;
  @override
  State<_AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends State<_AvatarSection> {
  bool _hovered = false;

  String get _initials {
    final parts = widget.nameCtrl.text.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      AppSnackbar.showError(context, 'No se pudo leer el archivo seleccionado.');
      return;
    }

    if (bytes.length > 2 * 1024 * 1024) {
      AppSnackbar.showError(context, 'La imagen debe pesar maximo 2 MB.');
      return;
    }

    final mime = _mimeFromFileName(file.name);
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    widget.onPhotoChanged(dataUrl);
  }

  String _mimeFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  ImageProvider? _resolvePhotoProvider(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final trimmed = value.trim();
    if (trimmed.startsWith('data:image/')) {
      final comma = trimmed.indexOf(',');
      if (comma > 0 && comma < trimmed.length - 1) {
        try {
          return MemoryImage(base64Decode(trimmed.substring(comma + 1)));
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return NetworkImage(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final hasName = widget.nameCtrl.text.trim().isNotEmpty;
    final gradeColor =
        widget.grade != null ? AppColors.forGrade(widget.grade!) : AppColors.textHint;
    final photoProvider = _resolvePhotoProvider(widget.photoDataUrl);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: _pickImage,
            child: Stack(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasName
                      ? gradeColor.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: hasName
                        ? gradeColor.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: photoProvider != null
                      ? Image(
                          image: photoProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person_outline_rounded,
                            size: 32,
                            color: AppColors.textHint,
                          ),
                        )
                      : Center(
                          child: hasName
                              ? Text(
                                  _initials,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Nunito',
                                    color: gradeColor,
                                  ),
                                )
                              : const Icon(
                                  Icons.person_outline_rounded,
                                  size: 32,
                                  color: AppColors.textHint,
                                ),
                        ),
                ),
              ),
              AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.72),
                  ),
                  child: const Icon(Icons.upload_rounded, size: 26, color: Colors.white),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(width: 1, height: 56, color: AppColors.border),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.isEditing ? 'Editar estudiante' : 'Nuevo estudiante',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 2),
            Text(
              'Puedes subir una foto para este estudiante.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 11, color: AppColors.textHint),
            ),
          ]),
        ),
      ]),
    );
  }
}

// --- Helpers ---

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.required = false});
  final String text; final bool required;
  @override
  Widget build(BuildContext context) {
    if (!required) return Text(text, style: Theme.of(context).textTheme.titleMedium);
    return RichText(text: TextSpan(style: Theme.of(context).textTheme.titleMedium, children: [
      TextSpan(text: text),
      const TextSpan(text: ' *', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800)),
    ]));
  }
}

class _GradeSelector extends StatelessWidget {
  const _GradeSelector({required this.selectedGrade, required this.onChanged});
  final int? selectedGrade; final ValueChanged<int?> onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm, runSpacing: AppSpacing.sm,
    children: AppConstants.grades.map((g) {
      final isSelected = selectedGrade == g;
      final color = AppColors.forGrade(g);
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(g),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(color: isSelected ? color.withValues(alpha: 0.12) : Colors.white, borderRadius: const BorderRadius.all(AppRadius.full),
              border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 2 : 1.5)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isSelected) ...[Icon(Icons.check_circle_rounded, size: 14, color: color), const SizedBox(width: AppSpacing.xs)],
              Text(AppConstants.gradeLabels[g] ?? '$g° grado',
                style: TextStyle(color: isSelected ? color : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: 13, fontFamily: 'Nunito')),
            ]),
          ),
        ),
      );
    }).toList(),
  );
}

// --- Condiciones especiales ---

class _ConditionsSection extends StatelessWidget {
  const _ConditionsSection({required this.expanded, required this.onToggle, required this.selected, required this.onToggleCondition, required this.conditions});
  final bool expanded; final VoidCallback onToggle;
  final Set<String> selected; final ValueChanged<String> onToggleCondition;
  final List<(String, String)> conditions;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(children: [
              const Icon(Icons.accessibility_new_rounded, size: 18, color: AppColors.textHint),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Condiciones especiales', style: Theme.of(context).textTheme.titleMedium),
                Text('Opcional - selecciona las que apliquen', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              ])),
              if (selected.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.10), borderRadius: const BorderRadius.all(AppRadius.full)),
                  child: Text('${selected.length}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito')),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              AnimatedRotation(turns: expanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textHint)),
            ]),
          ),
        ),
      ),
      AnimatedCrossFade(
        firstChild: const SizedBox.shrink(),
        secondChild: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Column(children: [
            GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.sm, mainAxisSpacing: AppSpacing.sm, childAspectRatio: 3.5,
              children: conditions.map(((String, String) c) {
                final isSel = selected.contains(c.$1);
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onToggleCondition(c.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.success.withValues(alpha: 0.10) : AppColors.surface,
                        borderRadius: const BorderRadius.all(AppRadius.medium),
                        border: Border.all(
                          color: isSel ? AppColors.success.withValues(alpha: 0.55) : AppColors.border,
                          width: isSel ? 1.7 : 1,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.success : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? AppColors.success : AppColors.textHint,
                              width: 1.6,
                            ),
                          ),
                          child: isSel
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(c.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: isSel ? AppColors.success : AppColors.textPrimary)),
                          Text(
                            c.$2,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Nunito',
                              color: isSel
                                  ? AppColors.success.withValues(alpha: 0.70)
                                  : AppColors.textHint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ])),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            // TODO(back/future): abrir panel lateral con más condiciones disponibles
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5), borderRadius: const BorderRadius.all(AppRadius.medium), color: AppColors.primary.withValues(alpha: 0.04)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primary.withValues(alpha: 0.7)),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Más condiciones conocidas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Nunito', color: AppColors.primary.withValues(alpha: 0.7))),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
      ),
    ]);
  }
}








