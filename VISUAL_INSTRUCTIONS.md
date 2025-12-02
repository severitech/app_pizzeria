# 👉 INSTRUCCIONES VISUALES - Paso a Paso

## 🎯 MÉTODO 1: Doble Click (MÁS FÁCIL)

```
┌─────────────────────────────────────────────────────┐
│  PASO 1: Abre el Explorador de Archivos            │
│  (Windows Explorer / File Explorer)                 │
└─────────────────────────────────────────────────────┘
            ↓
        [BUSCA ESTA RUTA]
D:\Universidad\Prácticos\Séptimo Semestre\IHC\Proyecto III 2.0\app_pizzeria

            ↓
┌─────────────────────────────────────────────────────┐
│  PASO 2: Busca este archivo                        │
│                                                     │
│  📄 run_dual_drivers.ps1                           │
│                                                     │
│  (Es un archivo PowerShell, puede que veas:)       │
│  - Un icono de script/código                       │
│  - Tamaño: ~3-4 KB                                 │
│                                                     │
└─────────────────────────────────────────────────────┘
            ↓
┌─────────────────────────────────────────────────────┐
│  PASO 3: DOBLE CLICK                               │
│                                                     │
│  ┌─────────────────────────────────────────────┐  │
│  │ 📄 run_dual_drivers.ps1                     │  │
│  │                                             │  │
│  │  [DOBLE CLICK AQUÍ] ←────────────────────┐ │  │
│  │                                           │ │  │
│  └─────────────────────────────────────────┼─┘  │
│                                             │    │
└─────────────────────────────────────────────────────┘
            ↓
        ✨ AUTOMÁTICO ✨
            ↓
┌─────────────────────────────────────────────────────┐
│  SE ABRIRÁN 2 VENTANAS POWERSHELL AUTOMÁTICAMENTE  │
│                                                     │
│  Ventana 1:  "🚗 CONDUCTOR 1: Conductor 1"        │
│              "ID: D1 | Puerto: 5913"               │
│                                                     │
│  Ventana 2:  "🚗 CONDUCTOR 2: Conductor 2"        │
│              "ID: D2 | Puerto: 5914"               │
│                                                     │
└─────────────────────────────────────────────────────┘
            ↓
      ⏱️ ESPERA 30 SEGUNDOS
            ↓
        ✅ ¡LISTO!
            ↓
    Ambas apps están ejecutándose
    Conductores independientes
    Listas para probar
```

---

## 🎯 MÉTODO 2: PowerShell Manual

### Paso 1: Abre PowerShell
```
1. Presiona: Windows + R
2. Escribe: powershell
3. Presiona: Enter
```

### Paso 2: Ve a la carpeta
```powershell
cd "d:\Universidad\Prácticos\Séptimo Semestre\IHC\Proyecto III 2.0\app_pizzeria"
```

### Paso 3: Ejecuta el script
```powershell
.\run_dual_drivers.ps1
```

### Resultado
```
Se abrirán 2 ventanas PowerShell nuevas automáticamente
```

---

## 📱 QUÉ VERÁS DESPUÉS

### En cada ventana:

