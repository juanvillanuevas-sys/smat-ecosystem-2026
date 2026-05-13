import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // URL PARA AJUSTAR según la IP de mi servidor o localhost
  final String baseUrl = "http://127.0.0.1:8000"; 

  // Función para iniciar sesión y guardar el token
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['access_token'];
      
      // Persistencia: Guardamos el token en el dispositivo
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      return true;
    }
    return false;
  }

  // Función para obtener el token guardado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Función para cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}