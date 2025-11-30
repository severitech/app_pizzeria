import 'package:flutter/material.dart';
import 'package:mi_aplicacion_pizzeria/modelos/pedido.dart';
import 'package:mi_aplicacion_pizzeria/servicios/servicio_pedido.dart';
import 'package:provider/provider.dart';
import 'pantalla_mapa.dart';

class PantallaPedidos extends StatefulWidget {
  @override
  State<PantallaPedidos> createState() => _PantallaPedidosState();
}

class _PantallaPedidosState extends State<PantallaPedidos> {
  String _filtroEstado = 'Todos';
  bool _mostrarNotificacion = false;
  String _ultimoPedidoNotificado = '';
  int _indiceVista = 0; // 0: Todos los pedidos, 1: Mis pedidos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final servicio = Provider.of<ServicioPedidos>(context, listen: false);
      servicio.obtenerPedidos();
      servicio.obtenerMisPedidos();
    });
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

  Color _getColorPorPrioridad(double total) {
    if (total > 100) return const Color(0xFFF44336); // Rojo - Alta
    if (total > 50) return const Color(0xFFFF9800); // Naranja - Media
    return const Color(0xFF4CAF50); // Verde - Baja
  }

  String _getPrioridad(double total) {
    if (total > 100) return 'Alta';
    if (total > 50) return 'Media';
    return 'Baja';
  }

  IconData _getIconPorEstado(String estado) {
    switch (estado) {
      case 'En camino':
        return Icons.directions_bike;
      case 'En preparación':
        return Icons.restaurant;
      case 'Repartidor Asignado':
        return Icons.person;
      case 'Pendiente':
        return Icons.schedule;
      case 'Entregado':
        return Icons.check_circle;
      case 'Cancelado':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }

  void _verificarNuevosPedidos(List<dynamic> pedidos) {
    final pedidosDisponibles = pedidos
        .where((p) => p.estado == 'Pendiente')
        .toList();

    if (pedidosDisponibles.isNotEmpty) {
      final ultimoPedido = pedidosDisponibles.first;
      if (ultimoPedido.id != _ultimoPedidoNotificado) {
        setState(() {
          _mostrarNotificacion = true;
          _ultimoPedidoNotificado = ultimoPedido.id;
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _mostrarNotificacion = false;
            });
          }
        });
      }
    }
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

  void _mostrarLoading(BuildContext context, String mensaje) {
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
        setState(() {
          _filtroEstado = selected ? label : 'Todos';
        });
      },
    );
  }

  String _formatearProductos(List<dynamic> items) {
    if (items.isEmpty) return 'Sin productos';
    final primeros = items
        .take(2)
        .map((item) => item['name'] ?? 'Producto')
        .join(', ');
    return items.length > 2 ? '$primeros...' : primeros;
  }

  String _formatearHora(DateTime fecha) {
    final fechaLaPaz = fecha.isUtc
        ? fecha.add(const Duration(hours: -4))
        : fecha;
    return '${fechaLaPaz.hour.toString().padLeft(2, '0')}:${fechaLaPaz.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBotonesAccion(
    Pedido pedido,
    ServicioPedidos servicioPedidos,
    int indiceVista,
  ) {
    // NO mostrar botones si el estado es "Entregado" o "Cancelado"
    if (pedido.estado == 'Entregado' || pedido.estado == 'Cancelado') {
      return const SizedBox.shrink();
    }

    // Si estamos en la vista de "Mis Pedidos"
    if (indiceVista == 1) {
      switch (pedido.estado) {
        case 'Repartidor Asignado':
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
                      'Enviar Pedido',
                      '¿Estás en camino para entregar el pedido #${pedido.id.substring(pedido.id.length - 6)}?',
                      () async {
                        _mostrarLoading(context, 'Actualizando estado...');
                        final exito = await servicioPedidos.enviarPedido(
                          pedido.id,
                        );
                        Navigator.of(context, rootNavigator: true).pop();

                        if (mounted) {
                          if (exito) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🚚 Pedido #${pedido.id.substring(pedido.id.length - 6)} en camino',
                                ),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 3),
                              ),
                            );
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
              ),
            ],
          );

        case 'En camino':
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
                  label: const Text('MARCAR ENTREGADO'),
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
                        _mostrarLoading(context, 'Actualizando estado...');
                        final exito = await servicioPedidos.entregarPedido(
                          pedido.id,
                        );
                        Navigator.of(context, rootNavigator: true).pop();

                        if (mounted) {
                          if (exito) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '✅ Pedido #${pedido.id.substring(pedido.id.length - 6)} entregado',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
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
              ),
            ],
          );

        default:
          return const SizedBox.shrink();
      }
    }

    // Si estamos en la vista de "Pedidos Disponibles" - Solo mostrar para pedidos Pendientes
    if (pedido.estado == 'Pendiente') {
      return Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
              label: const Text('ASIGNAR CONDUCTOR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () async {
                await _mostrarDialogoConfirmacion(
                  context,
                  'Asignar Conductor',
                  '¿Quieres asignarte como conductor del pedido #${pedido.id.substring(pedido.id.length - 6)}?',
                  () async {
                    _mostrarLoading(context, 'Asignando conductor...');
                    final exito = await servicioPedidos.asignarConductor(
                      pedido.id,
                    );
                    Navigator.of(context, rootNavigator: true).pop();

                    if (mounted) {
                      if (exito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✅ Pedido #${pedido.id.substring(pedido.id.length - 6)} asignado',
                            ),
                            backgroundColor: Colors.purple,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        // Cambiar a la vista de "Mis Pedidos"
                        setState(() {
                          _indiceVista = 1;
                        });
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
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final servicioPedidos = Provider.of<ServicioPedidos>(context);
    final pedidos = _indiceVista == 0
        ? servicioPedidos.pedidos
        : servicioPedidos.misPedidos;

    // Verificar nuevos pedidos cuando se actualiza la lista
    if (pedidos.isNotEmpty && _indiceVista == 0) {
      _verificarNuevosPedidos(pedidos);
    }

    List<dynamic> pedidosFiltrados = _filtroEstado == 'Todos'
        ? pedidos
        : pedidos.where((pedido) => pedido.estado == _filtroEstado).toList();

    // Estadísticas
    final totalPedidos = pedidos.length;
    final pedidosEnCamino = pedidos
        .where((p) => p.estado == 'En camino')
        .length;
    final pedidosPendientes = pedidos
        .where((p) => p.estado == 'Pendiente')
        .length;
    final pedidosRepartidorAsignado = pedidos
        .where((p) => p.estado == 'Repartidor Asignado')
        .length;
    final pedidosEntregados = pedidos
        .where((p) => p.estado == 'Entregado')
        .length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_indiceVista == 0 ? 'Pedidos Disponibles' : 'Mis Pedidos'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              servicioPedidos.obtenerPedidos();
              servicioPedidos.obtenerMisPedidos();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _indiceVista = 0),
                    style: TextButton.styleFrom(
                      backgroundColor: _indiceVista == 0
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Disponibles',
                      style: TextStyle(
                        color: _indiceVista == 0
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _indiceVista = 1),
                    style: TextButton.styleFrom(
                      backgroundColor: _indiceVista == 1
                          ? Colors.white.withOpacity(0.2)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Mis Pedidos',
                      style: TextStyle(
                        color: _indiceVista == 1
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
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
            // Notificación de nuevo pedido
            if (_mostrarNotificacion && _indiceVista == 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange,
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '¡NUEVO PEDIDO DISPONIBLE!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () =>
                          setState(() => _mostrarNotificacion = false),
                    ),
                  ],
                ),
              ),

            // Header con estadísticas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 120,
                bottom: 20,
                left: 24,
                right: 24,
              ),
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
                  Text(
                    _indiceVista == 0 ? 'Pedidos Disponibles' : 'Mis Entregas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total',
                        totalPedidos.toString(),
                        Icons.list_alt,
                        const Color(0xFF667eea),
                      ),
                      if (_indiceVista == 0)
                        _buildStatCard(
                          'Pendientes',
                          pedidosPendientes.toString(),
                          Icons.schedule,
                          const Color(0xFF2196F3),
                        ),
                      if (_indiceVista == 1)
                        _buildStatCard(
                          'Asignados',
                          pedidosRepartidorAsignado.toString(),
                          Icons.person,
                          const Color(0xFF9C27B0),
                        ),
                      _buildStatCard(
                        'En Camino',
                        pedidosEnCamino.toString(),
                        Icons.directions_bike,
                        const Color(0xFF4CAF50),
                      ),
                      _buildStatCard(
                        'Entregados',
                        pedidosEntregados.toString(),
                        Icons.check_circle,
                        const Color(0xFF607D8B),
                      ),
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
                    _buildFilterChip('Todos', _filtroEstado == 'Todos'),
                    const SizedBox(width: 8),
                    if (_indiceVista == 0) ...[
                      _buildFilterChip(
                        'Pendiente',
                        _filtroEstado == 'Pendiente',
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildFilterChip(
                      'Repartidor Asignado',
                      _filtroEstado == 'Repartidor Asignado',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip('En camino', _filtroEstado == 'En camino'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Entregado', _filtroEstado == 'Entregado'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de pedidos
            Expanded(
              child: servicioPedidos.estaCargando && pedidos.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : pedidosFiltrados.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list_alt, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay pedidos disponibles',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () {
                        servicioPedidos.obtenerPedidos();
                        return servicioPedidos.obtenerMisPedidos();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: pedidosFiltrados.length,
                        itemBuilder: (context, index) {
                          final pedido = pedidosFiltrados[index];
                          final estadoColor = _getColorPorEstado(pedido.estado);
                          final prioridadColor = _getColorPorPrioridad(
                            pedido.total,
                          );
                          final prioridad = _getPrioridad(pedido.total);

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
                                      builder: (context) =>
                                          PantallaMapa(pedido: pedido),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          // Icono de estado
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  estadoColor,
                                                  estadoColor.withOpacity(0.7),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: estadoColor
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              _getIconPorEstado(pedido.estado),
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // Información del pedido
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Pedido #${pedido.id.substring(pedido.id.length - 6)}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Color(
                                                            0xFF2D3748,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: prioridadColor
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: prioridadColor
                                                              .withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        prioridad,
                                                        style: TextStyle(
                                                          color: prioridadColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),

                                                // Dirección
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Colors.grey[600],
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        pedido.direccion,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),

                                                // Productos
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.fastfood,
                                                      color: Colors.amber[700],
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        _formatearProductos(
                                                          pedido.items,
                                                        ),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),

                                                // Hora, Total y estado
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.access_time,
                                                              color: Colors
                                                                  .blue[700],
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              _formatearHora(
                                                                pedido.fecha,
                                                              ),
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[700],
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          '${pedido.moneda} ${pedido.total.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: estadoColor
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        pedido.estado,
                                                        style: TextStyle(
                                                          color: estadoColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Botones de acción
                                      _buildBotonesAccion(
                                        pedido,
                                        servicioPedidos,
                                        _indiceVista,
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          servicioPedidos.obtenerPedidos();
          servicioPedidos.obtenerMisPedidos();
        },
        icon: const Icon(Icons.refresh, size: 24),
        label: const Text(
          'Actualizar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
