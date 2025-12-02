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
    // DEBUG: Imprimir datos de calificación si existen
    if (json['restaurant_rating'] != null || json['delivery_rating'] != null) {
      print('🌟 CALIFICACIÓN ENCONTRADA:');
      print('   - restaurant_rating: ${json['restaurant_rating']}');
      print('   - delivery_rating: ${json['delivery_rating']}');
      print('   - comment: ${json['comment']}');
      print('   - JSON completo: $json');
    }

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
      // Manejar calificaciones: pueden venir directamente o dentro de un objeto 'rating'
      restaurantRating: _parsearCalificacion(json, 'restaurant_rating'),
      deliveryRating: _parsearCalificacion(json, 'delivery_rating'),
      comment: _parsearComentario(json),
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

  // Helper para parsear calificaciones que pueden venir en diferentes formatos
  static int? _parsearCalificacion(Map<String, dynamic> json, String campo) {
    // Caso 1: Calificación directamente en el JSON
    if (json[campo] != null) {
      if (json[campo] is int) {
        return json[campo];
      }
      return int.tryParse(json[campo].toString());
    }
    
    // Caso 2: Calificación dentro de un objeto 'rating'
    if (json['rating'] is Map) {
      final rating = json['rating'] as Map<String, dynamic>;
      if (rating[campo] != null) {
        if (rating[campo] is int) {
          return rating[campo];
        }
        return int.tryParse(rating[campo].toString());
      }
    }
    
    return null;
  }

  // Helper para parsear comentario
  static String? _parsearComentario(Map<String, dynamic> json) {
    // Caso 1: Comentario directamente en el JSON
    if (json['comment'] != null) {
      return json['comment'].toString();
    }
    
    // Caso 2: Comentario dentro de un objeto 'rating'
    if (json['rating'] is Map) {
      final rating = json['rating'] as Map<String, dynamic>;
      if (rating['comment'] != null) {
        return rating['comment'].toString();
      }
    }
    
    return null;
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
      restaurantRating: restaurantRating,  // Preservar calificaciones
      deliveryRating: deliveryRating,       // Preservar calificaciones
      comment: comment,                      // Preservar comentario
    );
  }
}
