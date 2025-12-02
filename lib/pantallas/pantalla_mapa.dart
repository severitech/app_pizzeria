import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:mi_aplicacion_pizzeria/modelos/pedido.dart';
import 'package:mi_aplicacion_pizzeria/servicios/api_servicios.dart';
import 'package:mi_aplicacion_pizzeria/servicios/servicio_pedido.dart';
import 'package:provider/provider.dart';

class PantallaMapa extends StatefulWidget {
  final String? pedidoId;
  final bool mostrarAtras;

  const PantallaMapa({super.key, this.pedidoId, this.mostrarAtras = true});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  late MapController _mapController;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  bool _isLoading = true;
  bool _pedidoEnLugar = false;
  LocationData? _currentLocation;
  Timer? _timerActualizacionUbicacion;
  
  // Variables estáticas para preservar FakeGPS entre cambios de TAB
  static LatLng? _simulatedLocation;
  static bool _modoFakeGPSActivo = false;
  
  final Location _locationService = Location();

  // Coordenadas del restaurante (fijas)
  // static const LatLng _restauranteCoords = LatLng(-17.7832662, -63.1820985);
  // Coordenadas desplazadas para visualización en mapa (evita superposición exacta)
  static const LatLng _restauranteMapCoords = LatLng(-17.7836162, -63.1814985);

