# Script para ejecutar dos instancias de la app en modo debug simultáneamente
# Cada una en un puerto diferente con IDs de conductor diferentes

Write-Host "🚀 Iniciando dos instancias de Pizzería Nova para pruebas duales de conductores..." -ForegroundColor Cyan
Write-Host ""

# Verificar que flutter esté disponible
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Flutter no está en el PATH. Asegúrate de tener Flutter instalado." -ForegroundColor Red
    exit 1
}

# Obtener el directorio del script (donde está el run_dual_drivers.ps1)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Función para ejecutar una instancia
function Invoke-DriverInstance {
    param(
        [int]$Instance,
        [string]$DriverId,
        [string]$DriverName,
        [int]$Port,
        [string]$ProjectDirectory
    )
    
    $title = "Conductor $Instance - $DriverName"
    Write-Host "📱 Iniciando instancia $Instance ($title) en puerto $Port..." -ForegroundColor Yellow
    
    # Crear una nueva ventana PowerShell para cada instancia
    Start-Process powershell -ArgumentList @(
        "-NoExit",
        "-Command",
        "Set-Location '$ProjectDirectory'; Write-Host '========================================' -ForegroundColor Green; Write-Host '🚗 CONDUCTOR $Instance`: $DriverName' -ForegroundColor Green; Write-Host 'ID: $DriverId | Puerto: $Port' -ForegroundColor Green; Write-Host '========================================' -ForegroundColor Green; Write-Host ''; `$env:FLUTTER_DRIVER_ID = '$DriverId'; `$env:FLUTTER_INSTANCE = $Instance; flutter run --debug -d windows --dart-define=DRIVER_ID=$DriverId --dart-define=INSTANCE_NUMBER=$Instance"
    ) -NoNewWindow:$false
}

Write-Host "📁 Directorio del proyecto: $ScriptDir" -ForegroundColor Cyan
Write-Host ""

# Iniciar instancia 1 (Conductor 1)
Invoke-DriverInstance -Instance 1 -DriverId "D1" -DriverName "Conductor 1" -Port 5913 -ProjectDirectory $ScriptDir

# Esperar un poco antes de iniciar la segunda instancia
Start-Sleep -Seconds 3

# Iniciar instancia 2 (Conductor 2)
Invoke-DriverInstance -Instance 2 -DriverId "D2" -DriverName "Conductor 2" -Port 5914 -ProjectDirectory $ScriptDir

Write-Host ""
Write-Host "✅ Ambas instancias han sido iniciadas." -ForegroundColor Green
Write-Host "📝 Notas:" -ForegroundColor Yellow
Write-Host "  • Cada ventana ejecuta un conductor diferente (D1 y D2)" -ForegroundColor Yellow
Write-Host "  • Los cambios en modo debug se aplican independientemente en cada instancia" -ForegroundColor Yellow
Write-Host "  • Cierra cualquier ventana para detener la instancia correspondiente" -ForegroundColor Yellow
Write-Host ""
Write-Host "Presiona Ctrl+C en cualquier ventana para detener la instancia." -ForegroundColor Cyan
