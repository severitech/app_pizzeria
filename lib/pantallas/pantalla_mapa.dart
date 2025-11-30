import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mi_aplicacion_pizzeria/modelos/pedido.dart';
import 'package:mi_aplicacion_pizzeria/servicios/servicio_pedido.dart';
import 'package:provider/provider.dart';

class PantallaMapa extends StatefulWidget {
  final String pedidoId;

  const PantallaMapa({Key? key, required this.pedidoId}) : super(key: key);

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  late MapController _mapController;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  bool _isLoading = true;
  bool _pedidoEnLugar = false;

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
    // Los marcadores se configurarán con el pedido actual del Consumer
  }

  void _setupMarkersConPedido(Pedido pedido) {
    _markers.clear();
    
    // Extraer coordenadas de la dirección del cliente
    final clienteCoords = _extractCoordsFromAddress(pedido.direccion);
    
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
    _polylines.clear();
    
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

  void _fitMarkersToMap(LatLng clienteCoords) {
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

  Future<void> _mostrarDialogoConfirmacion(
    BuildContext context,
    String titulo,
    String mensaje,
    Function() onConfirm,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicioPedidos>(
      builder: (context, servicioPedidos, child) {
        final pedido = servicioPedidos.obtenerPedidoPorId(widget.pedidoId);
        
        if (pedido == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Mapa'),
              backgroundColor: const Color(0xFF667eea),
            ),
            body: const Center(
              child: Text('Pedido no encontrado'),
            ),
          );
        }

        // Configurar marcadores con el pedido actual
        if (_markers.isEmpty) {
          _setupMarkersConPedido(pedido);
        }

        final clienteCoords = _extractCoordsFromAddress(pedido.direccion);

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
                onPressed: () => _fitMarkersToMap(clienteCoords),
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
                          _fitMarkersToMap(clienteCoords);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.mi_aplicacion_pizzeria',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        PolylineLayer(
                          polylines: _polylines,
                        ),
                        MarkerLayer(
                          markers: _markers,
                        ),
                      ],
                    ),
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: _buildInfoCard(pedido, servicioPedidos),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: _buildLegend(),
                    ),
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
      },
    );
  }

  Widget _buildInfoCard(Pedido pedido, ServicioPedidos servicioPedidos) {
    final clienteCoords = _extractCoordsFromAddress(pedido.direccion);
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
                    'Pedido #${pedido.id.length > 6 ? pedido.id.substring(pedido.id.length - 6) : pedido.id}',
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
                      pedido.estado == 'En camino' && _pedidoEnLugar 
                          ? 'En camino - En el lugar' 
                          : pedido.estado,
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
                onPressed: () => _fitMarkersToMap(clienteCoords),
                tooltip: 'Ajustar vista a todos los marcadores',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationInfo(
            '📍 Cliente',
            _getShortAddress(pedido.direccion),
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
                  _formatProducts(pedido.items),
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
                      '${pedido.moneda} ${pedido.total.toStringAsFixed(2)}',
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
          // BOTONES DE ESTADO
          _buildBotonesEstado(pedido, servicioPedidos),
        ],
      ),
    );
  }

  Widget _buildBotonesEstado(Pedido pedido, ServicioPedidos servicioPedidos) {
    if (pedido.estado == 'Entregado') {
      return const SizedBox.shrink();
    }

    if (pedido.estado == 'Repartidor Asignado') {
      return Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.directions_bike, color: Colors.white, size: 20),
              label: const Text('MARCAR EN CAMINO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                await _mostrarDialogoConfirmacion(
                  context,
                  'Marcar en Camino',
                  '¿Estás listo para salir a entregar el pedido #${pedido.id.substring(pedido.id.length - 6)}?',
                  () async {
                    final exito = await servicioPedidos.enviarPedido(pedido.id);
                    if (mounted) {
                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🚚 Pedido #${pedido.id.substring(pedido.id.length - 6)} marcado como EN CAMINO'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        setState(() {
                          _pedidoEnLugar = false;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error al cambiar estado'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      );
    } else if (pedido.estado == 'En camino') {
      if (!_pedidoEnLugar) {
        return Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.location_on, color: Colors.white, size: 20),
                label: const Text('TU PEDIDO LLEGÓ AL LUGAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  await _mostrarDialogoConfirmacion(
                    context,
                    'Llegada al Lugar',
                    '¿Has llegado a la dirección del cliente con el pedido #${pedido.id.substring(pedido.id.length - 6)}?',
                    () async {
                      if (mounted) {
                        setState(() {
                          _pedidoEnLugar = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📍 Pedido #${pedido.id.substring(pedido.id.length - 6)} marcado como LLEGADO AL LUGAR'),
                            backgroundColor: Colors.blue,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                label: const Text('MARCAR COMO ENTREGADO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  await _mostrarDialogoConfirmacion(
                    context,
                    'Entregar Pedido',
                    '¿Has entregado el pedido #${pedido.id.substring(pedido.id.length - 6)} al cliente?',
                    () async {
                      final exito = await servicioPedidos.entregarPedido(pedido.id);
                      if (mounted) {
                        if (exito) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('✅ Pedido #${pedido.id.substring(pedido.id.length - 6)} ENTREGADO correctamente'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          setState(() {
                            _pedidoEnLugar = false;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error al entregar pedido'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }

  // ... (los demás métodos _buildLocationInfo, _formatProducts, _buildLegend, _buildLegendItem se mantienen igual)
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
}