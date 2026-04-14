import 'package:flutter/material.dart';
import '../../../../features/students/domain/entities/student_entity.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget para seleccionar un estudiante de la lista
class StudentSelector extends StatefulWidget {
  final List<StudentEntity> students;
  final StudentEntity? selectedStudent;
  final ValueChanged<StudentEntity?> onChanged;

  const StudentSelector({
    Key? key,
    required this.students,
    this.selectedStudent,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StudentSelector> createState() => _StudentSelectorState();
}

class _StudentSelectorState extends State<StudentSelector> {
  late TextEditingController _searchController;
  late List<StudentEntity> _filteredStudents;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredStudents = widget.students;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = widget.students;
      } else {
        _filteredStudents = widget.students
            .where((student) =>
                student.fullName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Estudiante',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _searchController,
          onChanged: _filterStudents,
          decoration: InputDecoration(
            hintText: 'Buscar estudiante...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_filteredStudents.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            alignment: Alignment.center,
            child: Text(
              'No se encontraron estudiantes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredStudents.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                final isSelected = widget.selectedStudent?.id == student.id;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.blue[50],
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        student.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  title: Text(student.fullName),
                  subtitle: Text('Grado ${student.grade}'),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    widget.onChanged(student);
                    _searchController.clear();
                    _filteredStudents = widget.students;
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