  // Colores para los marcadores
  static const Color _colorRestaurante = Color(0xFF667eea);
  static const Color _colorCliente = Color(0xFF4CAF50);
  static const Color _colorRepartidor = Color(0xFFFF9800);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // NO limpiar _simulatedLocation ni _modoFakeGPSActivo (son estáticos/globales)
    // Se conservan entre cambios de TAB
    _currentLocation = null; // Limpiar ubicación anterior
    _pedidoEnLugar = false;
    _markers.clear();
    _polylines.clear();
    _obtenerUbicacionActual();
    _initializeMap();
    _iniciarActualizacionPeriodicaUbicacion();
  }

  @override
  void didUpdateWidget(PantallaMapa oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Solo limpiar FakeGPS si cambias a un PEDIDO DIFERENTE
    // (no cuando cambias entre Mapa ↔ Pedidos sin seleccionar un pedido específico)
    final ambosConPedidosDiferentes = oldWidget.pedidoId != null && 
                                       widget.pedidoId != null && 
                                       oldWidget.pedidoId != widget.pedidoId;
    
    if (ambosConPedidosDiferentes) {
      // Solo limpiar si cambias de un pedido a OTRO PEDIDO diferente
      _markers.clear();
      _polylines.clear();
      _pedidoEnLugar = false;
      _simulatedLocation = null;
      _modoFakeGPSActivo = false;
      _currentLocation = null;
      
      _initializeMap();
      
      if (mounted) {
        Future.microtask(() {
          setState(() {});
        });
      }
    }
  }

  // Helper para obtener ID corto de forma segura
  String _obtenerIdCorto(String id) {
    if (id.isEmpty) return 'Sin ID';
    if (id.length <= 6) return id;
    return id.substring(id.length - 6);
  }

  Future<void> _obtenerUbicacionActual() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final locationData = await _locationService.getLocation();
    if (mounted) {
      // SOLO actualizar _currentLocation si FakeGPS NO está activo
      if (!_modoFakeGPSActivo) {
        _currentLocation = locationData;
      }
      // Si estamos en modo genérico (sin pedido), actualizar el mapa UNA SOLA VEZ
      if (widget.pedidoId == null && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Escuchar cambios de ubicación pero NO reconstruir el widget cada vez
    _locationService.onLocationChanged.listen((LocationData currentLocation) {
      if (mounted && !_modoFakeGPSActivo) {
        // SOLO actualizar si FakeGPS NO está activo
        _currentLocation = currentLocation; // Solo actualizar la variable, sin setState
      }
    });
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

    // Extraer coordenadas del cliente desde el campo 'location' del pedido
    LatLng clienteCoords;
    if (pedido.ubicacion != null &&
        pedido.ubicacion!['latitude'] != null &&
        pedido.ubicacion!['longitude'] != null) {
      clienteCoords = LatLng(
        (pedido.ubicacion!['latitude'] as num).toDouble(),
        (pedido.ubicacion!['longitude'] as num).toDouble(),
      );
    } else {
      // Si no hay ubicación en el modelo, intentar extraer de la dirección
      clienteCoords = _extractCoordsFromAddress(pedido.direccion);
    }

    // Coordenadas del restaurante (SIEMPRE usar las del backend)
    LatLng restauranteCoords;
    if (pedido.restaurantLocation != null &&
        pedido.restaurantLocation!['latitude'] != null &&
        pedido.restaurantLocation!['longitude'] != null) {
      restauranteCoords = LatLng(
        (pedido.restaurantLocation!['latitude'] as num).toDouble(),
        (pedido.restaurantLocation!['longitude'] as num).toDouble(),
      );
    } else {
      // Fallback SOLO si el backend no envió las coordenadas
      print('⚠️ ADVERTENCIA: No hay coordenadas del restaurante en el pedido');
      restauranteCoords = _restauranteMapCoords;
    }

    // Coordenadas del repartidor SIMULADAS según el estado del pedido
    LatLng repartidorCoords = _calcularPosicionRepartidor(
      pedido.estado,
      restauranteCoords,
      clienteCoords,
    );

    // Calcular distancia al destino según el estado
    final destino = (pedido.estado == 'Repartidor Asignado')
        ? restauranteCoords
        : clienteCoords;
    final distance = const Distance().as(
      LengthUnit.Meter,
      repartidorCoords,
      destino,
    );

    // Marcador del restaurante
    _markers.add(
      Marker(
        point: restauranteCoords,
        width: 80,
        height: 80,
        child: _buildCustomMarker('🏪', 'Restaurante', _colorRestaurante),
      ),
    );

    // Marcador del cliente
    _markers.add(
      Marker(
        point: clienteCoords,
        width: 80,
        height: 80,
        child: _buildCustomMarker('📍', 'Cliente', _colorCliente),
      ),
    );

    // Marcador del repartidor con mensaje según el estado
    String labelRepartidor;
    if (pedido.estado == 'Repartidor Asignado') {
      labelRepartidor = 'Tú - En restaurante';
    } else if (pedido.estado == 'En camino' && !_pedidoEnLugar) {
      labelRepartidor = 'Tú (${distance.toStringAsFixed(0)}m al destino)';
    } else if (_pedidoEnLugar || pedido.estado == 'Entregado') {
      labelRepartidor = 'Tú - En destino';
    } else {
      labelRepartidor = 'Tú';
    }

    _markers.add(
      Marker(
        point: repartidorCoords,
        width: 80,
        height: 80,
        child: _buildCustomMarker('🚗', labelRepartidor, _colorRepartidor),
      ),
    );

    // Crear polilíneas
    _createPolylines(restauranteCoords, clienteCoords, repartidorCoords);
  }

  // Calcular posición simulada del repartidor según el estado
  LatLng _calcularPosicionRepartidor(
    String estado,
    LatLng restauranteCoords,
    LatLng clienteCoords,
  ) {
    // Si hay ubicación simulada (FakeGPS), usarla
    if (_simulatedLocation != null) {
      return _simulatedLocation!;
    }

    switch (estado) {
      case 'Repartidor Asignado':
        // Está en el restaurante recogiendo el pedido
        return restauranteCoords;

      case 'En camino':
        if (_pedidoEnLugar) {
          // Ya llegó, mostrar en la ubicación del cliente
          return clienteCoords;
        } else {
          // Está en ruta, calcular punto medio más cercano al cliente (70% del camino)
          final latDiff = clienteCoords.latitude - restauranteCoords.latitude;
          final lngDiff = clienteCoords.longitude - restauranteCoords.longitude;
          return LatLng(
            restauranteCoords.latitude + (latDiff * 0.7),
            restauranteCoords.longitude + (lngDiff * 0.7),
          );
        }

      case 'Entregado':
        // En la ubicación del cliente
        return clienteCoords;

      default:
        // Por defecto, cerca del restaurante
        return LatLng(
          restauranteCoords.latitude + 0.001,
          restauranteCoords.longitude + 0.001,
        );
    }
  }

  Widget _buildCustomMarker(String emoji, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
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
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  LatLng _extractCoordsFromAddress(String address) {
    try {
      // Intentar parsear coordenadas explícitas en el texto
      final coordsMatch = RegExp(
        r'Coords?:?\s*(-?\d+\.\d+),\s*(-?\d+\.\d+)',
      ).firstMatch(address);

      if (coordsMatch != null) {
        final lat = double.parse(coordsMatch.group(1)!);
        final lng = double.parse(coordsMatch.group(2)!);
        return LatLng(lat, lng);
      }

      // Si no hay formato explícito, buscar cualquier par de números que parezcan coordenadas
      // (latitud entre -90 y 90, longitud entre -180 y 180)
      final generalMatch = RegExp(
        r'(-?\d+\.\d+)[,\s]+(-?\d+\.\d+)',
      ).firstMatch(address);
      if (generalMatch != null) {
        final lat = double.parse(generalMatch.group(1)!);
        final lng = double.parse(generalMatch.group(2)!);
        if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
          return LatLng(lat, lng);
        }
      }
    } catch (e) {
      print('Error extrayendo coordenadas: $e');
    }

    // Si falla, devolver una ubicación por defecto (pero loguear el error)
    print('⚠️ No se pudieron extraer coordenadas de: $address');
    return const LatLng(-17.7865, -63.1785);
  }

  void _createPolylines(
    LatLng restaurantePos,
    LatLng clientePos,
    LatLng repartidorPos,
  ) {
    _polylines.clear();

    // Línea de ruta completa (restaurante a cliente) - ruta planificada
    _polylines.add(
      Polyline(
        points: [restaurantePos, clientePos],
        color: _colorRestaurante.withValues(alpha: 0.3),
        strokeWidth: 3,
        isDotted: true,
      ),
    );

    // Línea de progreso actual (repartidor a destino)
    _polylines.add(
      Polyline(
        points: [repartidorPos, clientePos],
        color: _colorRepartidor.withValues(alpha: 0.8),
        strokeWidth: 4,
        isDotted: false,
      ),
    );

    // Línea del recorrido realizado (restaurante a posición actual)
    if (repartidorPos != restaurantePos) {
      _polylines.add(
        Polyline(
          points: [restaurantePos, repartidorPos],
          color: Colors.green.withValues(alpha: 0.6),
          strokeWidth: 4,
          isDotted: false,
        ),
      );
    }
  }

  void _fitMarkersToMap(LatLng clienteCoords) {
    if (_markers.isNotEmpty) {
      final bounds = _boundsFromMarkers();
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
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

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
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

  /// Activar/desactivar modo FakeGPS interactivo
  void _alternarModoFakeGPS() {
    setState(() {
      _modoFakeGPSActivo = !_modoFakeGPSActivo;
    });

    if (_modoFakeGPSActivo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '🎮 Modo FakeGPS ACTIVO - Toca el mapa para mover tu ubicación',
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎮 Modo FakeGPS desactivado'),
          backgroundColor: Colors.grey.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Manejar el toque en el mapa para simular ubicación
  void _onMapTap(LatLng position) async {
    if (_modoFakeGPSActivo) {
      setState(() {
        _simulatedLocation = position;
        
        // Si hay un pedido específico, recalcular marcadores
        if (widget.pedidoId != null) {
          final servicioPedidos = context.read<ServicioPedidos>();
          final pedido = servicioPedidos.obtenerPedidoPorId(widget.pedidoId!);
          if (pedido != null) {
            _setupMarkersConPedido(pedido);
          }
        } else {
          // Si no hay pedido (mapa genérico), simplemente actualizar _simulatedLocation
          // Los marcadores se recalculan en el build del mapa genérico
        }
      });

      // Actualizar ubicación en el backend
      try {
        final apiServicios = ApiServicios();
        await apiServicios.actualizarUbicacionConductor(
          position.latitude,
          position.longitude,
        );
        print('✅ Ubicación FakeGPS actualizada en backend: ${position.latitude}, ${position.longitude}');
      } catch (error) {
        print('❌ Error al actualizar ubicación en backend: $error');
      }

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📍 Ubicación simulada: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _iniciarActualizacionPeriodicaUbicacion() {
    // Enviar ubicación al backend cada 30 segundos para mantener actualizada la posición del conductor
    _timerActualizacionUbicacion = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final apiServicios = ApiServicios();
        LatLng ubicacionAEnviar;
        
        // Usar FakeGPS si está activo, sino usar ubicación real
        if (_simulatedLocation != null) {
          ubicacionAEnviar = _simulatedLocation!;
        } else if (_currentLocation != null) {
          ubicacionAEnviar = LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          );
        } else {
          // Si no hay ubicación, usar ubicación del restaurante por defecto
          ubicacionAEnviar = _restauranteMapCoords;
        }
        
        await apiServicios.actualizarUbicacionConductor(
          ubicacionAEnviar.latitude,
          ubicacionAEnviar.longitude,
        );
        print('✅ Ubicación actualizada periódicamente: ${ubicacionAEnviar.latitude}, ${ubicacionAEnviar.longitude}');
      } catch (error) {
        print('❌ Error al actualizar ubicación periódica: $error');
      }
    });
    
    // Enviar ubicación inmediatamente al iniciar
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final apiServicios = ApiServicios();
        LatLng ubicacionAEnviar = _simulatedLocation ?? 
                                 (_currentLocation != null 
                                   ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                                   : _restauranteMapCoords);
        await apiServicios.actualizarUbicacionConductor(
          ubicacionAEnviar.latitude,
          ubicacionAEnviar.longitude,
        );
        print('✅ Ubicación inicial enviada: ${ubicacionAEnviar.latitude}, ${ubicacionAEnviar.longitude}');
      } catch (error) {
        print('❌ Error al enviar ubicación inicial: $error');
      }
    });
  }

  @override
  void dispose() {
    _timerActualizacionUbicacion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ServicioPedidos, Pedido?>(
      selector: (context, servicioPedidos) {
        if (widget.pedidoId != null) {
          return servicioPedidos.obtenerPedidoPorId(widget.pedidoId!);
        }
        return null;
      },
      shouldRebuild: (previous, next) {
        // Reconstruir si cambió el pedido, su estado, ubicación o si el FakeGPS cambió la ubicación simulada
        if (previous == null && next == null) return true; // Reconstruir siempre si ambos son null (permite refrescar con FakeGPS)
        if (previous == null || next == null) return true;
        return previous.id != next.id ||
            previous.estado != next.estado ||
            previous.ubicacion != next.ubicacion;
      },
      builder: (context, pedido, child) {
        // Si no hay pedido específico, mostrar mapa genérico
        if (pedido == null) {
          return _buildMapaGenerico();
        }

        // Configurar marcadores con el pedido actual
        _setupMarkersConPedido(pedido);

        // Usar las coordenadas correctas del pedido
        LatLng clienteCoords;
        if (pedido.ubicacion != null &&
            pedido.ubicacion!['latitude'] != null &&
            pedido.ubicacion!['longitude'] != null) {
          clienteCoords = LatLng(
            (pedido.ubicacion!['latitude'] as num).toDouble(),
            (pedido.ubicacion!['longitude'] as num).toDouble(),
          );
        } else {
          clienteCoords = _extractCoordsFromAddress(pedido.direccion);
        }

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
            leading: widget.mostrarAtras
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF667eea),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: clienteCoords,
                        initialZoom: 14.0,
                        onMapReady: () {
                          _fitMarkersToMap(clienteCoords);
                        },
                        onTap: (tapPosition, latLng) {
                          _onMapTap(latLng);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.example.mi_aplicacion_pizzeria',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        PolylineLayer(polylines: _polylines),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: _buildInfoCard(
                        pedido,
                        context.read<ServicioPedidos>(),
                      ),
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
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'fake_gps',
                            onPressed: _alternarModoFakeGPS,
                            backgroundColor: _modoFakeGPSActivo ? Colors.red : Colors.orange,
                            tooltip: _modoFakeGPSActivo ? 'FakeGPS: ACTIVO (toca para mover)' : 'FakeGPS: Desactivado',
                            child: Icon(_modoFakeGPSActivo ? Icons.videogame_asset : Icons.videogame_asset_outlined),
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
    // Usar las MISMAS coordenadas que se usan en los marcadores
    LatLng clienteCoords;
    if (pedido.ubicacion != null &&
        pedido.ubicacion!['latitude'] != null &&
        pedido.ubicacion!['longitude'] != null) {
      clienteCoords = LatLng(
        (pedido.ubicacion!['latitude'] as num).toDouble(),
        (pedido.ubicacion!['longitude'] as num).toDouble(),
      );
    } else {
      clienteCoords = _extractCoordsFromAddress(pedido.direccion);
    }

    LatLng restauranteCoords;
    if (pedido.restaurantLocation != null &&
        pedido.restaurantLocation!['latitude'] != null &&
        pedido.restaurantLocation!['longitude'] != null) {
      restauranteCoords = LatLng(
        (pedido.restaurantLocation!['latitude'] as num).toDouble(),
        (pedido.restaurantLocation!['longitude'] as num).toDouble(),
      );
    } else {
      restauranteCoords = _restauranteMapCoords;
    }

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
            color: Colors.black.withValues(alpha: 0.3),
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
                    'Pedido #${_obtenerIdCorto(pedido.id)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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
                      if (_modoFakeGPSActivo) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videogame_asset,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'FakeGPS ACTIVO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
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
              color: Colors.white.withValues(alpha: 0.1),
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
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
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
              icon: const Icon(
                Icons.directions_bike,
                color: Colors.white,
                size: 20,
              ),
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
                  '¿Estás listo para salir a entregar el pedido #${_obtenerIdCorto(pedido.id)}?',
                  () async {
                    final exito = await servicioPedidos.enviarPedido(pedido.id);
                    if (mounted) {
                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🚚 Pedido #${_obtenerIdCorto(pedido.id)} marcado como EN CAMINO',
                            ),
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
                icon: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
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
                    '¿Has llegado a la dirección del cliente con el pedido #${_obtenerIdCorto(pedido.id)}?',
                    () async {
                      if (mounted) {
                        setState(() {
                          _pedidoEnLugar = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '📍 Pedido #${_obtenerIdCorto(pedido.id)} marcado como LLEGADO AL LUGAR',
                            ),
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
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
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
                    '¿Has entregado el pedido #${_obtenerIdCorto(pedido.id)} al cliente?',
                    () async {
                      final exito = await servicioPedidos.entregarPedido(
                        pedido.id,
                      );
                      if (mounted) {
                        if (exito) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Pedido #${_obtenerIdCorto(pedido.id)} ENTREGADO correctamente',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          // Limpiar estado para permitir que el mapa se reinicie
                          setState(() {
                            _pedidoEnLugar = false;
                            _markers.clear();
                            _polylines.clear();
                          });
                          // Si estamos en la navegación por tabs, el mapa se reconstruirá automáticamente
                          // Si estamos en navegación push, volver atrás
                          if (widget.mostrarAtras) {
                            Navigator.of(context).pop();
                          }
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
  Widget _buildLocationInfo(
    String title,
    String subtitle,
    LatLng coords,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
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
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${coords.latitude.toStringAsFixed(6)}, ${coords.longitude.toStringAsFixed(6)}',
                style: const TextStyle(color: Colors.white60, fontSize: 10),
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
            color: Colors.black.withValues(alpha: 0.1),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

  Widget _buildMapaGenerico() {
    // Coordenadas por defecto (Restaurante)
    final restauranteCoords = _restauranteMapCoords;

    // Coordenadas del repartidor (usar ubicación simulada si está disponible, sino usar real)
    LatLng repartidorCoords;
    if (_simulatedLocation != null) {
      // Si hay ubicación simulada (FakeGPS), usarla
      repartidorCoords = _simulatedLocation!;
    } else if (_currentLocation != null) {
      repartidorCoords = LatLng(
        _currentLocation!.latitude!,
        _currentLocation!.longitude!,
      );
    } else {
      // Si no hay GPS, mostrar una ubicación cercana pero claramente distinta
      repartidorCoords = LatLng(
        restauranteCoords.latitude + 0.005,
        restauranteCoords.longitude + 0.005,
      );
    } // Calcular distancia
    final distance = const Distance().as(
      LengthUnit.Meter,
      repartidorCoords,
      restauranteCoords,
    );

    // Marcadores básicos
    final markers = [
      Marker(
        point: restauranteCoords,
        width: 80,
        height: 80,
        child: _buildCustomMarker('🏪', 'Restaurante', _colorRestaurante),
      ),
      Marker(
        point: repartidorCoords,
        width: 80,
        height: 80,
        child: _buildCustomMarker(
          '🚗',
          'Tú (${distance.toStringAsFixed(0)}m)',
          _colorRepartidor,
        ),
      ),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Mapa',
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
        leading: widget.mostrarAtras
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: repartidorCoords, // Centrar en el repartidor
              initialZoom: 14.0,
              onTap: (tapPosition, latLng) {
                _onMapTap(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mi_aplicacion_pizzeria',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('🚗 Tú', Colors.orange),
                  _buildLegendItem('🏪 Restaurante', Colors.blue),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: () {
                    if (_currentLocation != null) {
                      _mapController.move(
                        LatLng(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                        ),
                        15.0,
                      );
                    } else {
                      _obtenerUbicacionActual();
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'fake_gps_generic',
                  onPressed: _alternarModoFakeGPS,
                  backgroundColor: _modoFakeGPSActivo ? Colors.red : Colors.orange,
                  tooltip: _modoFakeGPSActivo ? 'FakeGPS: ACTIVO (toca para mover)' : 'FakeGPS: Desactivado',
                  child: Icon(_modoFakeGPSActivo ? Icons.videogame_asset : Icons.videogame_asset_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
