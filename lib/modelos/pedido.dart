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
    );
  }
}
