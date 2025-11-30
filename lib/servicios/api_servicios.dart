import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicios {
  static const String _baseUrl = 'https://bottelegramihc-production.up.railway.app';
  
  static final ApiServicios _instancia = ApiServicios._internal();
  factory ApiServicios() => _instancia;
  ApiServicios._internal();

  Future<List<dynamic>> obtenerPedidos() async {
    try {
      final respuesta = await http.get(
        Uri.parse('$_baseUrl/get_orders'),
        headers: {'Content-Type': 'application/json'},
      );

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        return datos is List ? datos : [];
      } else {
        throw Exception('Error al obtener pedidos: ${respuesta.statusCode}');
      }
    } catch (error) {
      throw Exception('Error de conexión: $error');
    }
  }

  Future<Map<String, dynamic>> obtenerPedido(String idPedido) async {
    try {
      final respuesta = await http.get(
        Uri.parse('$_baseUrl/get_order/$idPedido'),
        headers: {'Content-Type': 'application/json'},
      );

      if (respuesta.statusCode == 200) {
        return json.decode(respuesta.body);
      } else {
        throw Exception('Error al obtener pedido: ${respuesta.statusCode}');
      }
    } catch (error) {
      throw Exception('Error de conexión: $error');
    }
  }

  Future<void> actualizarEstadoPedido(String idPedido, String nuevoEstado) async {
    try {
      final respuesta = await http.post(
        Uri.parse('$_baseUrl/update_status/$idPedido'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': nuevoEstado}),
      );

      if (respuesta.statusCode != 200) {
        throw Exception('Error al actualizar estado: ${respuesta.statusCode}');
      }
    } catch (error) {
      throw Exception('Error de conexión: $error');
    }
  }
}