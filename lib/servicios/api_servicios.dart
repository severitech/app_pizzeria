import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServicios {
  static const String _baseUrl =
      'https://bottelegramihc-production.up.railway.app';

  static String _driverId = 'D2'; // Ahora no es const para poder cambiarlo

  static final ApiServicios _instancia = ApiServicios._internal();
  factory ApiServicios() => _instancia;
  ApiServicios._internal();

  // Método para cambiar el ID del conductor (para pruebas)
  void setDriverId(String id) {
    _driverId = id;
    print('🆔 Driver ID cambiado a: $_driverId');
  }

  String get driverId => _driverId;

  // Obtener todos los pedidos (para la pantalla principal)
  Future<List<dynamic>> obtenerPedidos() async {
    try {
      print('🔄 Obteniendo pedidos desde: $_baseUrl/get_orders');
      final respuesta = await http.get(
        Uri.parse('$_baseUrl/get_orders'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        print(
          '📦 Datos recibidos: ${datos is List ? datos.length : 'no es lista'} elementos',
        );
        return datos is List ? datos : [];
      } else {
        print('❌ Error backend: ${respuesta.statusCode} - ${respuesta.body}');
        return [];
      }
    } catch (error) {
      print('❌ Error de conexión: $error');
      return [];
    }
  }

  // ENDPOINT ESPECÍFICO PARA CONDUCTORES: Obtener mis pedidos asignados
  Future<List<dynamic>> obtenerMisPedidos() async {
    try {
      print('🔄 Obteniendo mis pedidos: $_baseUrl/driver/orders/$_driverId');
      final respuesta = await http.get(
        Uri.parse('$_baseUrl/driver/orders/$_driverId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');

      if (respuesta.statusCode == 200) {
        final datos = json.decode(respuesta.body);
        print('📦 Mis pedidos: ${datos is List ? datos.length : 0} elementos');
        return datos is List ? datos : [];
      } else {
        print('❌ Error obteniendo mis pedidos: ${respuesta.statusCode}');
        return [];
      }
    } catch (error) {
      print('❌ Error de conexión: $error');
      return [];
    }
  }

  // ENDPOINT ESPECÍFICO PARA CONDUCTORES: Aceptar pedido
  Future<bool> aceptarPedidoConductor(String orderId) async {
    try {
      final payload = {'order_id': orderId, 'driver_id': _driverId};

      final respuesta = await http.post(
        Uri.parse('$_baseUrl/driver/accept'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (respuesta.statusCode == 200) {
        print('✅ Pedido aceptado exitosamente');
        return true;
      } else if (respuesta.statusCode == 409) {
        print('⚠️ Conflicto: El pedido ya fue aceptado por otro conductor');
        return false;
      } else {
        print('❌ Error del servidor: ${respuesta.statusCode}');
        return false;
      }
    } catch (error) {
      print('❌ Error al aceptar pedido: $error');
      return false;
    }
  }

  Future<bool> llegarDestino(String orderId) async {
    try {
      final payload = {'order_id': orderId, 'driver_id': _driverId};

      final respuesta = await http.post(
        Uri.parse('$_baseUrl/driver/arrive'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (respuesta.statusCode == 200) {
        print('✅ Pedido aceptado exitosamente');
        return true;
      } else {
        print('❌ Error del servidor: ${respuesta.statusCode}');
        return false;
      }
    } catch (error) {
      print('❌ Error al aceptar pedido: $error');
      return false;
    }
  }

  // ENDPOINT ESPECÍFICO PARA CONDUCTORES: Recoger pedido (marcar como "En camino")
  Future<bool> recogerPedido(String orderId) async {
    try {
      final payload = {'order_id': orderId};

      print('🔄 Recogiendo pedido: $_baseUrl/driver/pickup');
      print('📤 Payload: $payload');

      final respuesta = await http.post(
        Uri.parse('$_baseUrl/driver/pickup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');

      if (respuesta.statusCode == 200) {
        print('✅ Pedido recogido exitosamente');
        return true;
      } else {
        print('❌ Error del servidor: ${respuesta.statusCode}');
        return false;
      }
    } catch (error) {
      print('❌ Error al recoger pedido: $error');
      return false;
    }
  }

  // ENDPOINT ESPECÍFICO PARA CONDUCTORES: Entregar pedido
  Future<bool> entregarPedidoConductor(String orderId) async {
    try {
      final payload = {'order_id': orderId};

      print('🔄 Entregando pedido: $_baseUrl/driver/deliver');
      print('📤 Payload: $payload');

      final respuesta = await http.post(
        Uri.parse('$_baseUrl/driver/deliver'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');

      if (respuesta.statusCode == 200) {
        print('✅ Pedido entregado exitosamente');
        return true;
      } else {
        print('❌ Error del servidor: ${respuesta.statusCode}');
        return false;
      }
    } catch (error) {
      print('❌ Error al entregar pedido: $error');
      return false;
    }
  }

  // ENDPOINT ESPECÍFICO PARA CONDUCTORES: Actualizar ubicación
  Future<bool> actualizarUbicacionConductor(double lat, double lng) async {
    try {
      final payload = {
        'driver_id': _driverId,
        'latitude': lat,
        'longitude': lng,
      };

      print('📍 Actualizando ubicación: $_baseUrl/driver/location');
      print('📤 Payload: $payload');

      final respuesta = await http.post(
        Uri.parse('$_baseUrl/driver/location'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      print('📡 Respuesta del servidor: ${respuesta.statusCode}');

      if (respuesta.statusCode == 200) {
        print('✅ Ubicación actualizada exitosamente');
        return true;
      } else {
        print('❌ Error actualizando ubicación: ${respuesta.statusCode}');
        return false;
      }
    } catch (error) {
      print('❌ Error al actualizar ubicación: $error');
      return false;
    }
  }

  // Método para probar la conexión
  Future<bool> probarConexion() async {
    try {
      final respuesta = await http
          .get(
            Uri.parse('$_baseUrl/get_orders'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return respuesta.statusCode == 200;
    } catch (error) {
      print('❌ Error probando conexión: $error');
      return false;
    }
  }
}
