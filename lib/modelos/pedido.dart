import 'producto.dart';
import 'ubicacion.dart';

class Pedido {
  final String id;
  final String cliente;
  final String direccion;
  final List<Producto> productos;
  final Ubicacion ubicacion;

  Pedido({
    required this.id,
    required this.cliente,
    required this.direccion,
    required this.productos,
    required this.ubicacion,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      cliente: json['cliente'],
      direccion: json['direccion'],
      productos: (json['productos'] as List)
          .map((p) => Producto.fromJson(p))
          .toList(),
      ubicacion: Ubicacion.fromJson(json['ubicacion']),
    );
  }
}
