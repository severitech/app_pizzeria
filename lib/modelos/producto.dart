class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String emoji;
  final String imagen;
  final String categoria;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.emoji,
    required this.imagen,
    required this.categoria,
  });

  factory Producto.desdeJson(Map<String, dynamic> json, String categoria) {
    return Producto(
      id: json['id']?.toString() ?? '',
      nombre: json['name']?.toString() ?? '',
      descripcion: json['description']?.toString() ?? '',
      precio: (json['price'] as num?)?.toDouble() ?? 0.0,
      emoji: json['emoji']?.toString() ?? '🍕',
      imagen: json['image']?.toString() ?? '',
      categoria: categoria,
    );
  }
}