```
┌────────────────────────────────────────────────────┐
│                                                    │
│  🚀 Iniciando dos instancias de Pizzería Nova     │
│                                                    │
│  📱 Iniciando instancia 1 (Conductor 1)...        │
│                                                    │
│  ════════════════════════════════════════════     │
│  🚗 CONDUCTOR 1: Conductor 1                      │
│  ID: D1 | Puerto: 5913                            │
│  ════════════════════════════════════════════     │
│                                                    │
│  [ESPERANDO... compilando...]                     │
│                                                    │
│  [DESPUÉS DE 20-30 SEGUNDOS]                      │
│                                                    │
│  🚗 Instancia iniciada con Conductor ID: D1      │
│  ✅ Conductor D1 cargado automáticamente          │
│                                                    │
│  [LA APP ESTÁ LISTA]                              │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## 🎮 PRÓXIMOS PASOS (En la App)

### 1️⃣ Cuando aparezca la app (después de esperar):

```
Verás pantalla de Pizzería Nova
↓
Automáticamente cargado con Conductor D1 o D2
↓
NO hay selector (ya vino por parámetro)
```

### 2️⃣ Navega a "Mi Pedidos":

```
┌─────────────────────────────────────┐
│ 🍕 PIZZERÍA NOVA - DELIVERY         │
├─────────────────────────────────────┤
│                                     │
│  [📦 Mi Pedidos]  [🗺️ Mapa]        │
│   ↑                                 │
│   Toca aquí                         │
│                                     │
│  Verás tus pedidos asignados       │
│  (Diferentes en D1 y D2)           │
│                                     │
└─────────────────────────────────────┘
```

### 3️⃣ Abre un pedido y ve al mapa:

```
┌─────────────────────────────────────┐
│  [Pedido #12345]                    │
│  Estado: Repartidor Asignado        │
│                                     │
│  [Toca para abrir] ←─ Haz click    │
│                                     │
│  Se abrirá pantalla de mapa        │
│                                     │
└─────────────────────────────────────┘
```

### 4️⃣ En el mapa, toca el botón FakeGPS:

```
┌─────────────────────────────────────┐
│  🗺️ MAPA                            │
│                                     │
│  [Mapa interactivo]                │
│                                     │
│       (en esquina abajo derecha)    │
│       🎮 ← Botón naranja            │
│       [Toca aquí]                   │
│                                     │
│  Se abre diálogo de coordenadas     │
│                                     │
└─────────────────────────────────────┘
```

### 5️⃣ Ingresa coordenadas en FakeGPS:

```
┌─────────────────────────────────────┐
│  🎮 FakeGPS - Simular Ubicación     │
├─────────────────────────────────────┤
│                                     │
│  Latitud:  [-17.7836162         ]  │
│  Longitud: [-63.1814985         ]  │
│                                     │
│  💡 Sugerencias:                    │
│  • Restaurante: -17.7836162, ...    │
│  • Cliente: -17.7865, -63.1785      │
│  • Punto Medio: -17.7850, -63.1800  │
│                                     │
│  [Cancelar] [Limpiar] [✓ Aplicar]  │
│                         ↑           │
│                    Toca aquí        │
│                                     │
└─────────────────────────────────────┘
```

### 6️⃣ Ver cambios en HOT RELOAD:

```
Ventana D1 y Ventana D2 ejecutándose

Editas un archivo en tu editor

Ventana D1: Presionas 'r' → Cambios aparecen aquí
Ventana D2: Sigue con código anterior

Ventana D2: Presionas 'r' → Cambios aparecen aquí

¡INDEPENDIENTES!
```

---

## 🔄 FLUJO COMPLETO EN 5 PASOS

```
PASO 1: DOBLE CLICK run_dual_drivers.ps1
          ↓
PASO 2: ESPERA 30 SEGUNDOS
        (compila y carga)
          ↓
PASO 3: AMBAS VENTANAS LISTAS
        ├─ Ventana 1: D1
        └─ Ventana 2: D2
          ↓
PASO 4: PRUEBA INDEPENDENCIA
        ├─ FakeGPS en cada mapa (diferente)
        ├─ Hot reload 'r' (por separado)
        └─ Cambios en código (por ventana)
          ↓
PASO 5: ¡LISTO PARA PRODUCCIÓN!
        Ambos conductores funcionan simultáneamente
```

---

## ⏱️ TIMELINE EXACTO

```
00:00 - [DOBLE CLICK] run_dual_drivers.ps1
00:02 - PowerShell se abre, comienza flutter run
00:05 - Se abre Ventana 1 (D1)
00:10 - Se abre Ventana 2 (D2)
00:15 - Ambas compilando (ves mucho texto)
00:25 - Primer app lista (D1)
00:30 - Segundo app lista (D2)
        ✅ TODO FUNCIONA
00:35 - Prueba FakeGPS
01:00 - Completa pruebas iniciales
```

---

## ✅ CHECKLIST VISUAL

```
¿Seguiste PASO 1? (Abriste carpeta)
☐ SÍ  ☐ NO

¿Encontraste PASO 2? (run_dual_drivers.ps1)
☐ SÍ  ☐ NO

¿Hiciste PASO 3? (Doble click)
☐ SÍ  ☐ NO

¿Se abrieron 2 ventanas?
☐ SÍ  ☐ NO

¿Esperaste 30 segundos?
☐ SÍ  ☐ NO

¿Ves "CONDUCTOR 1" en ventana 1?
☐ SÍ  ☐ NO

¿Ves "CONDUCTOR 2" en ventana 2?
☐ SÍ  ☐ NO

¿Dice "Conductor X cargado automáticamente"?
☐ SÍ  ☐ NO

✅ SI MARCASTE TODOS → ¡LISTO!
❌ SI ALGUNO ES NO → Revisa troubleshooting
```

---

## 🆘 SI ALGO FALLA

```
❌ No se abrió nada
   → Abre PowerShell manualmente
   → Ve a la carpeta
   → Ejecuta: .\run_dual_drivers.ps1

❌ Se abrió 1 sola ventana
   → Espera más tiempo (hasta 60 segundos)
   → O ejecuta manualmente el segundo comando

❌ Ambas dicen D1
   → Cierra todo
   → Ejecuta de nuevo el script
   → Asegúrate de ver D1 y D2 diferentes

❌ No conecta a backend
   → Verifica: localhost:61689 está corriendo
   → Backend debe estar en ese puerto

❌ "Flutter not found"
   → Instala Flutter
   → O ejecuta PowerShell como administrador
```

---

## 🎓 PARA MEMORIZAR

```
┌────────────────────────────────────────┐
│  SOLO 3 COSAS QUE RECORDAR:           │
│                                        │
│  1. Carpeta: app_pizzeria             │
│  2. Archivo: run_dual_drivers.ps1     │
│  3. Acción: DOBLE CLICK               │
│                                        │
│  ¡ESO ES TODO!                        │
│                                        │
│  Tecla 'r' = hot reload (por ventana) │
│  Tecla 'q' = detener (por ventana)    │
└────────────────────────────────────────┘
```

---

## 🚀 COMIENZA YA

```
1. Abre Explorer
2. Ve a: app_pizzeria
3. Busca: run_dual_drivers.ps1
4. DOBLE CLICK
5. ¡AUTOMÁTICO! 🎉
```

---

*Instrucciones visuales - Diciembre 2024*
