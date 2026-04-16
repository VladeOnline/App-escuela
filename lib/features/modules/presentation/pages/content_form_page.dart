import 'dart:developer' as dev;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../data/repositories/api_module_repository.dart';
import '../../domain/entities/module_entities.dart';
import '../widgets/exercise_form/form_background.dart';
import '../widgets/exercise_form/form_chrome.dart';
import '../widgets/exercise_form/form_shared.dart';

class ContentFormPage extends StatefulWidget {
  const ContentFormPage({
    super.key,
    required this.moduleType,
    required this.grade,
    required this.repository,
  });

  final ModuleType moduleType;
  final int grade;
  final ApiModuleRepository repository;

  @override
  State<ContentFormPage> createState() => _ContentFormPageState();
}

class _ContentFormPageState extends State<ContentFormPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  bool _isLoading  = false;

  static const _gradeNames = {
    1: 'Primer grado',  2: 'Segundo grado', 3: 'Tercer grado',
    4: 'Cuarto grado',  5: 'Quinto grado',  6: 'Sexto grado',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_titleCtrl.text.trim().isEmpty) return 'El título del contenido es obligatorio.';
    if (_descCtrl.text.trim().isEmpty)  return 'La descripción del contenido es obligatoria.';
    return null;
  }

  Future<void> _onSave() async {
    final error = _validate();
    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }

    setState(() => _isLoading = true);

    final module = ModuleEntity(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: widget.moduleType,
      grade: widget.grade,
      createdAt: DateTime.now(),
    );

    final result = await widget.repository.createModule(module);

    // Debug: imprime en consola para diagnosticar errores del backend.
    // Podés quitar este bloque una vez confirmado que funciona.
    dev.log(
      'createModule → failure: ${result.failure?.message} | module.id: ${result.module?.id}',
      name: 'ContentFormPage',
    );

    if (!mounted) return;

    if (result.failure != null) {
      setState(() => _isLoading = false);
      AppSnackbar.showError(context, result.failure!.message);
      return;
    }

    // Éxito: limpia campos y vuelve
    _titleCtrl.clear();
    _descCtrl.clear();
    setState(() => _isLoading = false);
    AppSnackbar.showSuccess(context, 'Contenido creado correctamente');
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
              _ContentFormHeader(moduleType: widget.moduleType),
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
                          alignment: const Alignment(0, -0.3),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 620),
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
              _ContentFormFooter(isLoading: _isLoading, onSave: _onSave),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWide() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: ExFormBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _formCard()),
        ],
      );

  Widget _buildNarrow() => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ExFormBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          const SizedBox(height: AppSpacing.md),
          _formCard(),
          const SizedBox(height: AppSpacing.xl),
        ],
      );

  Widget _formCard() => Column(
        children: [
          _ContextChips(
            gradeName: _gradeNames[widget.grade] ?? '${widget.grade}° grado',
            moduleType: widget.moduleType,
          ),
          const SizedBox(height: AppSpacing.md),
          ExFormSectionCard(
            title: 'Datos del contenido',
            icon: Icons.folder_open_rounded,
            children: [
              ExFormFieldLabel(
                label: 'Título',
                required: true,
                hint: 'Nombre que verán los estudiantes al seleccionar el contenido.',
                child: TextField(
                  controller: _titleCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Ej: Comprensión de textos'),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ExFormFieldLabel(
                label: 'Descripción',
                required: true,
                hint: 'Breve explicación de qué trabajará el estudiante en este contenido.',
                child: TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Ejercicios para desarrollar la comprensión lectora.',
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ContentFormHeader extends StatelessWidget {
  const _ContentFormHeader({required this.moduleType});
  final ModuleType moduleType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withOpacity(0.92),
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Text(
          'Nuevo contenido — ${moduleType.label}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Footer sin botón Limpiar ─────────────────────────────────────────────────

class _ContentFormFooter extends StatelessWidget {
  const _ContentFormFooter({required this.isLoading, required this.onSave});

  final bool isLoading;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: AppColors.border.withOpacity(0.8)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          color: AppColors.surfaceCard.withOpacity(0.95),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, color: AppColors.textHint),
                  children: const [
                    TextSpan(text: 'Todos los campos con '),
                    TextSpan(text: '*', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                    TextSpan(text: ' son obligatorios'),
                  ],
                ),
              ),
              const Spacer(),
              Container(width: 1, height: 28, color: AppColors.border),
              const SizedBox(width: AppSpacing.md),
              FilledButton.icon(
                onPressed: isLoading ? null : onSave,
                icon: isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.library_add_rounded, size: 18),
                label: const Text('Guardar contenido'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(0, 44),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.medium)),
                ).copyWith(mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click)),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(width: 1, height: 28, color: AppColors.border),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Chips de contexto ────────────────────────────────────────────────────────

class _ContextChips extends StatelessWidget {
  const _ContextChips({required this.gradeName, required this.moduleType});
  final String gradeName;
  final ModuleType moduleType;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(icon: Icons.school_rounded, label: gradeName, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        _Chip(icon: moduleType.icon, label: moduleType.label, color: AppColors.primaryLight),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: color)),
        ],
      ),
    );
  }
}