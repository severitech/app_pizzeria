import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../modelos/pedido.dart';

class PantallaMapa extends StatefulWidget {
  final Pedido? pedido;

  const PantallaMapa({Key? key, this.pedido}) : super(key: key);

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  LatLng? puntoCliente;
  LatLng? puntoDelivery;
  LatLng? ubicacionActual;
  final Location _location = Location();
  MapController mapController = MapController();
  bool _isLoading = true;
  String _selectedTileLayer = 'openstreetmap';

  final List<Map<String, String>> _tileProviders = [
    {
      'name': 'CartoDB',
      'url': 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
      'subdomains': 'a,b,c,d',
    },
    {
      'name': 'OpenStreetMap',
      'url': 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      'subdomains': 'a,b,c',
    },
    {
      'name': 'Stamen Toner',
      'url': 'https://stamen-tiles-{s}.a.ssl.fastly.net/toner/{z}/{x}/{y}.png',
      'subdomains': 'a,b,c,d',
    },
    {
      'name': 'Stamen Watercolor',
      'url': 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
      'subdomains': 'a,b,c,d',
    },
  ];

  @override
  void initState() {
    super.initState();
    _inicializarUbicaciones();
    _obtenerUbicacionActual();
  }

  void _inicializarUbicaciones() {
    // Usar ubicación del pedido si está disponible
    if (widget.pedido?.ubicacion != null) {
      final ubicacion = widget.pedido!.ubicacion!;
      puntoCliente = LatLng(
        (ubicacion['latitude'] as num?)?.toDouble() ?? -17.7900,
        (ubicacion['longitude'] as num?)?.toDouble() ?? -63.1700,
      );
    } else {
      puntoCliente = const LatLng(-17.7900, -63.1700);
    }
    
    puntoDelivery = const LatLng(-17.8000, -63.1600);
  }

  Future<void> _obtenerUbicacionActual() async {
    try {
      bool servicioHabilitado = await _location.serviceEnabled();
      if (!servicioHabilitado) {
        servicioHabilitado = await _location.requestService();
        if (!servicioHabilitado) {
          setState(() => _isLoading = false);
          return;
        }
      }
      
      PermissionStatus permiso = await _location.hasPermission();
      if (permiso == PermissionStatus.denied) {
        permiso = await _location.requestPermission();
      }
      
      if (permiso == PermissionStatus.granted) {
        final ubicacion = await _location.getLocation();
        setState(() {
          ubicacionActual = LatLng(ubicacion.latitude!, ubicacion.longitude!);
          _isLoading = false;
        });
        _mostrarAmbos();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _centrarEnDriver() {
    if (ubicacionActual != null) {
      mapController.move(ubicacionActual!, 16);
    } else if (puntoDelivery != null) {
      mapController.move(puntoDelivery!, 16);
    }
  }

  void _centrarEnCliente() {
    if (puntoCliente != null) {
      mapController.move(puntoCliente!, 16);
    }
  }

  void _mostrarAmbos() {
    final puntos = <LatLng>[];
    if (puntoCliente != null) puntos.add(puntoCliente!);
    if (ubicacionActual != null) {
      puntos.add(ubicacionActual!);
    } else if (puntoDelivery != null) {
      puntos.add(puntoDelivery!);
    }

    if (puntos.length >= 2) {
      double latMin = puntos[0].latitude;
      double latMax = puntos[0].latitude;
      double lngMin = puntos[0].longitude;
      double lngMax = puntos[0].longitude;

      for (final punto in puntos) {
        latMin = punto.latitude < latMin ? punto.latitude : latMin;
        latMax = punto.latitude > latMax ? punto.latitude : latMax;
        lngMin = punto.longitude < lngMin ? punto.longitude : lngMin;
        lngMax = punto.longitude > lngMax ? punto.longitude : lngMax;
      }

      final lat = (latMin + latMax) / 2;
      final lng = (lngMin + lngMax) / 2;
      mapController.move(LatLng(lat, lng), 14);
    }
  }

  void _cambiarTileLayer(String providerName) {
    setState(() {
      _selectedTileLayer = providerName;
    });
  }

  Widget _buildTileLayer() {
    final provider = _tileProviders.firstWhere(
      (p) => p['name'] == _selectedTileLayer,
      orElse: () => _tileProviders.first,
    );

    return TileLayer(
      urlTemplate: provider['url']!,
      subdomains: provider['subdomains']!.split(','),
      userAgentPackageName: 'com.example.pizzeria_delivery',
    );
  }

  Widget _buildMarker(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> marcadores = [];

    // Marcador del cliente
    if (puntoCliente != null) {
      marcadores.add(
        Marker(
          point: puntoCliente!,
          width: 80,
          height: 80,
          child: _buildMarker(Icons.location_on, 'Cliente', const Color(0xFFF44336)),
        ),
      );
    }

    // Marcador del repartidor
    if (ubicacionActual != null) {
      marcadores.add(
        Marker(
          point: ubicacionActual!,
          width: 80,
          height: 80,
          child: _buildMarker(Icons.delivery_dining, 'Repartidor', const Color(0xFF2196F3)),
        ),
      );
    } else if (puntoDelivery != null) {
      marcadores.add(
        Marker(
          point: puntoDelivery!,
          width: 80,
          height: 80,
          child: _buildMarker(Icons.delivery_dining, 'Repartidor', const Color(0xFF2196F3)),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.pedido != null 
            ? 'Seguimiento Pedido #${widget.pedido!.id.substring(widget.pedido!.id.length - 6)}'
            : 'Seguimiento de Entrega'
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 10.0,
              color: Colors.black26,
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers, color: Colors.white),
            onSelected: _cambiarTileLayer,
            itemBuilder: (BuildContext context) {
              return _tileProviders.map((provider) {
                return PopupMenuItem<String>(
                  value: provider['name']!,
                  child: Row(
                    children: [
                      Icon(
                        _selectedTileLayer == provider['name'] 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                        color: const Color(0xFF667eea),
                      ),
                      const SizedBox(width: 8),
                      Text(provider['name']!),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: ubicacionActual ?? puntoDelivery ?? const LatLng(-17.7900, -63.1700),
              zoom: 14,
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              _buildTileLayer(),
              MarkerLayer(markers: marcadores),
            ],
          ),

          // Overlay de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Obteniendo ubicación...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Panel de controles
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
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Información del pedido si está disponible
                  if (widget.pedido != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.schedule, 
                                color: Colors.white, 
                                size: 20
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Estado: ${widget.pedido!.estado}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.pedido!.direccion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  if (widget.pedido != null) const SizedBox(height: 16),
                  
                  // Botones de control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildControlButton(
                        icon: Icons.delivery_dining,
                        label: 'Repartidor',
                        color: const Color(0xFF2196F3),
                        onPressed: _centrarEnDriver,
                      ),
                      _buildControlButton(
                        icon: Icons.location_on,
                        label: 'Cliente',
                        color: const Color(0xFFF44336),
                        onPressed: _centrarEnCliente,
                      ),
                      _buildControlButton(
                        icon: Icons.map,
                        label: 'Vista General',
                        color: const Color(0xFF667eea),
                        onPressed: _mostrarAmbos,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Leyenda de marcadores
          Positioned(
            top: 100,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    icon: Icons.delivery_dining,
                    label: 'Repartidor',
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(
                    icon: Icons.location_on,
                    label: 'Cliente',
                    color: const Color(0xFFF44336),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mapa: ${_selectedTileLayer}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}