class Ubicacion {
  final double latitud;
  final double longitud;
  final String? direccion;

  Ubicacion({
    required this.latitud,
    required this.longitud,
    this.direccion,
  });

  factory Ubicacion.desdeJson(Map<String, dynamic> json) {
    return Ubicacion(
      latitud: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitud: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      direccion: json['display_name']?.toString(),
    );
  }
}