import 'package:flutter/material.dart';

/// Design system principal de la aplicación.
/// Paleta pensada para ser profesional para el docente
/// y amigable/atractiva visualmente para niños de primaria.
abstract class AppColors {
  // Primarios - verde teal cálido (educación, naturaleza, confianza)
  static const primary = Color(0xFF0D9488);
  static const primaryLight = Color(0xFF14B8A6);
  static const primaryDark = Color(0xFF0F766E);

  // Secundario - ámbar cálido (energía, motivación, gamificación)
  static const secondary = Color(0xFFF59E0B);
  static const secondaryLight = Color(0xFFFBBF24);

  // Acento - violeta suave (creatividad, aprendizaje)
  static const accent = Color(0xFF8B5CF6);

  // Semánticos
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // Neutros
  static const surface = Color(0xFFF8FAFC);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);

  // Grados (colores únicos por grado para identificación visual)
  static const grade1 = Color(0xFFEF4444); // Rojo
  static const grade2 = Color(0xFFF97316); // Naranja
  static const grade3 = Color(0xFFF59E0B); // Ámbar
  static const grade4 = Color(0xFF10B981); // Esmeralda
  static const grade5 = Color(0xFF3B82F6); // Azul
  static const grade6 = Color(0xFF8B5CF6); // Violeta

  static Color forGrade(int grade) {
    const map = {
      1: grade1,
      2: grade2,
      3: grade3,
      4: grade4,
      5: grade5,
      6: grade6,
    };
    return map[grade] ?? primary;
  }
}

abstract class AppRadius {
  static const small = Radius.circular(8);
  static const medium = Radius.circular(12);
  static const large = Radius.circular(16);
  static const xl = Radius.circular(24);
  static const full = Radius.circular(999);
}

abstract class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      fontFamily: 'Nunito',
      textTheme: _textTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      appBarTheme: _appBarTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.2,
    ),
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.medium),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.medium),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
      ),
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    border: OutlineInputBorder(
      borderRadius: const BorderRadius.all(AppRadius.medium),
      borderSide: BorderSide(color: AppColors.border, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: const BorderRadius.all(AppRadius.medium),
      borderSide: BorderSide(color: AppColors.border, width: 1.5),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(AppRadius.medium),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(AppRadius.medium),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(AppRadius.medium),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
      fontFamily: 'Nunito',
    ),
    hintStyle: const TextStyle(
      color: AppColors.textHint,
      fontFamily: 'Nunito',
    ),
    errorStyle: const TextStyle(
      color: AppColors.error,
      fontWeight: FontWeight.w500,
      fontFamily: 'Nunito',
    ),
  );

  static final CardThemeData _cardTheme = CardThemeData(
    color: AppColors.surfaceCard,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(AppRadius.large),
      side: BorderSide(color: AppColors.border, width: 1),
    ),
    margin: EdgeInsets.zero,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: AppColors.surfaceCard,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontFamily: 'Nunito',
    ),
  );

  static final DialogThemeData _dialogTheme = DialogThemeData(
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(AppRadius.xl),
    ),
    elevation: 8,
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontFamily: 'Nunito',
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      fontFamily: 'Nunito',
    ),
  );

  static final SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(AppRadius.medium),
    ),
    contentTextStyle: const TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
  );
}


