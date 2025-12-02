# 🚗 Modo Dual de Conductores - Guía de Uso

## Problema Solucionado
Anteriormente, cuando ejecutabas dos instancias de la app en modo debug, ambas compartían el mismo ID de conductor (`D1`). Ahora puedes ejecutar dos instancias completamente independientes con diferentes conductores (`D1` y `D2`).

## Soluciones Disponibles

### Opción 1: Script PowerShell Automático (⭐ RECOMENDADO)

**Uso:**
```powershell
# Desde la carpeta del proyecto
.\run_dual_drivers.ps1
```

**Qué hace:**
- ✅ Abre dos ventanas PowerShell automáticamente
- ✅ Ejecuta la instancia D1 (Conductor 1) en la primera ventana
- ✅ Ejecuta la instancia D2 (Conductor 2) en la segunda ventana
- ✅ Cada una es completamente independiente
- ✅ Los cambios en modo debug se aplican a cada una por separado

**Beneficios:**
- Solo necesitas ejecutar un comando
- Las ventanas se abren automáticamente
- Cada conductor tiene su propia sesión de desarrollo

---

### Opción 2: Comandos Manuales Independientes

Si prefieres control manual, abre **dos terminales por separado**:

**Terminal 1 (Conductor 1):**
```bash
flutter run --debug -d windows --dart-define=DRIVER_ID=D1
```

**Terminal 2 (Conductor 2):**
```bash
flutter run --debug -d windows --dart-define=DRIVER_ID=D2
```

---

### Opción 3: Selector Manual en la App

Si ejecutas la app sin definir `DRIVER_ID`:
```bash
flutter run --debug -d windows
```

La app te mostrará un diálogo para seleccionar el conductor (D1 o D2).

---

## 🎮 Cómo Probar

1. **Ejecuta el script (Opción 1):**
   ```powershell
   .\run_dual_drivers.ps1
   ```

2. **Espera a que ambas ventanas se abran** (tardan unos 15-20 segundos cada una)

3. **En la primera ventana:** Verás "Conductor 1" automáticamente
4. **En la segunda ventana:** Verás "Conductor 2" automáticamente

5. **Prueba independiente:**
   - En la ventana de D1: Crea un pedido, mira su estado
   - En la ventana de D2: Acepta ese mismo pedido
   - Ambas ven el mismo pedido pero con diferente perspectiva (cliente vs repartidor)

---

## 📱 Casos de Uso

### Prueba 1: Dos Conductores Simultáneos
- Conductor 1 acepta pedidos
- Conductor 2 ve pedidos diferentes
- Ambos pueden navegar en el mapa y ver sus ubicaciones

### Prueba 2: Mismo Pedido, Múltiples Conductores
- D1 acepta un pedido
- D2 busca el mismo pedido
- Verifica que ambos ven la información correcta

### Prueba 3: Cambios en Hot Reload
- Haz una modificación en el código
- Presiona `r` para hot reload en AMBAS ventanas
- Cada una recibe los cambios de forma independiente

---

## 🔧 Cómo Funciona Internamente

1. **Variable de compilación (`dart-define`):**
   ```dart
   const String _driverId = String.fromEnvironment('DRIVER_ID', defaultValue: '');
   ```

2. **Inicialización automática en `main()`:**
   ```dart
   if (_driverId.isNotEmpty) {
     ApiServicios().setDriverId(_driverId);
   }
   ```

3. **Cada instancia obtiene su propio ID:**
   - D1: `/driver/orders/D1`
   - D2: `/driver/orders/D2`

---

## ⚠️ Notas Importantes

- **No necesitan puertos diferentes:** Ambas instancias pueden usar `localhost:61689` porque cada una es un proceso separado
- **API Backend:** Asegúrate de que tu backend en `localhost:61689` esté corriendo
- **Hot Reload:** Presiona `r` en cada ventana independientemente
- **Stop:** Presiona `q` en cada ventana para cerrar su instancia

---

## 🐛 Solución de Problemas

### "Las dos instancias siguen siendo iguales"
**Solución:** Asegúrate de que estés usando el script o los comandos con `--dart-define=DRIVER_ID=`

### "Una ventana no se abre"
**Solución:** Intenta ejecutar los comandos manualmente en dos terminales

### "Los cambios no se aplican en ambas"
**Solución:** Presiona `r` en ambas ventanas para hacer hot reload en cada una

---

## 📋 Resumen de Comandos

| Acción | Comando |
|--------|---------|
| Ambos conductores (automático) | `.\run_dual_drivers.ps1` |
| Solo D1 | `flutter run --debug -d windows --dart-define=DRIVER_ID=D1` |
| Solo D2 | `flutter run --debug -d windows --dart-define=DRIVER_ID=D2` |
| Selector manual | `flutter run --debug -d windows` |
| Hot reload (en terminal actual) | `r` |
| Detener (en terminal actual) | `q` |

