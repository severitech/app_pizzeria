# 🍕 Pizzería Nova - Aplicación de Delivery

Aplicación Flutter para gestión de pedidos y entregas de pizzería con soporte para múltiples conductores simultáneamente.

## ✨ Características Principales

- 📱 Interfaz intuitiva para conductores de delivery
- 🗺️ Mapa interactivo con seguimiento de ubicación en tiempo real
- 🎮 FakeGPS para pruebas de simulación de movimiento
- 🚗🚗 Modo dual de conductores (D1 y D2) en modo debug
- 🔄 Actualizaciones en tiempo real de pedidos
- 📦 Gestión de estados de pedido (Repartidor Asignado → En Camino → Entregado)

## 🚀 Inicio Rápido

### Prerequisitos
- Flutter 3.x instalado
- Backend API corriendo en `localhost:61689`
- Windows 10/11 (para modo debug con hot reload)

### Opción 1: Modo Dual de Conductores (⭐ Recomendado para Pruebas)

```powershell
# Desde la carpeta del proyecto
.\run_dual_drivers.ps1
```

Esto abrirá automáticamente:
- Ventana 1: Conductor D1 (Conductor 1)
- Ventana 2: Conductor D2 (Conductor 2)

### Opción 2: Conductor Individual

```bash
# Conductor 1
flutter run --debug -d windows --dart-define=DRIVER_ID=D1

# Conductor 2
flutter run --debug -d windows --dart-define=DRIVER_ID=D2
```

### Opción 3: Selector Manual

```bash
flutter run --debug -d windows
# La app te pedirá elegir el conductor
```

## 📚 Documentación

- **[DUAL_DRIVERS_GUIDE.md](./DUAL_DRIVERS_GUIDE.md)** - Guía completa para ejecutar dos conductores simultáneamente
- **[TEST_SCENARIOS.md](./TEST_SCENARIOS.md)** - Escenarios de prueba y validación

## 🗂️ Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada con soporte dual de conductores
├── pantallas/
│   ├── pantalla_pedidos.dart # Lista de pedidos asignados
│   └── pantalla_mapa.dart    # Mapa con FakeGPS y seguimiento
├── modelos/
│   ├── pedido.dart           # Modelo de datos de pedido
│   ├── producto.dart         # Modelo de producto
│   └── ubicacion.dart        # Modelo de ubicación
└── servicios/
    ├── api_servicios.dart    # Conexión con backend
    └── servicio_pedido.dart  # Gestión de pedidos locales
```

## 🎮 Características de Prueba

### FakeGPS (Simulador de Ubicación)

Accede mediante el botón naranja con icono de videojuego en el mapa:
- Ingresa latitud y longitud personalizadas
- Simula movimiento del conductor sin GPS real
- Funciona independientemente en cada instancia

**Coordenadas de ejemplo:**
- Restaurante: `-17.7836162, -63.1814985`
- Cliente: `-17.7865, -63.1785`
- Punto medio: `-17.7850, -63.1800`

### Cambios en Vivo (Hot Reload)

Presiona `r` en cada ventana para aplicar cambios independientemente:
- Edita código
- Presiona `r` en cada terminal
- Cambios se aplican sin reiniciar

## 🔄 Soporte Dual de Conductores

### Cómo Funciona

```
┌─────────────────────────────────────┐
│      Aplicación Pizzería Nova       │
├─────────────────┬───────────────────┤
│   Ventana D1    │    Ventana D2     │
│ Conductor 1     │  Conductor 2      │
│ ID: D1          │  ID: D2           │
└────────┬────────┴────────┬──────────┘
         │                 │
         └─────────────────┘
              Backend API
         (localhost:61689)
         /driver/orders/D1
         /driver/orders/D2
```

### Independencia

- Cada ventana es un **proceso separado**
- Diferentes IDs de conductor (`D1` vs `D2`)
- APIs filtradas por conductor
- Hot reload en cada ventana de forma independiente
- FakeGPS independiente en cada mapa

## 🛠️ Desarrollo

### Variables de Compilación

El soporte dual usa `dart-define`:

```dart
// main.dart
const String _driverId = String.fromEnvironment('DRIVER_ID', defaultValue: '');

void main() {
  if (_driverId.isNotEmpty) {
    ApiServicios().setDriverId(_driverId);
  }
  runApp(const MiPizzeriaApp());
}
```

### Cambiar Conductor en Tiempo de Ejecución

```dart
// En cualquier parte del código
ApiServicios().setDriverId('D2');
```

## 📋 Casos de Uso

| Caso | Comando |
|------|---------|
| Pruebas duales automáticas | `.\run_dual_drivers.ps1` |
| Desarrollo individual D1 | `flutter run --dart-define=DRIVER_ID=D1` |
| Desarrollo individual D2 | `flutter run --dart-define=DRIVER_ID=D2` |
| Selector manual | `flutter run` |

## 📱 Pantallas Principales

1. **Pantalla de Pedidos:** Lista de entregas asignadas
2. **Pantalla de Mapa:** Seguimiento en tiempo real con FakeGPS
3. **Selector de Conductor:** Elige entre D1 o D2

## 🐛 Solución de Problemas

### "Las dos instancias tienen el mismo conductor"
→ Usa el script `run_dual_drivers.ps1` o especifica `--dart-define=DRIVER_ID=`

### "El FakeGPS no funciona"
→ Asegúrate de estar en la pantalla de mapa y presiona el botón naranja

### "Los pedidos no se actualizan"
→ Verifica que el backend en `localhost:61689` está corriendo

## 📞 Contacto

Proyecto IHC - Séptimo Semestre

