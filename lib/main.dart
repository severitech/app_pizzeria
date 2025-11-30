import 'package:flutter/material.dart';
import 'package:mi_aplicacion_pizzeria/servicios/servicio_pedido.dart';
import 'package:provider/provider.dart';

import 'pantallas/pantalla_pedidos.dart';
import 'pantallas/pantalla_mapa.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        theme: ThemeData(
          primarySwatch: Colors.red,
          useMaterial3: false,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _indicePagina == 0 
          ?  PantallaPedidos()
          : _buildPantallaMapa(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indicePagina,
        onTap: (index) {
          setState(() {
            _indicePagina = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }

  Widget _buildPantallaMapa() {
    return Consumer<ServicioPedidos>(
      builder: (context, servicioPedidos, child) {
        // Si hay pedidos en "Mis Pedidos", usar el primero
        if (servicioPedidos.misPedidos.isNotEmpty) {
          // Pasar el ID del pedido requerido por PantallaMapa
          return PantallaMapa(pedidoId: servicioPedidos.misPedidos.first.id);
        }
        
        // Si no hay pedidos, mostrar mensaje o mapa vacío
        return _buildMapaVacio();
      },
    );
  }

  Widget _buildMapaVacio() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        backgroundColor: const Color(0xFF667eea),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay pedidos activos',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Acepta un pedido para verlo en el mapa',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}