# ⚡ Quick Start - Dos Conductores en 30 Segundos

## 🎯 Objetivo
Ejecutar dos instancias independientes de la app (D1 y D2) simultáneamente.

## 📋 Checklist Previo

- [ ] Backend API corriendo en `localhost:61689`
- [ ] Flutter instalado y funcionando
- [ ] Estás en la carpeta `app_pizzeria`

## 🚀 INICIO (LA FORMA MÁS FÁCIL)

### ⭐ Opción A: Solo Haz Click en `run_dual_drivers.ps1`

1. **Abre el Explorador de Archivos**
2. **Navega a la carpeta del proyecto:** `D:\Universidad\Prácticos\Séptimo Semestre\IHC\Proyecto III 2.0\app_pizzeria`
3. **Busca el archivo:** `run_dual_drivers.ps1`
4. **Haz doble click en él** ✨

**Automáticamente:**
- Se abrirán 2 ventanas PowerShell
- Una dirá: "🚗 CONDUCTOR 1: Conductor 1"
- Otra dirá: "🚗 CONDUCTOR 2: Conductor 2"
- Después de 20-30 segundos, ambas apps estarán listas

---

## Si no funciona el doble click:

**Opción B: Desde PowerShell Manual**

1. **Abre PowerShell**
2. **Ve a la carpeta del proyecto:**
   ```powershell
   cd "d:\Universidad\Prácticos\Séptimo Semestre\IHC\Proyecto III 2.0\app_pizzeria"
   ```
3. **Ejecuta:**
   ```powershell
   .\run_dual_drivers.ps1
   ```

---

## ✅ ¿Cómo sé que funciona?

Deberías ver en cada ventana algo como:
```
🚗 CONDUCTOR 1: Conductor 1
ID: D1 | Puerto: 5913
========================================

🚀 Iniciando instancia 1...
```

Después de ~30 segundos:
```
🚗 Instancia iniciada con Conductor ID: D1
✅ Conductor D1 cargado automáticamente
```

---

## 🎮 Qué hacer cuando esté listo

### En Ventana 1 (D1):
1. Verás la app de Pizzería Nova
2. Ve a "📦 Mi Pedidos"
3. Espera a que se carguen los pedidos

### En Ventana 2 (D2):
1. Verás otra instancia de la app
2. Ve a "📦 Mi Pedidos"
3. Verás pedidos DIFERENTES a D1

---

## 🗺️ Prueba el Mapa (Lo más emocionante)

1. **En Ventana D1:** Toca un pedido
2. **En Ventana D2:** Toca un pedido diferente
3. Ambos ven la **Pantalla de Mapa**
4. **En cada ventana:** Toca el botón naranja 🎮 (abajo derecha)
5. En D1 ingresa: `-17.7836162, -63.1814985`
6. En D2 ingresa: `-17.7865, -63.1785`
7. **¡Verás a ambos conductores en lugares diferentes!** 🚗🚗

---

## 📝 Comandos en las Ventanas

Una vez que está ejecutando, en cada ventana:

| Tecla | Acción |
|-------|--------|
| `r` | Recarga el código (Hot Reload) |
| `q` | Cierra la app |

---

## 🔄 Hacer Cambios de Código

**Perfecto para desarrollo:**

1. Edita un archivo (ej: cambiar un color en `pantalla_pedidos.dart`)
2. **En Ventana D1:** Presiona `r` → Ver cambios
3. **En Ventana D2:** Presiona `r` → Ver cambios
4. **Ambas se actualizan en VIVO** ✨

---

## ❌ Si algo falla

| Problema | Solución |
|----------|----------|
| "No se abre nada" | Verifica: `flutter --version` en PowerShell |
| "Error de permisos" | Haz click derecho en PowerShell → "Ejecutar como administrador" |
| "Conexión rechazada" | Backend debe estar en `localhost:61689` |
| "Ambas dicen D1" | Cierra todo y ejecuta de nuevo el script |

---

## ⏱️ Timeline Típico

```
00:00 - Haces doble click en run_dual_drivers.ps1
00:05 - Se abren 2 ventanas PowerShell
00:10 - Comienza: "flutter run --debug -d windows..."
00:20 - Primer instancia lista (D1)
00:25 - Segunda instancia lista (D2)
00:30 - ¡LISTO PARA PRUEBAS! 🎉
```

---

## 🎯 Casos de Prueba Rápidos

**Test 1: Diferentes Pedidos**
- [ ] D1 ve sus pedidos
- [ ] D2 ve SUS pedidos (diferentes)

**Test 2: FakeGPS Independiente**
- [ ] D1 abre mapa con FakeGPS
- [ ] D2 abre mapa con FakeGPS diferente
- [ ] No interfieren

**Test 3: Hot Reload**
- [ ] Cambias un color en el código
- [ ] Presionas `r` en D1 → Ve cambios
- [ ] D2 sigue con color viejo
- [ ] Presionas `r` en D2 → Ahora ve cambios

---

## 📚 Si Quieres Más Detalles

- **Guía completa:** `DUAL_DRIVERS_GUIDE.md`
- **Escenarios de prueba:** `TEST_SCENARIOS.md`
- **README:** `README.md`

---

## 💡 Lo Más Importante

> **Solo necesitas hacer 3 cosas:**
> 1. Abre la carpeta del proyecto
> 2. Haz doble click en `run_dual_drivers.ps1`
> 3. Espera 30 segundos
>
> **¡Todo lo demás ocurre automáticamente!** ✨



