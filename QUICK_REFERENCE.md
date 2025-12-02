# ⚡ Referencia Rápida - Comandos y Acciones

## 🎯 Iniciar (Elige UNO)

### Opción 1: Doble Click (⭐ MÁS FÁCIL)
```
1. Abre carpeta: D:\Universidad\Prácticos\Séptimo Semestre\IHC\Proyecto III 2.0\app_pizzeria
2. Busca: run_dual_drivers.ps1
3. Doble click
4. ¡Listo! (espera 30 segundos)
```

### Opción 2: PowerShell
```powershell
cd "d:\Universidad\Prácticos\Séptimo Semestre\IHC\Proyecto III 2.0\app_pizzeria"
.\run_dual_drivers.ps1
```

### Opción 3: Conductores Individuales
```powershell
# Terminal 1
flutter run --debug -d windows --dart-define=DRIVER_ID=D1

# Terminal 2 (otra PowerShell)
flutter run --debug -d windows --dart-define=DRIVER_ID=D2
```

### Opción 4: Selector Manual
```powershell
flutter run --debug -d windows
# La app pregunta qué conductor
```

---

## 🔧 Durante Ejecución

| Tecla | Efecto | Alcance |
|-------|--------|---------|
| `r` | Hot Reload | Solo ventana actual |
| `q` | Detener | Solo ventana actual |
| `R` | Reiniciar | Solo ventana actual |
| Ctrl+C | Fuerza cierre | Solo ventana actual |

---

## 🎮 FakeGPS Rápido

```
1. En pantalla de mapa
2. Toca botón naranja 🎮 (abajo derecha)
3. Ingresa:
   - Latitud: -17.7836162 (restaurante)
   - Longitud: -63.1814985
4. Presiona "Aplicar"
5. ¡Tu ubicación cambió! 📍
```

### Coordenadas de Ejemplo
```
Restaurante: -17.7836162, -63.1814985
Cliente:     -17.7865, -63.1785
Punto Medio: -17.7850, -63.1800
```

---

## 🔄 Hacer Cambios de Código

```
1. Edita archivo (ej: lib/pantallas/pantalla_pedidos.dart)
2. En Ventana D1: Presiona r
3. Cambios aparecen en D1
4. En Ventana D2: Presiona r
5. Cambios aparecen en D2
6. Cada ventana se actualiza POR SEPARADO
```

---

## 📱 Cambiar Conductor en Vivo

```dart
// En cualquier archivo Dart
ApiServicios().setDriverId('D2');  // Cambiar a D2
```

Luego presiona `r` para recargar.

---

## 🐛 Verificar Estado

### Ver qué conductor está activo
```powershell
# En la consola deberías ver
🚗 Instancia iniciada con Conductor ID: D1
✅ Conductor D1 cargado automáticamente
```

### Verificar conexión a API
```dart
// En main.dart
print('📡 Driver: $_driverId');
```

### Ver pedidos que obtiene
```dart
// Revisará en consola
print('🔄 Obteniendo mis pedidos: $_baseUrl/driver/orders/$_driverId');
```

---

## 📋 Archivos Importantes

| Archivo | Propósito |
|---------|-----------|
| `run_dual_drivers.ps1` | Script para iniciar dual |
| `lib/main.dart` | Inicialización con DRIVER_ID |
| `lib/servicios/api_servicios.dart` | API con ID de conductor |
| `lib/pantallas/pantalla_mapa.dart` | Mapa con FakeGPS |
| `QUICK_START.md` | Inicio en 30 segundos |
| `DUAL_DRIVERS_GUIDE.md` | Guía completa |

---

## 🔍 Buscar Variables

```dart
// Dónde se usa DRIVER_ID
const String _driverId = String.fromEnvironment('DRIVER_ID', defaultValue: '');

// Dónde se establece
ApiServicios().setDriverId(_driverId);

// Dónde se usa en API
'$_baseUrl/driver/orders/$_driverId'
```

---

## 🚨 Problemas Comunes (SOS)

