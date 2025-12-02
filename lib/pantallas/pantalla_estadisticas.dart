import 'package:flutter/material.dart';
import '../modelos/pedido.dart';

class PantallaEstadisticas extends StatelessWidget {
  final List<Pedido> pedidos;

  const PantallaEstadisticas({super.key, required this.pedidos});

  @override
  Widget build(BuildContext context) {
    // Filtrar pedidos entregados con calificación
    final pedidosCalificados = pedidos
        .where((p) => p.estado == 'Entregado' && p.deliveryRating != null)
        .toList();

    if (pedidosCalificados.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_chart_outlined,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                'Sin calificaciones aún',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completa entregas para ver tus estadísticas',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Calcular estadísticas
    final calificacionesDelivery = pedidosCalificados
        .map((p) => p.deliveryRating!)
        .toList();

    final promedioDelivery = calificacionesDelivery.isEmpty
        ? 0.0
        : calificacionesDelivery.reduce((a, b) => a + b) /
              calificacionesDelivery.length;

    // Contar estrellas
    final conteo5Estrellas = calificacionesDelivery.where((r) => r == 5).length;
    final conteo4Estrellas = calificacionesDelivery.where((r) => r == 4).length;
    final conteo3Estrellas = calificacionesDelivery.where((r) => r == 3).length;
    final conteo2Estrellas = calificacionesDelivery.where((r) => r == 2).length;
    final conteo1Estrella = calificacionesDelivery.where((r) => r == 1).length;

    final totalCalificaciones = calificacionesDelivery.length;

    // Calcular estadísticas del restaurante
    final calificacionesRestaurante = pedidosCalificados
        .where((p) => p.restaurantRating != null)
        .map((p) => p.restaurantRating!)
        .toList();

    final promedioRestaurante = calificacionesRestaurante.isEmpty
        ? 0.0
        : calificacionesRestaurante.reduce((a, b) => a + b) /
              calificacionesRestaurante.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Estadísticas'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con promedio general
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'Calificación Promedio',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    promedioDelivery.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < promedioDelivery.round()
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber[300],
                        size: 32,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Basado en $totalCalificaciones ${totalCalificaciones == 1 ? "entrega" : "entregas"}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Desglose de estrellas
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribución de Calificaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBarraEstrellas(
                    5,
                    conteo5Estrellas,
                    totalCalificaciones,
                  ),
                  const SizedBox(height: 12),
                  _buildBarraEstrellas(
                    4,
                    conteo4Estrellas,
                    totalCalificaciones,
                  ),
                  const SizedBox(height: 12),
                  _buildBarraEstrellas(
                    3,
                    conteo3Estrellas,
                    totalCalificaciones,
                  ),
                  const SizedBox(height: 12),
                  _buildBarraEstrellas(
                    2,
                    conteo2Estrellas,
                    totalCalificaciones,
                  ),
                  const SizedBox(height: 12),
                  _buildBarraEstrellas(1, conteo1Estrella, totalCalificaciones),
                ],
              ),
            ),
            // Comparación Delivery vs Restaurante
            if (calificacionesRestaurante.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comparación de Calificaciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTarjetaComparacion(
                            'Tu Delivery',
                            promedioDelivery,
                            Icons.delivery_dining,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTarjetaComparacion(
                            'Restaurante',
                            promedioRestaurante,
                            Icons.restaurant,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // Comentarios recientes
            if (pedidosCalificados.any(
              (p) => p.comment != null && p.comment!.isNotEmpty,
            ))
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comentarios Recientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF424242),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...pedidosCalificados
                        .where(
                          (p) => p.comment != null && p.comment!.isNotEmpty,
                        )
                        .take(5)
                        .map((pedido) => _buildComentarioItem(pedido)),
                  ],
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraEstrellas(int estrellas, int cantidad, int total) {
    final porcentaje = total > 0 ? cantidad / total : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            '$estrellas',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF616161),
            ),
          ),
        ),
        const Icon(Icons.star, color: Colors.amber, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: porcentaje,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber[600],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 35,
          child: Text(
            '$cantidad',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaComparacion(
    String titulo,
    double promedio,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            promedio.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < promedio.round() ? Icons.star : Icons.star_border,
                color: color,
                size: 14,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildComentarioItem(Pedido pedido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < (pedido.deliveryRating ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber[700],
                  size: 16,
                );
              }),
              const Spacer(),
              Text(
                _formatearFecha(pedido.fecha),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pedido.comment ?? '',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      final meses = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];
      return '${fecha.day} ${meses[fecha.month - 1]}';
    }
  }
}
