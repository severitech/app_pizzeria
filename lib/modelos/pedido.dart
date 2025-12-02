class Pedido {
  final String id;
  final double total;
  final List<dynamic> items;
  final String direccion;
  final Map<String, dynamic>? ubicacion;
  final String metodoPago;
  final DateTime fecha;
  final String estado;
  final String moneda;
  final bool estaCalificado;
  final Map<String, dynamic>? restaurantLocation;
  final int? restaurantRating;  // Calificación del restaurante (1-5)
  final int? deliveryRating;     // Calificación del delivery (1-5)
  final String? comment;          // Comentario opcional

  Pedido({
    required this.id,
    required this.total,
    required this.items,
    required this.direccion,
    this.ubicacion,
    required this.metodoPago,
    required this.fecha,
    required this.estado,
    required this.moneda,
    required this.estaCalificado,
    this.restaurantLocation,
    this.restaurantRating,
    this.deliveryRating,
    this.comment,
  });

  factory Pedido.vacio() {
    return Pedido(
      id: '',
      items: [],
      total: 0,
      direccion: '',
      estado: '',
      fecha: DateTime.now(),
      moneda: 'Bs',
      metodoPago: '',
      estaCalificado: false,
    );
  }
  factory Pedido.desdeJson(Map<String, dynamic> json) {
    // Manejar el total que puede venir como String o num
    double totalParseado = 0.0;
    if (json['total'] != null) {
      if (json['total'] is String) {
        totalParseado = double.tryParse(json['total']) ?? 0.0;
      } else if (json['total'] is num) {
        totalParseado = (json['total'] as num).toDouble();
      }
    }

    return Pedido(
      id: json['id']?.toString() ?? 'Sin ID',
      total: totalParseado,
      items: json['items'] is List ? json['items'] : [],
      direccion: json['address']?.toString() ?? 'Dirección no especificada',
      ubicacion: json['location'] is Map
          ? Map<String, dynamic>.from(json['location'])
          : null,
      metodoPago: json['paymentMethod']?.toString() ?? 'Efectivo',
      fecha: _parsearFecha(json['date']?.toString(), json['date_ts']),
      estado: json['status']?.toString() ?? 'Pendiente',
      moneda: json['currency']?.toString() ?? 'Bs',
      estaCalificado: json['isRated'] == true,
      restaurantLocation: json['restaurant_location'] is Map
          ? Map<String, dynamic>.from(json['restaurant_location'])
          : null,
      restaurantRating: json['restaurant_rating'] is int 
          ? json['restaurant_rating'] 
          : (json['restaurant_rating'] != null ? int.tryParse(json['restaurant_rating'].toString()) : null),
      deliveryRating: json['delivery_rating'] is int 
          ? json['delivery_rating'] 
          : (json['delivery_rating'] != null ? int.tryParse(json['delivery_rating'].toString()) : null),
      comment: json['comment']?.toString(),
    );
  }

  static DateTime _parsearFecha(String? fechaString, dynamic timestamp) {
    if (fechaString != null) {
      try {
        return DateTime.parse(fechaString);
      } catch (e) {
        print('Error parseando fecha: $e');
      }
    }

    if (timestamp != null) {
      try {
        final ts = timestamp is int
            ? timestamp
            : int.tryParse(timestamp.toString());
        if (ts != null) {
          return DateTime.fromMillisecondsSinceEpoch(ts);
        }
      } catch (e) {
        print('Error parseando timestamp: $e');
      }
    }

    return DateTime.now();
  }

  Pedido copyWith({String? estado, bool? estaCalificado}) {
    return Pedido(
      id: id,
      total: total,
      items: items,
      direccion: direccion,
      ubicacion: ubicacion,
      metodoPago: metodoPago,
      fecha: fecha,
      estado: estado ?? this.estado,
      moneda: moneda,
      estaCalificado: estaCalificado ?? this.estaCalificado,
      restaurantLocation: restaurantLocation,
    );
  }
}