| Problema | Solución |
|----------|----------|
| "Ambas dicen D1" | Cierra todo, ejecuta script nuevamente |
| "No se conecta" | Backend debe estar en localhost:61689 |
| "FakeGPS no funciona" | Asegúrate estar en pantalla de mapa |
| "Cambios no se ven" | Presiona `r` en cada ventana |
| "Flutter no funciona" | `flutter --version` para verificar instalación |
| "Permisos denegados" | Ejecuta PowerShell como administrador |

---

## 📊 Verificación Rápida

```
✅ Script ejecutable?
   flutter --version

✅ Backend corriendo?
   curl http://localhost:61689/health

✅ Script sintaxis?
   Intenta: .\run_dual_drivers.ps1

✅ Dart OK?
   dart analyze lib/main.dart

✅ Todo listo?
   ¡Doble click en run_dual_drivers.ps1!
```

---

## 🎯 Casos de Prueba Rápidos (5 min)

### Test 1: Conductores Diferentes
```
[ ] D1 ve Pedido A
[ ] D2 ve Pedido B
[ ] Son diferentes
```

### Test 2: FakeGPS Independiente
```
[ ] D1 FakeGPS → Restaurante
[ ] D2 FakeGPS → Cliente
[ ] Ubicaciones diferentes
```

### Test 3: Hot Reload
```
[ ] Cambias color
[ ] Presionas r en D1 → Cambio visible
[ ] Presionas r en D2 → Cambio visible
[ ] Independientes
```

---

## 📞 Links Útiles

```
Documentación: INDEX.md
Inicio Rápido: QUICK_START.md
Guía Completa: DUAL_DRIVERS_GUIDE.md
Escenarios: TEST_SCENARIOS.md
Técnico: IMPLEMENTATION_SUMMARY.md
```

---

## 🎓 Cheat Sheet Completo

```
EMPEZAR
└─ run_dual_drivers.ps1 (doble click)
   ├─ Ventana 1: D1 ✅
   ├─ Ventana 2: D2 ✅
   └─ API filtra: /driver/orders/{ID}

DESARROLLAR
├─ Edita código
├─ Presiona r en cada ventana
└─ Cambios aplican independientemente

PROBAR
├─ FakeGPS en cada mapa 🎮
├─ Diferentes ubicaciones
└─ Verifica sincronización backend

DEPURAR
├─ print() en consola
├─ dart analyze lib/main.dart
└─ flutter pub get
```

---

## ✨ Lo Más Importante

```
┌─────────────────────────────────────┐
│   SOLO NECESITAS 3 CLICS:           │
│                                     │
│   1. Abre carpeta (File Explorer)   │
│   2. Busca: run_dual_drivers.ps1    │
│   3. DOBLE CLICK                    │
│                                     │
│   ¡AUTOMÁTICO! ✨                   │
└─────────────────────────────────────┘
```

---

## 🚀 Comandos útiles (Copiar-Pegar)

```powershell
# Ir a carpeta del proyecto
cd "d:\Universidad\Prácticos\Séptimo Semestre\IHC\Proyecto III 2.0\app_pizzeria"

# Ver si Flutter está OK
flutter --version

# Ver si hay cambios
git status

# Ejecutar dual
.\run_dual_drivers.ps1

# Ejecutar solo D1
flutter run --debug -d windows --dart-define=DRIVER_ID=D1

# Ejecutar solo D2
flutter run --debug -d windows --dart-define=DRIVER_ID=D2

# Limpiar build
flutter clean

# Obtener dependencias
flutter pub get

# Analizar código
dart analyze
```

---

## 📖 Lectura Rápida por Nivel

| Nivel | Tiempo | Archivo |
|-------|--------|---------|
| Principiante | 30 seg | QUICK_START.md |
| Intermedio | 5 min | SETUP_SUMMARY.md |
| Avanzado | 20 min | DUAL_DRIVERS_GUIDE.md |
| Expert | 30 min | IMPLEMENTATION_SUMMARY.md |

---

**¡Listo para empezar!** 🚀

*Última actualización: Diciembre 2024*
