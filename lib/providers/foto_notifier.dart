import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/foto_service.dart';

class FotoNotifier extends ChangeNotifier {
  final FotoService _fotoService;

  FotoNotifier(this._fotoService);

  bool _isLoading = false;
  String? _error;
  String? _fotoUrl;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get fotoUrl => _fotoUrl;

  /// Cargar foto guardada localmente
  Future<void> loadSavedPhoto(String usuarioId) async {
    try {
      final fotoFile = await _fotoService.getFotoDocente(usuarioId);
      if (fotoFile != null) {
        _fotoUrl = fotoFile.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al cargar foto guardada: $e');
    }
  }

  /// Subir foto de docente
  Future<void> uploadFotoDocente({
    required String usuarioId,
    required File fotoFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rutaLocal = await _fotoService.uploadFotoDocente(
        usuarioId: usuarioId,
        fotoFile: fotoFile,
      );
      
      _fotoUrl = rutaLocal;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Subir foto de estudiante
  Future<void> uploadFotoEstudiante({
    required String estudianteId,
    required File fotoFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rutaLocal = await _fotoService.uploadFotoEstudiante(
        estudianteId: estudianteId,
        fotoFile: fotoFile,
      );
      
      _fotoUrl = rutaLocal;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
