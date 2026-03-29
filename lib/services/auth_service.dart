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
      return jsonDecode(response.body);
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
}
