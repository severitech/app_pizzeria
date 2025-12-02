import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'api_servicios.dart';

class ServicioSimulacion {
  static final ServicioSimulacion _instancia = ServicioSimulacion._internal();
  factory ServicioSimulacion() => _instancia;
  ServicioSimulacion._internal();

  Timer? _timerSimulacion;
  bool _simulacionActiva = false;

  bool get simulacionActiva => _simulacionActiva;

  /// Detiene cualquier simulación en curso
  void detenerSimulacion() {
    _timerSimulacion?.cancel();
    _timerSimulacion = null;
    _simulacionActiva = false;
    print('🛑 Simulación detenida');
  }

  /// Simula el viaje del conductor desde su ubicación actual hasta el destino
  /// siguiendo una ruta lineal interpolada
  Future<void> simularViaje({
    required String conductorId,
    required LatLng inicio,
    required LatLng destino,
    required Function(LatLng) onUbicacionActualizada,
    required Function() onLlegada,
    double velocidadKmH = 30.0, // Velocidad del conductor en km/h
    int intervaloMs = 2000, // Actualización cada 2 segundos
  }) async {
    // Detener simulación previa si existe
    detenerSimulacion();

    _simulacionActiva = true;
    print('🚗 Iniciando simulación de viaje');
    print('   Desde: ${inicio.latitude}, ${inicio.longitude}');
    print('   Hasta: ${destino.latitude}, ${destino.longitude}');

    final distancia = const Distance().as(LengthUnit.Meter, inicio, destino);
    print('   Distancia total: ${distancia.toStringAsFixed(0)}m');

    // Calcular cuántos metros avanza por intervalo
    final metrosPorHora = velocidadKmH * 1000;
    final metrosPorSegundo = metrosPorHora / 3600;
    final metrosPorIntervalo = metrosPorSegundo * (intervaloMs / 1000);

    print('   Velocidad: $velocidadKmH km/h');
    print('   Metros por intervalo: ${metrosPorIntervalo.toStringAsFixed(1)}m');

    // Número total de pasos
    final pasosTotales = (distancia / metrosPorIntervalo).ceil();
    print('   Pasos totales: $pasosTotales');

    int pasoActual = 0;

    _timerSimulacion = Timer.periodic(
      Duration(milliseconds: intervaloMs),
      (timer) async {
        if (!_simulacionActiva) {
          timer.cancel();
          return;
        }

        pasoActual++;

        if (pasoActual >= pasosTotales) {
          // Llegó al destino
          print('🎯 Llegada al destino');
          final apiServicios = ApiServicios();
          await apiServicios.actualizarUbicacionConductor(
            destino.latitude,
            destino.longitude,
          );
          onUbicacionActualizada(destino);
          timer.cancel();
          _simulacionActiva = false;
          onLlegada();
          return;
        }

        // Interpolar posición actual
        final progreso = pasoActual / pasosTotales;
        final latActual = inicio.latitude +
            (destino.latitude - inicio.latitude) * progreso;
        final lngActual = inicio.longitude +
            (destino.longitude - inicio.longitude) * progreso;

        final ubicacionActual = LatLng(latActual, lngActual);

        // Actualizar en el backend
        final apiServicios = ApiServicios();
        await apiServicios.actualizarUbicacionConductor(
          ubicacionActual.latitude,
          ubicacionActual.longitude,
        );

        // Notificar cambio de ubicación
        onUbicacionActualizada(ubicacionActual);

        final distanciaRestante = const Distance()
            .as(LengthUnit.Meter, ubicacionActual, destino);
        print(
          '📍 Paso $pasoActual/$pasosTotales - Distancia restante: ${distanciaRestante.toStringAsFixed(0)}m',
        );
      },
    );
  }

  /// Simula el ciclo completo del pedido:
  /// 1. Conductor → Restaurante
  /// 2. Espera en restaurante (preparación)
  /// 3. Restaurante → Cliente
  Future<void> simularCicloPedido({
    required String pedidoId,
    required String conductorId,
    required LatLng ubicacionConductor,
    required LatLng ubicacionRestaurante,
    required LatLng ubicacionCliente,
    required Function(String) onCambioEstado,
    required Function(LatLng) onUbicacionActualizada,
    required Function() onPedidoCompletado,
    double velocidadKmH = 30.0,
  }) async {
    print('🚀 Iniciando ciclo completo del pedido $pedidoId');

    try {
      // FASE 1: Conductor va al restaurante
      print('📍 FASE 1: Conductor → Restaurante');
      onCambioEstado('Repartidor en camino al restaurante');

      await simularViaje(
        conductorId: conductorId,
        inicio: ubicacionConductor,
        destino: ubicacionRestaurante,
        onUbicacionActualizada: onUbicacionActualizada,
        velocidadKmH: velocidadKmH,
        onLlegada: () {},
      );

      // Esperar a que termine la simulación anterior
      while (_simulacionActiva) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // FASE 2: Conductor llega al restaurante (espera)
      print('🏪 FASE 2: En restaurante, recogiendo pedido...');
      onCambioEstado('En camino');
      
      // Simular tiempo de recogida (3 segundos acelerados)
      await Future.delayed(const Duration(seconds: 3));

      // FASE 3: Conductor va al cliente
      print('📍 FASE 3: Restaurante → Cliente');
      onCambioEstado('En camino al cliente');

      await simularViaje(
        conductorId: conductorId,
        inicio: ubicacionRestaurante,
        destino: ubicacionCliente,
        onUbicacionActualizada: onUbicacionActualizada,
        velocidadKmH: velocidadKmH,
        onLlegada: () {},
      );

      // Esperar a que termine
      while (_simulacionActiva) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // FASE 4: Entrega completada
      print('✅ FASE 4: Pedido entregado');
      onCambioEstado('Entregado');
      onPedidoCompletado();
    } catch (e) {
      print('❌ Error en simulación del ciclo: $e');
      detenerSimulacion();
    }
  }
}
