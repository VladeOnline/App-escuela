import 'package:flutter/material.dart';

enum FontFamily {
  nunito('Nunito'),
  roboto('Roboto'),
  openSans('Open Sans');

  final String displayName;
  const FontFamily(this.displayName);
}

enum AppThemeMode {
  light('Claro'),
  dark('Oscuro');

  final String displayName;
  const AppThemeMode(this.displayName);
}

class AppSettingsNotifier extends ChangeNotifier {
  FontFamily _fontFamily = FontFamily.nunito;
  AppThemeMode _themeMode = AppThemeMode.light;

  FontFamily get fontFamily => _fontFamily;
  AppThemeMode get themeMode => _themeMode;

  String get fontFamilyName => _fontFamily.name;
  String get themeName => _themeMode.name;

  void setFontFamily(FontFamily family) {
    if (_fontFamily != family) {
      _fontFamily = family;
      notifyListeners();
    }
  }

  void setThemeMode(AppThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void resetToDefaults() {
    _fontFamily = FontFamily.nunito;
    _themeMode = AppThemeMode.light;
    notifyListeners();
  }
}
