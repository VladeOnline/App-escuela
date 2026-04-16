import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_failure.dart';

/// Validaciones de negocio para los datos de un estudiante.
/// Centraliza toda la lógica de validación que el Back también necesitará.
class ValidateStudentUseCase {
  const ValidateStudentUseCase();

  /// Valida todos los campos y retorna una lista de errores.
  /// Si la lista está vacía, los datos son válidos.
  Map<String, String?> validate({
    required String fullName,
    required String ageText,
    required int? grade,
  }) {
    final errors = <String, String?>{};

    // Nombre
    final nameTrimmed = fullName.trim();
    if (nameTrimmed.isEmpty) {
      errors['fullName'] = 'El nombre es obligatorio';
    } else if (nameTrimmed.length < AppConstants.minNameLength) {
      errors['fullName'] =
          'El nombre debe tener al menos ${AppConstants.minNameLength} caracteres';
    } else if (nameTrimmed.length > AppConstants.maxNameLength) {
      errors['fullName'] =
          'El nombre no puede tener más de ${AppConstants.maxNameLength} caracteres';
    } else if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s'-]+$").hasMatch(nameTrimmed)) {
      errors['fullName'] = 'El nombre solo puede contener letras';
    }

    // Edad
    final age = int.tryParse(ageText.trim());
    if (ageText.trim().isEmpty) {
      errors['age'] = 'La edad es obligatoria';
    } else if (age == null) {
      errors['age'] = 'Ingresa una edad válida';
    } else if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      errors['age'] =
          'La edad debe estar entre ${AppConstants.minAge} y ${AppConstants.maxAge} años';
    }

    // Grado
    if (grade == null) {
      errors['grade'] = 'Selecciona un grado académico';
    } else if (!AppConstants.grades.contains(grade)) {
      errors['grade'] = 'El grado seleccionado no es válido';
    }

    return errors;
  }

  /// Valida un solo campo (para validación en tiempo real).
  AppFailure? validateField(String field, String value, {int? grade}) {
    switch (field) {
      case 'fullName':
        final trimmed = value.trim();
        if (trimmed.isEmpty) return const ValidationFailure('El nombre es obligatorio');
        if (trimmed.length < AppConstants.minNameLength) {
          return ValidationFailure(
              'Mínimo ${AppConstants.minNameLength} caracteres');
        }
        if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚüÜñÑ\s'-]+$").hasMatch(trimmed)) {
          return const ValidationFailure('Solo se permiten letras');
        }
        return null;

      case 'age':
        final age = int.tryParse(value.trim());
        if (value.trim().isEmpty) return const ValidationFailure('La edad es obligatoria');
        if (age == null) return const ValidationFailure('Ingresa un número válido');
        if (age < AppConstants.minAge || age > AppConstants.maxAge) {
          return ValidationFailure(
              'Entre ${AppConstants.minAge} y ${AppConstants.maxAge} años');
        }
        return null;

      default:
        return null;
    }
  }
}

