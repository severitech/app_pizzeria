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

  final List<Widget> _paginas = [
    PantallaPedidos(), // Quitar const
    PantallaMapa(),    // Quitar const
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paginas[_indicePagina],
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
}