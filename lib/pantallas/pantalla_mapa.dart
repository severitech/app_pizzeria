import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mi_aplicacion_pizzeria/modelos/pedido.dart';

class PantallaMapa extends StatefulWidget {
  final Pedido pedido;

  const PantallaMapa({Key? key, required this.pedido}) : super(key: key);

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  late MapController _mapController;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  bool _isLoading = true;

  // Colores para los marcadores
  static const Color _colorRestaurante = Color(0xFF667eea);
  static const Color _colorCliente = Color(0xFF4CAF50);
  static const Color _colorRepartidor = Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMap();
  }

  void _initializeMap() {
    _setupMarkers();
    setState(() => _isLoading = false);
  }

  void _setupMarkers() {
    // Extraer coordenadas de la dirección del cliente
    final clienteCoords = _extractCoordsFromAddress(widget.pedido.direccion);
    
    // Coordenadas del restaurante (por defecto)
    final restauranteCoords = const LatLng(-17.827459, -63.169474);
    
    // Coordenadas del repartidor (simuladas cerca del restaurante)
    final repartidorCoords = LatLng(
      restauranteCoords.latitude + 0.002, 
      restauranteCoords.longitude + 0.002
    );

    // Marcador del restaurante
    _markers.add(
      Marker(
        point: restauranteCoords,
        width: 50,
        height: 50,
        child: _buildCustomMarker('🏪', 'Restaurante', _colorRestaurante),
      ),
    );

    // Marcador del cliente
    _markers.add(
      Marker(
        point: clienteCoords,
        width: 50,
        height: 50,
        child: _buildCustomMarker('📍', 'Cliente', _colorCliente),
      ),
    );

    // Marcador del repartidor
    _markers.add(
      Marker(
        point: repartidorCoords,
        width: 50,
        height: 50,
        child: _buildCustomMarker('🚗', 'Tú', _colorRepartidor),
      ),
    );

    // Crear polilíneas
    _createPolylines(restauranteCoords, clienteCoords, repartidorCoords);
  }

  Widget _buildCustomMarker(String emoji, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  LatLng _extractCoordsFromAddress(String address) {
    try {
      final coordsMatch = RegExp(r'Coords?:?\s*(-?\d+\.\d+),\s*(-?\d+\.\d+)').firstMatch(address);
      if (coordsMatch != null) {
        final lat = double.parse(coordsMatch.group(1)!);
        final lng = double.parse(coordsMatch.group(2)!);
        return LatLng(lat, lng);
      }
    } catch (e) {
      print('Error extrayendo coordenadas: $e');
    }
    
    return const LatLng(-17.7865, -63.1785);
  }

  void _createPolylines(LatLng restaurantePos, LatLng clientePos, LatLng repartidorPos) {
    // Línea de restaurante a cliente
    _polylines.add(
      Polyline(
        points: [restaurantePos, clientePos],
        color: _colorRestaurante.withOpacity(0.7),
        strokeWidth: 4,
        isDotted: true,
      ),
    );

    // Línea de repartidor a restaurante
    _polylines.add(
      Polyline(
        points: [repartidorPos, restaurantePos],
        color: _colorRepartidor.withOpacity(0.7),
        strokeWidth: 3,
        isDotted: true,
      ),
    );
  }

  void _fitMarkersToMap() {
    if (_markers.isNotEmpty) {
      final bounds = _boundsFromMarkers();
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(
          padding: EdgeInsets.all(50),
        ),
      );
    }
  }

  LatLngBounds _boundsFromMarkers() {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (Marker marker in _markers) {
      double lat = marker.point.latitude;
      double lng = marker.point.longitude;

      minLat = minLat < lat ? minLat : lat;
      maxLat = maxLat > lat ? maxLat : lat;
      minLng = minLng < lng ? minLng : lng;
      maxLng = maxLng > lng ? maxLng : lng;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  String _getShortAddress(String fullAddress) {
    return fullAddress.split(',').first;
  }

  Widget _buildInfoCard() {
    final clienteCoords = _extractCoordsFromAddress(widget.pedido.direccion);
    final restauranteCoords = const LatLng(-17.827459, -63.169474);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${widget.pedido.id.length > 6 ? widget.pedido.id.substring(widget.pedido.id.length - 6) : widget.pedido.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.pedido.estado,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white),
                onPressed: _fitMarkersToMap,
                tooltip: 'Ajustar vista a todos los marcadores',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationInfo(
            '📍 Cliente',
            _getShortAddress(widget.pedido.direccion),
            clienteCoords,
            Icons.person_pin_circle,
          ),
          const SizedBox(height: 12),
          _buildLocationInfo(
            '🏪 Restaurante',
            'Punto de recogida',
            restauranteCoords,
            Icons.restaurant,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📦 Productos del Pedido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatProducts(widget.pedido.items),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total del pedido:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${widget.pedido.moneda} ${widget.pedido.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String title, String subtitle, LatLng coords, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatProducts(List<dynamic> items) {
    if (items.isEmpty) return 'No hay productos en el pedido';
    
    final productList = items.map((item) {
      final name = item['name'] ?? 'Producto';
      final quantity = item['quantity'] ?? 1;
      return '• $name x$quantity';
    }).toList();
    
    return productList.join('\n');
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('🚗 Tú', Colors.orange),
          _buildLegendItem('📍 Cliente', Colors.green),
          _buildLegendItem('🏪 Restaurante', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final clienteCoords = _extractCoordsFromAddress(widget.pedido.direccion);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Seguimiento del Pedido',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map, color: Colors.white),
            onPressed: _fitMarkersToMap,
            tooltip: 'Ajustar vista',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: clienteCoords,
                    zoom: 14.0,
                    onMapReady: () {
                      _fitMarkersToMap();
                    },
                  ),
                  children: [
                    // Capa de tiles (mapa)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mi_aplicacion_pizzeria',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // Capa de polilíneas
                    PolylineLayer(
                      polylines: _polylines,
                    ),
                    // Capa de marcadores
                    MarkerLayer(
                      markers: _markers,
                    ),
                  ],
                ),
                // Tarjeta de información
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: _buildInfoCard(),
                ),
                // Leyenda
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: _buildLegend(),
                ),
                // Controles de zoom
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        ),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: () => _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        ),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}