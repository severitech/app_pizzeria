# 🚗🚗 Guía de Pruebas - Dos Conductores Simultáneos

## Escenarios de Prueba

### Escenario 1: Asignación de Pedidos
**Meta:** Verificar que los pedidos se asignen correctamente a cada conductor

**Pasos:**
1. Inicia ambas instancias con el script: `.\run_dual_drivers.ps1`
2. **Ventana D1:** Ve a "Mi Pedidos" y espera a que se carguen
3. **Ventana D2:** Ve a "Mi Pedidos" y espera a que se carguen
4. En tu backend, asigna un pedido a D1 y otro a D2
5. **Esperado:** Cada ventana muestra solo sus pedidos

---

### Escenario 2: Seguimiento en Tiempo Real
**Meta:** Verificar que ambos conductores ven el mismo pedido con perspectivas diferentes

**Pasos:**
1. Desde backend: Crea un pedido y asígnalo a D1
2. **Ventana D1:** Verá el pedido como "Mi Pedido"
3. **Ventana D2:** Verá el pedido en estado "Disponible" o "Asignado a otro"
4. **D1 acepta:** Presiona botón de aceptación
5. **Esperado:** D1 pasa a "En camino", D2 sigue viendo el estado actual del backend

---

### Escenario 3: Ubicación Simulada (FakeGPS)
**Meta:** Probar que ambos conductores pueden usar FakeGPS independientemente

**Pasos:**
1. En **Ventana D1:** Toca botón FakeGPS (🎮) naranja en el mapa
2. Ingresa coordenadas: `-17.7836162, -63.1814985`
3. Presiona "Aplicar" → D1 se mueve a ese punto
4. En **Ventana D2:** Toca botón FakeGPS
5. Ingresa coordenadas diferentes: `-17.7850, -63.1800`
6. Presiona "Aplicar" → D2 se mueve a su punto
7. **Esperado:** Ambos están en puntos diferentes en sus respectivos mapas

---

### Escenario 4: Hot Reload Independiente
**Meta:** Verificar que los cambios se aplican a cada instancia por separado

**Pasos:**
1. **Ambas ventanas están ejecutándose**
2. En tu editor, cambia un color o texto en `lib/pantallas/pantalla_pedidos.dart`
3. En **Ventana D1:** Presiona `r` para hot reload
4. Verifica que los cambios aparecen en D1
5. En **Ventana D2:** NO hagas nada
6. **Esperado:** D2 sigue con el código anterior
7. En **Ventana D2:** Presiona `r`
8. **Esperado:** Ahora D2 también tiene los cambios

---

### Escenario 5: Entrega Completa
**Meta:** Probar flujo completo de dos conductores entregando diferentes pedidos

**Pasos:**

**Setup:**
```
Backend crea 2 pedidos:
- Pedido A → Asignado a D1
- Pedido B → Asignado a D2
```

**D1 (Ventana 1):**
1. Ve "Mi Pedidos"
2. Ve Pedido A con estado "Repartidor Asignado"
3. Toca "MARCAR EN CAMINO"
4. Toca botón FakeGPS y ve a punto medio (restaurante → cliente)
5. Verifica distancia disminuye en info card
6. Toca "TU PEDIDO LLEGÓ AL LUGAR"
7. Toca "MARCAR COMO ENTREGADO"

**D2 (Ventana 2):** Repite con Pedido B simultáneamente

**Esperado:** Ambos completan entregas en paralelo sin interferencias

---

### Escenario 6: Estado Compartido
**Meta:** Verificar que cambios de estado en un conductor se reflejan (si es necesario) en el otro

**Pasos:**
1. **D1:** Acepta un pedido (estado = "En camino")
2. **D2:** Visualiza en "Todos los Pedidos" si tiene ese endpoint
3. Verifica que D2 ve el cambio de estado de D1
4. **D1:** Entrega el pedido (estado = "Entregado")
5. **D2:** Verifica que el pedido desaparece o cambia a "Entregado"

---

## 🎯 Checklist de Validación

- [ ] Script `run_dual_drivers.ps1` abre dos ventanas automáticamente
- [ ] Ventana 1 muestra "Conductor 1" o "D1"
- [ ] Ventana 2 muestra "Conductor 2" o "D2"
- [ ] Cada ventana conecta al mismo backend (`localhost:61689`)
- [ ] D1 obtiene sus pedidos (API: `/driver/orders/D1`)
- [ ] D2 obtiene sus pedidos (API: `/driver/orders/D2`)
- [ ] FakeGPS funciona independientemente en cada ventana
- [ ] Hot reload (`r`) afecta solo a la ventana donde se ejecuta
- [ ] Los cambios en la otra ventana se mantienen sin aplicarse
- [ ] Ambos conductores pueden entrar en mapas simultáneamente
- [ ] Ambos pueden usar botones de estado sin conflictos
- [ ] Sin mensajes de error sobre "Driver ID" o "Singleton"

---

## 🔧 Debugging

### Ver qué conductor está ejecutándose
En la consola de cada ventana deberías ver:
```
🚗 Instancia iniciada con Conductor ID: D1
```
o
```
🚗 Instancia iniciada con Conductor ID: D2
```

### Verificar IDs de API
Agrega esto temporalmente en `api_servicios.dart`:
```dart
print('📡 Usando API con Driver: $_driverId');
```

Luego haz hot reload y verifica en la consola.

### Logs útiles
```
✅ Conductor D1 cargado automáticamente
✅ Conductor D2 cargado automáticamente
🔄 Obteniendo mis pedidos: https://...driver/orders/D1
🔄 Obteniendo mis pedidos: https://...driver/orders/D2
```

---

## 📝 Notas de Desarrollo

- Ambas instancias **comparten el mismo código fuente**
- Cambios en archivos se aplican individualmente en cada ventana cuando presionas `r`
- Los datos se obtienen de diferentes endpoints (`/driver/orders/D1` vs `/D2`)
- La UI se renderiza independientemente en cada ventana

---

## ❌ Problemas Comunes

| Problema | Causa | Solución |
|----------|-------|----------|
| Ambas ventanas dicen "D1" | No se pasó `--dart-define` | Usa script o comando manual con `DRIVER_ID=D1` y `DRIVER_ID=D2` |
| Una ventana no se abre | Error en ejecución | Ejecuta manualmente en dos terminales |
| Los pedidos son iguales en ambas | Backend no filtra por conductor | Verifica que API filtra correctamente (`/driver/orders/{id}`) |
| Hot reload da error | Sintaxis en cambios | Verifica `dart analyze` antes de guardar |
| Conexión rechazada | Backend offline | Verifica que `localhost:61689` está corriendo |

