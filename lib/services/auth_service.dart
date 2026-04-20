import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/errors/app_failure.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String username, String password, String rol) async {
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'rol': rol,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final message = data['message']?.toString();
        throw AuthFailure(message ?? 'Credenciales incorrectas.');
      } catch (_) {
        throw const AuthFailure('Credenciales incorrectas.');
      }
    }
  }

  static Future<Map<String, dynamic>> updateProfilePhoto({
    required String token,
    required String photoDataUrl,
  }) async {
    final response = await http.patch(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/me/foto-perfil'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'foto_perfil_url': photoDataUrl}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    final fallback = 'No se pudo actualizar la foto de perfil.';
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw AuthFailure(data['message']?.toString() ?? fallback);
    } catch (_) {
      throw AuthFailure(fallback);
    }
  }

  static Future<void> deleteAccount({required String token}) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final fallback = 'No se pudo eliminar la cuenta.';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw AuthFailure(data['message']?.toString() ?? fallback);
      } catch (_) {
        throw AuthFailure(fallback);
      }
    }
  }
}


