import 'package:flutter/material.dart';
import '../servicios/servicio_pedidos.dart';
import '../modelos/pedido.dart';
import 'pantalla_mapa.dart';

class PantallaPedidos extends StatefulWidget {
  @override
  State<PantallaPedidos> createState() => _PantallaPedidosState();
}

class _PantallaPedidosState extends State<PantallaPedidos> {
  final List<Map<String, dynamic>> pedidosFicticios = [
    {
      'cliente': 'Juan Pérez',
      'direccion': 'Av. Ejemplo 123',
      'estado': 'En camino',
      'hora': '18:30',
      'productos': 'Pizza, Refresco',
      'prioridad': 'Alta',
    },
    {
      'cliente': 'Ana Gómez',
      'direccion': 'Calle Falsa 456',
      'estado': 'Preparando',
      'hora': '18:45',
      'productos': 'Hamburguesa, Papas',
      'prioridad': 'Media',
    },
    {
      'cliente': 'Carlos López',
      'direccion': 'Plaza Central 789',
      'estado': 'Entregado',
      'hora': '18:15',
      'productos': 'Pasta, Ensalada',
      'prioridad': 'Baja',
    },
  ];

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'En camino':
        return const Color(0xFF4CAF50); // Verde
      case 'Preparando':
        return const Color(0xFFFF9800); // Naranja
      case 'Entregado':
        return const Color(0xFF2196F3); // Azul
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  Color _getColorPorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'Alta':
        return const Color(0xFFF44336); // Rojo
      case 'Media':
        return const Color(0xFFFF9800); // Naranja
      case 'Baja':
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF9E9E9E); // Gris
    }
  }

  IconData _getIconPorEstado(String estado) {
    switch (estado) {
      case 'En camino':
        return Icons.directions_bike;
      case 'Preparando':
        return Icons.restaurant;
      case 'Entregado':
        return Icons.check_circle;
      default:
        return Icons.schedule;
    }
  }

  String _getEstadoCount(String estado) {
    return pedidosFicticios.where((pedido) => pedido['estado'] == estado).length.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf5f7fa), Color(0xFFc3cfe2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header con estadísticas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 100, bottom: 20, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del Día',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total', pedidosFicticios.length.toString(), Icons.list_alt, const Color(0xFF667eea)),
                      _buildStatCard('En Camino', _getEstadoCount('En camino'), Icons.directions_bike, const Color(0xFF4CAF50)),
                      _buildStatCard('Preparando', _getEstadoCount('Preparando'), Icons.restaurant, const Color(0xFFFF9800)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Filtros de estado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos', true),
                    const SizedBox(width: 8),
                    _buildFilterChip('En camino', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Preparando', false),
                    const SizedBox(width: 8),
                    _buildFilterChip('Entregado', false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Lista de pedidos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: pedidosFicticios.length,
                itemBuilder: (context, index) {
                  final pedido = pedidosFicticios[index];
                  final estadoColor = _getColorPorEstado(pedido['estado']);
                  final prioridadColor = _getColorPorPrioridad(pedido['prioridad']);
                  
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.black26,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PantallaMapa(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              // Icono de estado
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [estadoColor, estadoColor.withOpacity(0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: estadoColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getIconPorEstado(pedido['estado']),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 20),
                              
                              // Información del pedido
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pedido['cliente'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2D3748),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: prioridadColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: prioridadColor.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            pedido['prioridad'],
                                            style: TextStyle(
                                              color: prioridadColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Dirección
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            pedido['direccion'],
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Productos
                                    Row(
                                      children: [
                                        Icon(Icons.fastfood, color: Colors.amber[700], size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            pedido['productos'],
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Hora y estado
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, color: Colors.blue[700], size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              pedido['hora'],
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: estadoColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            pedido['estado'],
                                            style: TextStyle(
                                              color: estadoColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFFA0AEC0),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Funcionalidad de agregar pedido próximamente'),
              backgroundColor: const Color(0xFF667eea),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        },
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'Nuevo Pedido',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF667eea),
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF667eea),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      onSelected: (bool selected) {
        // Lógica de filtrado aquí
      },
    );
  }
}