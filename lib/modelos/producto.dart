class Producto {
  final String nombre;
  final int cantidad;

  Producto({required this.nombre, required this.cantidad});

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      nombre: json['nombre'],
      cantidad: json['cantidad'],
    );
  }
}
