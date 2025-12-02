import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mi_aplicacion_pizzeria/modelos/pedido.dart';
import 'api_servicios.dart';

class ServicioPedidos with ChangeNotifier {
  final List<Pedido> _pedidos = [];
  final List<Pedido> _misPedidos = [];
  final ApiServicios _apiServicios = ApiServicios();
  Timer? _timerSincronizacion;
  Timer? _timerUbicacion;
  bool _estaCargando = false;
  String? _ultimoError;

  List<Pedido> get pedidos => _pedidos;
  List<Pedido> get misPedidos => _misPedidos;
  bool get estaCargando => _estaCargando;
  String? get ultimoError => _ultimoError;

  ServicioPedidos() {
    _iniciarSincronizacionAutomatica();
    _iniciarActualizacionUbicacion();
  }

  void _iniciarSincronizacionAutomatica() {
    // OPTIMIZACIÓN: Reducir frecuencia de polling de 15s a 60s (1 minuto)
    // Esto reduce las lecturas de Firebase de 240/hora a 60/hora
    _timerSincronizacion = Timer.periodic(const Duration(seconds: 60), (timer) {
      // Solo sincronizar misPedidos (los que ya aceptó el conductor)
      // No necesitamos obtenerPedidos() constantemente
      obtenerMisPedidos();
    });
  }

  void _iniciarActualizacionUbicacion() {
    // OPTIMIZACIÓN: Reducir frecuencia de 10s a 30s
    // Esto reduce las actualizaciones de ubicación de 360/hora a 120/hora
    _timerUbicacion = Timer.periodic(const Duration(seconds: 30), (timer) {
      _actualizarUbicacionSiEsNecesario();
    });
  }

  void _actualizarUbicacionSiEsNecesario() {
    // Solo actualizar ubicación si hay pedidos activos
    if (_misPedidos.where((p) => p.estado != 'Entregado' && p.estado != 'Cancelado').isEmpty) {
      print('⏸️ No hay pedidos activos - Saltando actualización de ubicación');
      return;
    }
    // Enviar ubicación siempre para que el backend sepa quién está más cerca
    // Usar coordenadas simuladas o reales. Aquí simulamos movimiento o posición fija.
    // TODO: Integrar geolocator para obtener ubicación real
    _apiServicios.actualizarUbicacionConductor(-17.7833, -63.1821);
  }
  
  // Pausar sincronización automática (útil cuando la app está en background)
  void pausarSincronizacion() {
    _timerSincronizacion?.cancel();
    _timerUbicacion?.cancel();
    print('⏸️ Sincronización pausada');
  }
  
  // Reanudar sincronización automática
  void reanudarSincronizacion() {
    if (_timerSincronizacion?.isActive != true) {
      _iniciarSincronizacionAutomatica();
    }
    if (_timerUbicacion?.isActive != true) {
      _iniciarActualizacionUbicacion();
    }
    print('▶️ Sincronización reanudada');
  }

