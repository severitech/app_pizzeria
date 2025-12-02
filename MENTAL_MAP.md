# 🗺️ Mapa Mental - Sistema Dual de Conductores

```
                    ┌─────────────────────────────────────────┐
                    │   PIZZERÍA NOVA - DUAL CONDUCTORES      │
                    └──────────────────┬──────────────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                │                      │                      │
                ▼                      ▼                      ▼
        ┌─────────────────┐   ┌──────────────────┐   ┌─────────────────┐
        │ EMPEZAR RÁPIDO  │   │   ENTENDER TODO  │   │  HACER PRUEBAS  │
        └────────┬────────┘   └─────────┬────────┘   └────────┬────────┘
                 │                      │                      │
                 ├─ QUICK_START.md      ├─ DUAL_DRIVERS_  ─ TEST_SCENARIOS.md
                 │  (30 segundos)       │  GUIDE.md          (Casos uso)
                 │  "Solo haz click"    │  (Guía completa)
                 │                      │
                 └─► run_dual_drivers   └─► lib/main.dart
                    .ps1                   (Variables env)


                    ┌─────────────────────────────────────────┐
                    │      ¿CÓMO FUNCIONA INTERNAMENTE?       │
                    └──────────────────┬──────────────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                │                      │                      │
                ▼                      ▼                      ▼
        ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
        │ SCRIPT POWERSHELL│  │  COMPILACIÓN     │  │  INICIALIZACIÓN  │
        ├──────────────────┤  ├──────────────────┤  ├──────────────────┤
        │ run_dual_        │  │ --dart-define=   │  │ main() lee:      │
        │ drivers.ps1      │  │ DRIVER_ID=D1     │  │ - DRIVER_ID      │
        │                  │  │                  │  │ - setDriverId()  │
        │ ┌─ Ventana 1     │  │ ┌─ D1            │  │ - ApiServicios   │
        │ │ DRIVER_ID=D1   │  │ │                │  │   .setDriverId   │
        │ ├─ Ventana 2     │  │ ├─ D2            │  │   ('D1' o 'D2')  │
        │ │ DRIVER_ID=D2   │  │ │                │  │                  │
        │ └─ Espera 30s    │  │ └─ Independiente │  │ Resultado:       │
        └──────────────────┘  └──────────────────┘  │ Dos instancias   │
                                                    │ diferentes       │
                                                    └──────────────────┘


                    ┌─────────────────────────────────────────┐
                    │      FLUJO DE DATOS Y PEDIDOS          │
                    └──────────────────┬──────────────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                │                      │                      │
                ▼                      ▼                      ▼
         ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
         │  VENTANA D1  │      │  BACKEND API │      │  VENTANA D2  │
         ├──────────────┤      ├──────────────┤      ├──────────────┤
         │ ID: D1       │      │ localhost:   │      │ ID: D2       │
         │              │      │ 61689        │      │              │
         │ Pide:        │      │              │      │ Pide:        │
         │ /driver/     │◄────►│ Filtra por   │◄────►│ /driver/     │
         │ orders/D1    │      │ Conductor ID │      │ orders/D2    │
         │              │      │              │      │              │
         │ Recibe:      │      │              │      │ Recibe:      │
         │ - Pedido A   │      │              │      │ - Pedido B   │
         │ - Pedido C   │      │              │      │ - Pedido D   │
         │              │      │              │      │              │
         └──────────────┘      └──────────────┘      └──────────────┘


                    ┌─────────────────────────────────────────┐
                    │       CARACTERÍSTICAS ESPECIALES        │
                    └──────────────────┬──────────────────────┘
                                       │
        ┌──────────────────┬───────────┼──────────────┬──────────────────┐
        │                  │           │              │                  │
        ▼                  ▼           ▼              ▼                  ▼
   ┌─────────────┐  ┌────────────┐ ┌─────────┐ ┌──────────────┐ ┌───────────┐
   │  FakeGPS    │  │ Hot Reload │ │  Mapas  │ │ Independ.   │ │ Selector  │
   ├─────────────┤  ├────────────┤ ├─────────┤ ├──────────────┤ ├───────────┤
   │ Botón 🎮    │  │ Presiona r │ │ Mapa    │ │ Cada ventana:│ │ Si no hay │
   │ en mapa     │  │ en cada    │ │ interac.│ │ - Sus propios│ │ DRIVER_ID,│
   │             │  │ ventana    │ │ tivo    │ │   pedidos    │ │ selector  │
   │ Coordenadas │  │ independ.  │ │         │ │ - Su propio  │ │ manual D1 │
   │ personalizadas
