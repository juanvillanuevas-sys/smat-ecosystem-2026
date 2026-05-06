import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion.dart';
class ApiService {
  // 10.0.2.2 es el alias del localhost de la PC para emuladores Android
  final String baseUrl = "http://localhost:8000";
  //"http://10.0.2.2:8000" en movil

  Future<List<Estacion>> fetchEstaciones() async {
    final response = await http.get(Uri.parse('$baseUrl/estaciones/'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Estacion.fromJson(data)).toList();
    } else {
      throw Exception('Error al conectar con el servidor SMAT');
    }
  }
}