  Future<void> obtenerPedidos() async {
    if (_estaCargando) return;
    _estaCargando = true;
    _ultimoError = null;
    notifyListeners();

    try {
      final datos = await _apiServicios.obtenerPedidos();
      final List<Pedido> pedidosActualizados = [];

      for (var dato in datos) {
        try {
          final pedido = Pedido.desdeJson(dato);
          pedidosActualizados.add(pedido);
        } catch (e) {
          print('❌ Error parseando pedido: $e');
        }
      }

      pedidosActualizados.sort((a, b) => b.fecha.compareTo(a.fecha));
      _pedidos.clear();
      _pedidos.addAll(pedidosActualizados);
    } catch (error) {
      print('❌ Error obteniendo pedidos: $error');
      _ultimoError = 'Error al cargar pedidos: $error';
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  Future<void> obtenerMisPedidos() async {
    try {
      final datos = await _apiServicios.obtenerMisPedidos();
      final List<Pedido> misPedidosActualizados = [];

      for (var dato in datos) {
        try {
          final pedido = Pedido.desdeJson(dato);
          misPedidosActualizados.add(pedido);
        } catch (e) {
          print('❌ Error parseando mi pedido: $e');
        }
      }

      misPedidosActualizados.sort((a, b) => b.fecha.compareTo(a.fecha));
      
      // Solo notificar si hay cambios reales
      if (_hayaCambiosEnMisPedidos(misPedidosActualizados)) {
        _misPedidos.clear();
        _misPedidos.addAll(misPedidosActualizados);
        notifyListeners();
        print('🔄 Mis pedidos actualizados - Notificando cambios');
      }
    } catch (error) {
      print('❌ Error obteniendo mis pedidos: $error');
    }
  }
  
  bool _hayaCambiosEnMisPedidos(List<Pedido> nuevos) {
    if (_misPedidos.length != nuevos.length) return true;
    
    for (int i = 0; i < _misPedidos.length; i++) {
      if (_misPedidos[i].id != nuevos[i].id || 
          _misPedidos[i].estado != nuevos[i].estado) {
        return true;
      }
    }
    
    return false;
  }

  // MÉTODO NUEVO: Obtener pedido por ID
  Pedido? obtenerPedidoPorId(String id) {
    try {
      // Buscar primero en mis pedidos
      final pedidoEnMisPedidos = _misPedidos.firstWhere(
        (p) => p.id == id,
        orElse: () => Pedido.vacio(),
      );

      // Si no se encuentra en mis pedidos, buscar en todos los pedidos
      if (pedidoEnMisPedidos.id.isEmpty) {
        return _pedidos.firstWhere(
          (p) => p.id == id,
          orElse: () => Pedido.vacio(),
        );
      }

      return pedidoEnMisPedidos;
    } catch (e) {
      print('❌ Error obteniendo pedido por ID: $e');
      return null;
    }
  }

  // ASIGNAR CONDUCTOR - Cambia de "Pendiente" a "Repartidor Asignado"
  Future<bool> asignarConductor(String idPedido) async {
    try {
      final exito = await _apiServicios.aceptarPedidoConductor(idPedido);
      if (exito) {
        // Actualizar estado localmente
        final indice = _pedidos.indexWhere((p) => p.id == idPedido);
        if (indice != -1) {
          _pedidos[indice] = _pedidos[indice].copyWith(
            estado: 'Repartidor Asignado',
          );
          // Mover a mis pedidos
          final pedidoAceptado = _pedidos[indice];
          _misPedidos.add(pedidoAceptado);
          _pedidos.removeAt(indice);

          // Forzar actualización de ambas listas
          obtenerPedidos();
          obtenerMisPedidos();

          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      print('❌ Error al asignar conductor: $error');
      _ultimoError = 'Error al asignar conductor: $error';
      notifyListeners();
      return false;
    }
  }

  // ENVIAR PEDIDO - Cambia de "Repartidor Asignado" a "En camino"
  Future<bool> enviarPedido(String idPedido) async {
    try {
      final exito = await _apiServicios.recogerPedido(idPedido);
      if (exito) {
        // Actualizar en mis pedidos
        final indice = _misPedidos.indexWhere((p) => p.id == idPedido);
        if (indice != -1) {
          _misPedidos[indice] = _misPedidos[indice].copyWith(
            estado: 'En camino',
          );

          // Forzar actualización
          obtenerMisPedidos();

          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      print('❌ Error al enviar pedido: $error');
      _ultimoError = 'Error al enviar pedido: $error';
      notifyListeners();
      return false;
    }
  }

  // ENTREGAR PEDIDO - Cambia de "En camino" a "Entregado"
  Future<bool> entregarPedido(String idPedido) async {
    try {
      final exito = await _apiServicios.entregarPedidoConductor(idPedido);
      if (exito) {
        // Actualizar en mis pedidos
        final indice = _misPedidos.indexWhere((p) => p.id == idPedido);
        if (indice != -1) {
          _misPedidos[indice] = _misPedidos[indice].copyWith(
            estado: 'Entregado',
          );

          // Forzar actualización
          obtenerMisPedidos();

          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      print('❌ Error al entregar pedido: $error');
      _ultimoError = 'Error al entregar pedido: $error';
      notifyListeners();
      return false;
    }
  }

  // LLEGAR DESTINO - Método opcional para marcar llegada al destino
  Future<bool> llegarDestino(String idPedido) async {
    try {
      // Si tienes este endpoint en tu API, úsalo. Si no, puedes eliminarlo.
      final exito = await _apiServicios.llegarDestino(idPedido);
      if (exito) {
        final indice = _misPedidos.indexWhere((p) => p.id == idPedido);
        if (indice != -1) {
          _misPedidos[indice] = _misPedidos[indice].copyWith(
            estado: 'En destino',
          );

          // Forzar actualización
          obtenerMisPedidos();

          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      print('❌ Error al marcar como llegado a destino: $error');
      _ultimoError = 'Error al marcar como llegado a destino: $error';
      notifyListeners();
      return false;
    }
  }

  // MÉTODO PARA LIMPIAR ERRORES
  void limpiarError() {
    _ultimoError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerSincronizacion?.cancel();
    _timerUbicacion?.cancel();
    super.dispose();
  }
}
