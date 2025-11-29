import 'package:http/http.dart' as http;
import 'dart:convert';
import '../modelos/pedido.dart';

class ServicioPedidos {
  final String urlBase = 'https://roomy-untempestuous-nolan.ngrok-free.dev/api/pedidos';

  Future<List<Pedido>> obtenerPedidos() async {
    try {
      final respuesta = await http.get(Uri.parse(urlBase));
      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        if (datos is List) {
          return datos.map<Pedido>((p) => Pedido.fromJson(p)).toList();
        } else {
          throw Exception('La respuesta no es una lista de pedidos');
        }
      } else {
        throw Exception('Error HTTP: ${respuesta.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener los pedidos: $e');
    }
  }
}
