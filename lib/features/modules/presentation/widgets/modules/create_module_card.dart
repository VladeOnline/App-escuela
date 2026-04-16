import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../data/repositories/api_module_repository.dart';
import '../../../domain/entities/module_entities.dart';
import '../../pages/content_form_page.dart';

class CreateModuleCard extends StatefulWidget {
  const CreateModuleCard({
    super.key,
    required this.repository,
    required this.moduleType,
    required this.grade,
    required this.onCreated,
  });

  final ApiModuleRepository repository;
  final ModuleType moduleType;
  final int grade;
  final VoidCallback onCreated;

  @override
  State<CreateModuleCard> createState() => _CreateModuleCardState();
}

class _CreateModuleCardState extends State<CreateModuleCard> {
  bool _hovered = false;

  Future<void> _goToCreateContent() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ContentFormPage(
          moduleType: widget.moduleType,
          grade: widget.grade,
          repository: widget.repository,
        ),
      ),
    );
    if (created == true) widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _goToCreateContent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.primary.withOpacity(0.04) : Colors.white,
            borderRadius: const BorderRadius.all(AppRadius.large),
            border: Border.all(
              color: _hovered ? AppColors.primary : AppColors.primary.withOpacity(0.35),
              width: _hovered ? 1.5 : 1.0,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hovered ? AppColors.primary : AppColors.primary.withOpacity(0.12),
                    boxShadow: _hovered
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10)]
                        : [],
                  ),
                  child: Icon(Icons.add_rounded, size: 26,
                      color: _hovered ? Colors.white : AppColors.primary),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 12 * 1.95 * 2,
                  child: Center(
                    child: Text(
                      '¡Crea otro módulo haciendo click aquí!',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: _hovered ? AppColors.primary : AppColors.textSecondary.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                const SizedBox(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}