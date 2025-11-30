import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mi_aplicacion_pizzeria/modelos/pedido.dart';
import 'api_servicios.dart';

class ServicioPedidos with ChangeNotifier {
  final List<Pedido> _pedidos = [];
  final ApiServicios _apiServicios = ApiServicios();
  Timer? _timerSincronizacion;
  bool _estaCargando = false;

  List<Pedido> get pedidos => _pedidos;
  bool get estaCargando => _estaCargando;

  ServicioPedidos() {
    _iniciarSincronizacionAutomatica();
  }

  void _iniciarSincronizacionAutomatica() {
    // Sincronizar cada 10 segundos para detectar nuevos pedidos
    _timerSincronizacion = Timer.periodic(const Duration(seconds: 10), (timer) {
      obtenerPedidos();
    });
  }

  Future<void> obtenerPedidos() async {
    if (_estaCargando) return;
    
    _estaCargando = true;
    notifyListeners();

    try {
      final datos = await _apiServicios.obtenerPedidos();
      
      final List<Pedido> pedidosActualizados = [];
      
      for (var dato in datos) {
        try {
          final pedido = Pedido.desdeJson(dato);
          pedidosActualizados.add(pedido);
        } catch (e) {
          print('Error parseando pedido: $e');
        }
      }

      // Ordenar por fecha (más recientes primero)
      pedidosActualizados.sort((a, b) => b.fecha.compareTo(a.fecha));

      // Verificar si hay nuevos pedidos
      final hayNuevosPedidos = _verificarNuevosPedidos(pedidosActualizados);
      
      _pedidos.clear();
      _pedidos.addAll(pedidosActualizados);
      
      if (hayNuevosPedidos) {
        _mostrarNotificacionNuevoPedido();
      }

    } catch (error) {
      print('Error obteniendo pedidos: $error');
    } finally {
      _estaCargando = false;
      notifyListeners();
    }
  }

  bool _verificarNuevosPedidos(List<Pedido> nuevosPedidos) {
    if (_pedidos.isEmpty && nuevosPedidos.isNotEmpty) return true;
    
    final idsActuales = _pedidos.map((p) => p.id).toSet();
    final hayNuevo = nuevosPedidos.any((pedido) => 
        !idsActuales.contains(pedido.id) && 
        pedido.estado == 'Pendiente'
    );
    
    return hayNuevo;
  }

  void _mostrarNotificacionNuevoPedido() {
    // Esta función se implementará en la pantalla principal
    // para mostrar una notificación cuando haya nuevos pedidos
  }

  Future<void> aceptarPedido(String idPedido) async {
    try {
      await _apiServicios.actualizarEstadoPedido(idPedido, 'Confirmado');
      
      // Actualizar el estado localmente
      final indice = _pedidos.indexWhere((p) => p.id == idPedido);
      if (indice != -1) {
        _pedidos[indice] = _pedidos[indice].copyWith(estado: 'Confirmado');
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Error al aceptar pedido: $error');
    }
  }

  Future<void> actualizarEstado(String idPedido, String nuevoEstado) async {
    try {
      await _apiServicios.actualizarEstadoPedido(idPedido, nuevoEstado);
      
      // Actualizar el estado localmente
      final indice = _pedidos.indexWhere((p) => p.id == idPedido);
      if (indice != -1) {
        _pedidos[indice] = _pedidos[indice].copyWith(estado: nuevoEstado);
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Error al actualizar estado: $error');
    }
  }

  @override
  void dispose() {
    _timerSincronizacion?.cancel();
    super.dispose();
  }
}