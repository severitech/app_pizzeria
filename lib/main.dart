import 'package:flutter/material.dart';
import 'package:mi_aplicacion_pizzeria/servicios/servicio_pedido.dart';
import 'package:mi_aplicacion_pizzeria/servicios/api_servicios.dart';
import 'package:provider/provider.dart';

import 'pantallas/pantalla_pedidos.dart';
import 'pantallas/pantalla_mapa.dart';

// Variables de compilación para soporte dual de conductores
const String _driverId = String.fromEnvironment('DRIVER_ID', defaultValue: '');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Si se proporciona un DRIVER_ID por compilación, establecerlo automáticamente
  if (_driverId.isNotEmpty) {
    ApiServicios().setDriverId(_driverId);
    debugPrint('🚗 Instancia iniciada con Conductor ID: $_driverId');
  }
  
  runApp(const MiPizzeriaApp());
}

class MiPizzeriaApp extends StatelessWidget {
  const MiPizzeriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ServicioPedidos(),
      child: MaterialApp(
        title: 'Pizzería Nova - Delivery',
        theme: ThemeData(primarySwatch: Colors.red, useMaterial3: false),
        home: const PantallaPrincipal(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indicePagina = 0;
  String _conductorId = '';
  String _conductorNombre = '';
  bool _dialogoMostrado = false;

  @override
  void initState() {
    super.initState();
    // Si el conductor fue definido por compilación, no mostrar selector
    if (_driverId.isNotEmpty) {
      _conductorId = _driverId;
      // Mapear ID a nombre
      if (_driverId == 'D1') {
        _conductorNombre = 'Conductor 1';
      } else if (_driverId == 'D2') {
        _conductorNombre = 'Conductor 2';
      } else {
        _conductorNombre = _driverId;
      }
      _dialogoMostrado = true;
      debugPrint('✅ Conductor $_driverId cargado automáticamente');
    } else {
      // Mostrar selector de conductor al iniciar la app (solo una vez)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_dialogoMostrado && mounted) {
          _dialogoMostrado = true;
          _mostrarSelectorConductor();
        }
      });
    }
  }

  void _mostrarSelectorConductor() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Seleccionar Conductor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Qué conductor eres?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildConductorOption(
              'D1',
              'Conductor 1',
              Icons.delivery_dining,
              const Color(0xFF667eea),
            ),
            const SizedBox(height: 12),
            _buildConductorOption(
              'D2',
              'Conductor 2',
              Icons.motorcycle,
              const Color(0xFFFF6B6B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConductorOption(
    String id,
    String nombre,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          _conductorId = id;
          _conductorNombre = nombre;
        });
        // Establecer el ID del conductor en la API
        ApiServicios().setDriverId(id);
        Navigator.pop(context);
        // Recargar pedidos
        context.read<ServicioPedidos>().obtenerPedidos();
        context.read<ServicioPedidos>().obtenerMisPedidos();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'ID: $id',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si no se ha seleccionado conductor, mostrar pantalla de carga
    if (_conductorId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              ),
              SizedBox(height: 16),
              Text(
                'Selecciona tu perfil de conductor',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBarWithDriver(),
      body: _indicePagina == 0 ? const PantallaPedidos() : _buildPantallaMapa(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indicePagina,
        onTap: (index) {
          setState(() {
            _indicePagina = index;
          });
          // Recargar datos solo cuando el usuario cambia de pestaña
          if (index == 0) {
            // Cambió a lista de pedidos - actualizar
            context.read<ServicioPedidos>().obtenerPedidos();
            context.read<ServicioPedidos>().obtenerMisPedidos();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBarWithDriver() {
    final color = _conductorId == 'D1'
        ? const Color(0xFF667eea)
        : const Color(0xFFFF6B6B);
    final icon = _conductorId == 'D1'
        ? Icons.delivery_dining
        : Icons.motorcycle;

    return AppBar(
      backgroundColor: color,
      elevation: 2,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            _conductorNombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.swap_horiz, color: Colors.white),
          tooltip: 'Cambiar conductor',
          onPressed: _mostrarSelectorConductor,
        ),
      ],
    );
  }

  Widget _buildPantallaMapa() {
    // Usar Selector en lugar de Consumer para rebuilds más selectivos
    return Selector<ServicioPedidos, String?>(
      selector: (context, servicioPedidos) {
        // Solo reconstruir cuando cambia el ID del pedido activo
        try {
          final pedidosActivos = servicioPedidos.misPedidos
              .where(
                (p) =>
                    p.estado != 'Entregado' &&
                    p.estado != 'Cancelado' &&
                    p.estado != 'Pendiente',
              )
              .toList();

          if (pedidosActivos.isNotEmpty) {
            pedidosActivos.sort((a, b) => b.fecha.compareTo(a.fecha));
            return pedidosActivos.first.id;
          }
        } catch (e) {
          return null;
        }
        return null;
      },
      shouldRebuild: (previous, next) {
        // Solo reconstruir si realmente cambió el ID del pedido
        final cambio = previous != next;
        if (cambio) {
          print(
            '🗺️ Pedido cambió de "$previous" a "$next" - Reconstruyendo mapa',
          );
        }
        return cambio;
      },
      builder: (context, pedidoId, child) {
        // Si hay un pedido activo, mostrar seguimiento
        if (pedidoId != null) {
          return PantallaMapa(
            key: ValueKey(pedidoId),
            pedidoId: pedidoId,
            mostrarAtras: false,
          );
        }

        // Si no hay pedidos activos, mostrar mapa genérico
        return const PantallaMapa(pedidoId: null, mostrarAtras: false);
      },
    );
  }
}
