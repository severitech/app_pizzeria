import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:mi_aplicacion_pizzeria/servicios/servicio_pedido.dart';
import 'package:provider/provider.dart';
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
  
  // Variable para almacenar el pedido actualizado
  Pedido? _pedidoActual;

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
    _pedidoActual = widget.pedido;
    _inicializarUbicaciones();
    _obtenerUbicacionActual();
    _configurarListener();
  }

  void _configurarListener() {
    // Escuchar cambios en el servicio de pedidos
    final servicioPedidos = Provider.of<ServicioPedidos>(context, listen: false);
    
    // No podemos usar addListener directamente con ChangeNotifierProvider,
    // pero podemos usar un timer para verificar cambios periódicamente
    // o mejor aún, usar el Consumer en el build
  }

  void _inicializarUbicaciones() {
    // Usar ubicación del pedido si está disponible
    if (_pedidoActual?.ubicacion != null) {
      final ubicacion = _pedidoActual!.ubicacion!;
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

  // Método para actualizar el pedido localmente
  void _actualizarPedidoLocal(Pedido nuevoPedido) {
    setState(() {
      _pedidoActual = nuevoPedido;
    });
  }

  // Método para buscar el pedido actualizado en el servicio
  void _buscarPedidoActualizado() {
    if (_pedidoActual == null) return;
    
    final servicioPedidos = Provider.of<ServicioPedidos>(context, listen: false);
    
    // Buscar en mis pedidos primero
    final pedidoEnMisPedidos = servicioPedidos.misPedidos.firstWhere(
      (p) => p.id == _pedidoActual!.id,
      orElse: () => _pedidoActual!,
    );
    
    // Si no está en mis pedidos, buscar en todos los pedidos
    final pedidoEnPedidos = servicioPedidos.pedidos.firstWhere(
      (p) => p.id == _pedidoActual!.id,
      orElse: () => pedidoEnMisPedidos,
    );
    
    if (pedidoEnPedidos.estado != _pedidoActual!.estado) {
      _actualizarPedidoLocal(pedidoEnPedidos);
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

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'En camino':
        return const Color(0xFF4CAF50); // Verde
      case 'En preparación':
        return const Color(0xFFFF9800); // Naranja
      case 'Repartidor Asignado':
        return const Color(0xFF9C27B0); // Púrpura
      case 'Pendiente':
        return const Color(0xFF2196F3); // Azul
      case 'Entregado':
        return const Color(0xFF607D8B); // Gris azulado
      case 'Cancelado':
        return const Color(0xFFF44336); // Rojo
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  Future<void> _mostrarDialogoConfirmacion(
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

  void _mostrarLoading(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
                const SizedBox(width: 20),
                Text(
                  mensaje,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotonEstado(String texto, Color color, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBotonesEstado(Pedido pedido, ServicioPedidos servicioPedidos) {
    // NO mostrar botones si el estado es "Entregado" o "Cancelado"
    if (pedido.estado == 'Entregado' || pedido.estado == 'Cancelado') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Pedido ${pedido.estado.toLowerCase()}',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    switch (pedido.estado) {
      case 'Pendiente':
        return Row(
          children: [
            _buildBotonEstado(
              'ASIGNAR CONDUCTOR',
              Colors.purple,
              () async {
                await _mostrarDialogoConfirmacion(
                  'Asignar Conductor',
                  '¿Quieres asignarte como conductor del pedido #${pedido.id.substring(pedido.id.length - 6)}?',
                  () async {
                    _mostrarLoading('Asignando conductor...');
                    final exito = await servicioPedidos.asignarConductor(pedido.id);
                    Navigator.of(context, rootNavigator: true).pop();
                    
                    if (mounted) {
                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Pedido #${pedido.id.substring(pedido.id.length - 6)} asignado'),
                            backgroundColor: Colors.purple,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        
                        // Buscar el pedido actualizado después del cambio
                        _buscarPedidoActualizado();
                        
                        // Forzar rebuild
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error al asignar pedido'),
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
          ],
        );

      case 'Repartidor Asignado':
        return Row(
          children: [
            _buildBotonEstado(
              'MARCAR EN CAMINO',
              Colors.orange,
              () async {
                await _mostrarDialogoConfirmacion(
                  'Enviar Pedido',
                  '¿Estás en camino para entregar el pedido #${pedido.id.substring(pedido.id.length - 6)}?',
                  () async {
                    _mostrarLoading('Actualizando estado...');
                    final exito = await servicioPedidos.enviarPedido(pedido.id);
                    Navigator.of(context, rootNavigator: true).pop();
                    
                    if (mounted) {
                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('🚚 Pedido #${pedido.id.substring(pedido.id.length - 6)} en camino'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        
                        // Buscar el pedido actualizado después del cambio
                        _buscarPedidoActualizado();
                        
                        // Forzar rebuild
                        setState(() {});
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
          ],
        );

      case 'En camino':
        return Row(
          children: [
            _buildBotonEstado(
              'MARCAR ENTREGADO',
              Colors.green,
              () async {
                await _mostrarDialogoConfirmacion(
                  'Entregar Pedido',
                  '¿Has entregado el pedido #${pedido.id.substring(pedido.id.length - 6)} al cliente?',
                  () async {
                    _mostrarLoading('Actualizando estado...');
                    final exito = await servicioPedidos.entregarPedido(pedido.id);
                    Navigator.of(context, rootNavigator: true).pop();
                    
                    if (mounted) {
                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Pedido #${pedido.id.substring(pedido.id.length - 6)} entregado'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        
                        // Buscar el pedido actualizado después del cambio
                        _buscarPedidoActualizado();
                        
                        // Forzar rebuild
                        setState(() {});
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
          ],
        );

      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicioPedidos = Provider.of<ServicioPedidos>(context);
    
    // Buscar el pedido actualizado cada vez que se reconstruye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarPedidoActualizado();
    });

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
        title: Text(_pedidoActual != null 
            ? 'Pedido #${_pedidoActual!.id.substring(_pedidoActual!.id.length - 6)}'
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

          // Panel superior con información del pedido
          if (_pedidoActual != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pedido #${_pedidoActual!.id.substring(_pedidoActual!.id.length - 6)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getColorPorEstado(_pedidoActual!.estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _pedidoActual!.estado,
                            style: TextStyle(
                              color: _getColorPorEstado(_pedidoActual!.estado),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pedidoActual!.direccion,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_pedidoActual!.moneda} ${_pedidoActual!.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Panel inferior con controles y botones de estado
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Botones de cambio de estado - SOLO si el pedido no está entregado
                if (_pedidoActual != null)
                  Container(
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
                    child: _buildBotonesEstado(_pedidoActual!, servicioPedidos),
                  ),
                if (_pedidoActual != null) const SizedBox(height: 16),
                // Controles del mapa (siempre visibles)
                Container(
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
                  child: Row(
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
                ),
              ],
            ),
          ),

          // Leyenda de marcadores
          Positioned(
            top: _pedidoActual != null ? 220 : 100,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(height: 6),
                  _buildLegendItem(
                    icon: Icons.location_on,
                    label: 'Cliente',
                    color: const Color(0xFFF44336),
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
          width: 50,
          height: 50,
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
            icon: Icon(icon, color: Colors.white, size: 20),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 11,
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
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 6),
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
}