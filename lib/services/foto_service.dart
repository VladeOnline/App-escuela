import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/constants/app_constants.dart';

class FotoService {
  final http.Client httpClient;

  FotoService({required this.httpClient});

  /// Obtener directorio para guardar fotos localmente
  Future<Directory> _getFotosDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory fotosDir = Directory('${appDir.path}/fotos_perfil');
    
    if (!await fotosDir.exists()) {
      await fotosDir.create(recursive: true);
    }
    
    return fotosDir;
  }

  /// Guardar foto localmente y retornar la ruta
  Future<String> _saveFotoLocally({
    required String usuarioId,
    required File fotoFile,
  }) async {
    try {
      final fotosDir = await _getFotosDirectory();
      final nombreArchivo = 'foto_docente_$usuarioId.jpg';
      final rutaGuardada = File('${fotosDir.path}/$nombreArchivo');
      
      // Copiar archivo a la carpeta de fotos
      await fotoFile.copy(rutaGuardada.path);
      
      return rutaGuardada.path;
    } catch (e) {
      throw Exception('Error al guardar foto localmente: $e');
    }
  }

  /// Guardar foto de estudiante localmente
  Future<String> _saveFotoEstudianteLocally({
    required String estudianteId,
    required File fotoFile,
  }) async {
    try {
      final fotosDir = await _getFotosDirectory();
      final nombreArchivo = 'foto_estudiante_$estudianteId.jpg';
      final rutaGuardada = File('${fotosDir.path}/$nombreArchivo');
      
      await fotoFile.copy(rutaGuardada.path);
      
      return rutaGuardada.path;
    } catch (e) {
      throw Exception('Error al guardar foto localmente: $e');
    }
  }

  /// Subir foto de docente (y guardar localmente)
  Future<String> uploadFotoDocente({
    required String usuarioId,
    required File fotoFile,
  }) async {
    try {
      // Guardar localmente primero
      final rutaLocal = await _saveFotoLocally(
        usuarioId: usuarioId,
        fotoFile: fotoFile,
      );

      // Intentar subir al backend (si falla, al menos quedó guardada localmente)
      try {
        final uri = Uri.parse('${AppConstants.apiBaseUrl}/fotos/docente/upload');
        
        var request = http.MultipartRequest('POST', uri);
        request.fields['usuarioId'] = usuarioId;
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            fotoFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        final response = await request.send().timeout(const Duration(seconds: 10));
        
        if (response.statusCode != 200) {
          throw Exception('Error al subir al servidor: ${response.statusCode}');
        }
      } catch (e) {
        // El servidor falló pero la foto se guardó localmente
        print('Advertencia: No se pudo subir al servidor, pero se guardó localmente');
      }

      return rutaLocal;
    } catch (e) {
      rethrow;
    }
  }

  /// Subir foto de estudiante (y guardar localmente)
  Future<String> uploadFotoEstudiante({
    required String estudianteId,
    required File fotoFile,
  }) async {
    try {
      // Guardar localmente
      final rutaLocal = await _saveFotoEstudianteLocally(
        estudianteId: estudianteId,
        fotoFile: fotoFile,
      );

      // Intentar subir al backend
      try {
        final uri = Uri.parse('${AppConstants.apiBaseUrl}/fotos/estudiante/upload');
        
        var request = http.MultipartRequest('POST', uri);
        request.fields['estudianteId'] = estudianteId;
        request.files.add(
          await http.MultipartFile.fromPath(
            'foto',
            fotoFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        final response = await request.send().timeout(const Duration(seconds: 10));
        
        if (response.statusCode != 200) {
          throw Exception('Error al subir al servidor: ${response.statusCode}');
        }
      } catch (e) {
        print('Advertencia: No se pudo subir al servidor, pero se guardó localmente');
      }

      return rutaLocal;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtener foto guardada localmente
  Future<File?> getFotoDocente(String usuarioId) async {
    try {
      final fotosDir = await _getFotosDirectory();
      final nombreArchivo = 'foto_docente_$usuarioId.jpg';
      final archivo = File('${fotosDir.path}/$nombreArchivo');
      
      if (await archivo.exists()) {
        return archivo;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener foto de estudiante guardada localmente
  Future<File?> getFotoEstudiante(String estudianteId) async {
    try {
      final fotosDir = await _getFotosDirectory();
      final nombreArchivo = 'foto_estudiante_$estudianteId.jpg';
      final archivo = File('${fotosDir.path}/$nombreArchivo');
      
      if (await archivo.exists()) {
        return archivo;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
