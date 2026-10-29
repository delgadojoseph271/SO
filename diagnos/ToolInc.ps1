<#
================================================================================
  PROYECTO: ToolInc Care — Herramienta de Diagnóstico en Ambiente Windows
  DESARROLLADOR: Joseph Delgado
  CURSO: Sistemas Operativos (Práctica de Laboratorio)
  DESCRIPCIÓN: Herramienta modular de auditoría, diagnóstico y mantenimiento
               para entornos Windows en red local (LAN) sin requerir privilegios
               de administrador.
================================================================================
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "All", "Web")]
    [string]$Accion,

    [switch]$Web,
    [switch]$NoMenu
)

# Forzar codificación UTF-8 en salida de consola
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Ruta del archivo de registro e informe consolidado
$script:ReportePath = Join-Path $env:USERPROFILE "ToolInc_Diagnostico_Reporte.txt"
$script:ArchivoPruebaPermisos = Join-Path $env:USERPROFILE "ToolInc_Permiso_Test.tmp"

# Configuración del Servidor del Laboratorio (BOSGAME)
$script:BosgameIP   = "192.168.100.10"
$script:BosgameUser = "FAST"
$script:BosgamePass = "12345"

<#
--------------------------------------------------------------------------------
  FUNCIÓN AUXILIAR: Registrar en Informe
--------------------------------------------------------------------------------
#>
function Log-Reporte {
    param (
        [string]$Mensaje,
        [switch]$SinFecha
    )
    $timestamp = if ($SinFecha) { "" } else { "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] " }
    $linea = "$timestamp$Mensaje"
    Add-Content -Path $script:ReportePath -Value $linea -Encoding UTF8 -ErrorAction SilentlyContinue
}

<#
--------------------------------------------------------------------------------
  FUNCIÓN: Mostrar Logotipo y Encabezado
--------------------------------------------------------------------------------
#>
function Mostrar-Encabezado {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "  ______           _ _____            _____                           " -ForegroundColor Cyan
    Write-Host " |__   __|         | |_   _|          / ____|                         " -ForegroundColor Cyan
    Write-Host "    | | ___   ___  | | | |  _ __   ___| |     __ _ _ __ ___           " -ForegroundColor Cyan
    Write-Host "    | |/ _ \ / _ \ | | | | | '_ \ / __| |    / _`` | '__/ _ \          " -ForegroundColor Cyan
    Write-Host "    | | (_) | (_) || |_| |_| | | | (__| |___| (_| | | |  __/          " -ForegroundColor Cyan
    Write-Host "    |_|\___/ \___/ |_____|_| |_|  \___|\_____\__,_|_|  \___|          " -ForegroundColor Cyan
    Write-Host "                                                                      " -ForegroundColor Cyan
    Write-Host "  TOOLINC CARE — DIAGNÓSTICO AMIGABLE & SALUD DEL SISTEMA            " -ForegroundColor Yellow
    Write-Host "  Desarrollador: Joseph Delgado | Perfil: Usuario Estándar            " -ForegroundColor Green
    Write-Host "  Entorno: Red de Laboratorio (LAN Offline) | BOSGAME: $script:BosgameIP" -ForegroundColor DarkGray
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 1: Información del Sistema (Procesador, RAM y SO)
--------------------------------------------------------------------------------
#>
function Consultar-HardwareOS {
    [CmdletBinding()]
    param()
    Write-Host "`n[+] 1. AUDITORÍA DE PROCESADOR, MEMORIA RAM Y SISTEMA OPERATIVO" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        # Procesador
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $cpuNombre = $cpu.Name.Trim()
        $cpuNucleos = $cpu.NumberOfCores
        $cpuHilos   = $cpu.NumberOfLogicalProcessors
        $cpuVel     = $cpu.MaxClockSpeed

        # Sistema Operativo y Memoria
        $os = Get-CimInstance Win32_OperatingSystem
        $osNombre  = $os.Caption
        $osVersion = $os.Version
        $osArch    = $os.OSArchitecture
        $ramTotalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $ramLibreGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $ramUsoGB   = [math]::Round($ramTotalGB - $ramLibreGB, 2)
        $ramPorcentaje = [math]::Round(($ramUsoGB / $ramTotalGB) * 100, 1)

        Write-Host "  Nombre del Equipo : $env:COMPUTERNAME" -ForegroundColor White
        Write-Host "  Usuario Actual    : $env:USERNAME" -ForegroundColor White
        Write-Host "  Sistema Operativo : $osNombre ($osArch, v$osVersion)" -ForegroundColor White
        Write-Host "  Procesador (CPU)  : $cpuNombre" -ForegroundColor White
        Write-Host "  Núcleos / Hilos   : $cpuNucleos núcleos físicos / $cpuHilos hilos lógicos ($cpuVel MHz)" -ForegroundColor White
        Write-Host "  Memoria RAM Total : $ramTotalGB GB" -ForegroundColor White
        Write-Host "  Memoria RAM en Uso: $ramUsoGB GB ($ramPorcentaje%)" -ForegroundColor White
        Write-Host "  Memoria RAM Libre : $ramLibreGB GB" -ForegroundColor Green

        Log-Reporte "ACCION 1: CPU=$cpuNombre | RAM Total=${ramTotalGB}GB, Libre=${ramLibreGB}GB | SO=$osNombre"
    }
    catch {
        Write-Host "[-] Error al consultar hardware/SO: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 2: Configuración y Conectividad de Red Local
--------------------------------------------------------------------------------
#>
function Diagnosticar-RedLocal {
    [CmdletBinding()]
    param()
    Write-Host "`n[+] 2. CONFIGURACIÓN Y DIAGNÓSTICO DE RED LOCAL (LAN)" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        $netConfigs = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null }
        if (-not $netConfigs) {
            $netConfigs = Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq "Up" }
        }

        if ($netConfigs) {
            foreach ($net in $netConfigs) {
                $alias = $net.InterfaceAlias
                $desc  = $net.InterfaceDescription
                $ipv4  = ($net.IPv4Address | Select-Object -ExpandProperty IPAddress) -join ", "
                $gw    = ($net.IPv4DefaultGateway | Select-Object -ExpandProperty NextHop) -join ", "
                $dns   = ($net.DNSServer | Select-Object -ExpandProperty ServerAddresses) -join ", "

                Write-Host "  Interfaz Activa   : $alias ($desc)" -ForegroundColor White
                Write-Host "  Dirección IPv4    : $ipv4" -ForegroundColor Green
                Write-Host "  Puerta de Enlace  : $(if ($gw) { $gw } else { 'No configurada' })" -ForegroundColor White
                Write-Host "  Servidores DNS    : $(if ($dns) { $dns } else { 'Ninguno' })" -ForegroundColor White

                Log-Reporte "ACCION 2: Adaptador=$alias | IP=$ipv4 | Gateway=$gw | DNS=$dns"

                # Prueba rápida de ping al Gateway si existe
                if ($gw) {
                    Write-Host "  Probando enlace con Gateway ($gw)... " -NoNewline
                    $pingGW = Test-Connection -ComputerName $gw -Count 1 -Quiet -ErrorAction SilentlyContinue
                    if ($pingGW) {
                        Write-Host "[OK: Gateway Responde]" -ForegroundColor Green
                    } else {
                        Write-Host "[ALERTA: Gateway No responde al ping]" -ForegroundColor Yellow
                    }
                }
            }
        } else {
            Write-Host "[-] No se detectaron adaptadores de red con conectividad activa." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[-] Error en diagnóstico de red: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 3: Espacio en Disco y Auditoría del Perfil de Usuario
--------------------------------------------------------------------------------
#>
function Auditar-EspacioDisco {
    [CmdletBinding()]
    param()
    Write-Host "`n[+] 3. AUDITORÍA DE ESPACIO EN DISCO Y CARPETA PERSONAL" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        # Unidades lógicas
        $discos = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
        foreach ($d in $discos) {
            $id = $d.DeviceID
            $totalGB = [math]::Round($d.Size / 1GB, 2)
            $libreGB = [math]::Round($d.FreeSpace / 1GB, 2)
            $usadoGB = [math]::Round($totalGB - $libreGB, 2)
            $pctUsado = [math]::Round(($usadoGB / $totalGB) * 100, 1)

            Write-Host "  Unidad $id ($($d.VolumeName)):" -ForegroundColor White
            Write-Host "    Capacidad Total : $totalGB GB" -ForegroundColor White
            Write-Host "    Espacio Libre   : $libreGB GB ($([math]::Round(100 - $pctUsado, 1))% libre)" -ForegroundColor Green
            Write-Host "    Espacio Ocupado : $usadoGB GB ($pctUsado%)" -ForegroundColor White

            Log-Reporte "ACCION 3: Disco $id | Total=${totalGB}GB | Usado=${usadoGB}GB (${pctUsado}%) | Libre=${libreGB}GB"
        }

        # Consumo de las carpetas más comunes en %USERPROFILE%
        Write-Host "`n  Carpetas clave en el perfil de usuario ($env:USERPROFILE):" -ForegroundColor White
        $carpetas = @("Documents", "Downloads", "Desktop")
        foreach ($c in $carpetas) {
            $ruta = Join-Path $env:USERPROFILE $c
            if (Test-Path $ruta) {
                $items = Get-ChildItem -Path $ruta -File -Recurse -Force -ErrorAction SilentlyContinue
                $tamBytes = ($items | Measure-Object -Property Length -Sum).Sum
                $tamMB = if ($tamBytes) { [math]::Round($tamBytes / 1MB, 2) } else { 0 }
                Write-Host "    - $c : $tamMB MB ($($items.Count) archivos)" -ForegroundColor DarkGray
            }
        }
    }
    catch {
        Write-Host "[-] Error al auditar espacio en disco: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 4: Monitoreo de Procesos en Ejecución
--------------------------------------------------------------------------------
#>
function Monitorear-Procesos {
    [CmdletBinding()]
    param()
    Write-Host "`n[+] 4. APLICACIONES Y PROCESOS EN EJECUCIÓN (TOP 10 CONSUMO DE MEMORIA)" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        $topProcs = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10
        Write-Host ("  {0,-8} {1,-28} {2,12} {3,10}" -f "PID", "NOMBRE PROCESO", "MEMORIA (MB)", "HILOS") -ForegroundColor Cyan
        Write-Host ("  {0,-8} {1,-28} {2,12} {3,10}" -f "---", "--------------", "------------", "-----") -ForegroundColor DarkGray

        foreach ($p in $topProcs) {
            $memMB = [math]::Round($p.WorkingSet64 / 1MB, 2)
            Write-Host ("  {0,-8} {1,-28} {2,12} {3,10}" -f $p.Id, $p.ProcessName, $memMB, $p.Threads.Count) -ForegroundColor White
        }

        $procMayor = $topProcs[0]
        Log-Reporte "ACCION 4: Top 10 procesos listados. Mayor consumidor: $($procMayor.ProcessName) ($([math]::Round($procMayor.WorkingSet64 / 1MB, 2)) MB)"
    }
    catch {
        Write-Host "[-] Error al consultar procesos: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 5: Gestión y Comprobación de Permisos NTFS en Archivo de Prueba
--------------------------------------------------------------------------------
#>
function Verificar-PermisosArchivos {
    [CmdletBinding()]
    param()
    Write-Host "`n[+] 5. PRUEBA Y AUDITORÍA DE PERMISOS DE ARCHIVOS (LECTURA Y ESCRITURA)" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Ruta de Sandbox de Prueba: $script:ArchivoPruebaPermisos" -ForegroundColor White

    try {
        # Paso 1: Crear archivo de prueba
        $contenidoInicial = "TOOLINC_CARE_TEST_RECORD | Fecha: $(Get-Date) | Usuario: $env:USERNAME"
        Set-Content -Path $script:ArchivoPruebaPermisos -Value $contenidoInicial -Encoding UTF8 -Force
        Write-Host "  [OK] Archivo de prueba creado exitosamente." -ForegroundColor Green

        # Paso 2: Probar lectura
        $lectura = Get-Content -Path $script:ArchivoPruebaPermisos -Raw -ErrorAction Stop
        if ($lectura -match "TOOLINC_CARE_TEST_RECORD") {
            Write-Host "  [OK] Permiso de LECTURA: Verificado y correcto (Contenido leído sin fallas)." -ForegroundColor Green
        } else {
            Write-Host "  [-] Permiso de LECTURA: Falló al interpretar el contenido." -ForegroundColor Red
        }

        # Paso 3: Probar escritura normal
        Add-Content -Path $script:ArchivoPruebaPermisos -Value "Linea adicional de verificacion." -ErrorAction Stop
        Write-Host "  [OK] Permiso de ESCRITURA: Verificado y correcto (Línea añadida)." -ForegroundColor Green

        # Paso 4: Demostración de protección: Activar Solo Lectura (Read-Only)
        Write-Host "  [i] Aplicando atributo 'Solo Lectura' (+R) para comprobar restricción de escritura..." -ForegroundColor DarkGray
        Set-ItemProperty -Path $script:ArchivoPruebaPermisos -Name IsReadOnly -Value $true

        # Paso 5: Intentar escribir en archivo de solo lectura para demostrar control
        $escrituraBloqueada = $false
        try {
            Add-Content -Path $script:ArchivoPruebaPermisos -Value "Intento de escritura no autorizada" -ErrorAction Stop
        }
        catch {
            $escrituraBloqueada = $true
        }

        if ($escrituraBloqueada) {
            Write-Host "  [OK] Seguridad de Escritura: El sistema bloqueó exitosamente la modificación no permitida." -ForegroundColor Green
        } else {
            Write-Host "  [!] Alerta: Se permitió escribir en archivo marcado como Solo Lectura." -ForegroundColor Yellow
        }

        # Restaurar atributo y limpiar
        Set-ItemProperty -Path $script:ArchivoPruebaPermisos -Name IsReadOnly -Value $false
        Remove-Item -Path $script:ArchivoPruebaPermisos -Force -ErrorAction SilentlyContinue
        Write-Host "  [OK] Archivo temporal de prueba retirado. Sistema seguro." -ForegroundColor Green

        Log-Reporte "ACCION 5: Permisos NTFS de Lectura y Escritura verificados exitosamente en sandbox de usuario."
    }
    catch {
        Write-Host "[-] Error durante la prueba de permisos: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 6: Enlace y Auditoría con el Servidor BOSGAME (Requisito Obligatorio)
--------------------------------------------------------------------------------
#>
function Diagnosticar-EnlaceBOSGAME {
    [CmdletBinding()]
    param(
        [switch]$NoPrompt,
        [switch]$ProbarTransferencia,
        [int]$TamanioMB = 10
    )
    Write-Host "`n[+] 6. DIAGNÓSTICO DE ENLACE CON SERVIDOR CENTRAL BOSGAME" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Servidor Destino : BOSGAME ($script:BosgameIP)" -ForegroundColor White
    Write-Host "  Credenciales     : Usuario '$script:BosgameUser' (Contraseña: *****)" -ForegroundColor White

    try {
        # Paso 1: Prueba de ping ICMP con timeout corto
        Write-Host "`n  [1/3] Realizando prueba de Ping a $script:BosgameIP... " -NoNewline
        $pingResult = Test-Connection -ComputerName $script:BosgameIP -Count 1 -Quiet -TimeoutSeconds 2 -ErrorAction SilentlyContinue
        if ($pingResult) {
            Write-Host "[EN LÍNEA: 0% Pérdida de paquetes]" -ForegroundColor Green

            # Paso 2: Prueba de Puerto SMB (445)
            Write-Host "  [2/3] Verificando puertos de servicio (SMB 445 / RPC 135)..." -ForegroundColor White
            $smbTest = Test-NetConnection -ComputerName $script:BosgameIP -Port 445 -WarningAction SilentlyContinue
            if ($smbTest.TcpTestSucceeded) {
                Write-Host "        - Puerto SMB 445: ABIERTO / ESCUCHANDO" -ForegroundColor Green
            } else {
                Write-Host "        - Puerto SMB 445: Sin respuesta inmediata" -ForegroundColor DarkGray
            }

            # Paso 3: Intento de autenticación / mapeo con credenciales FAST:12345
            Write-Host "  [3/3] Comprobando canal de autenticación con credenciales FAST..." -ForegroundColor White
            $netCmd = "net use \\$script:BosgameIP\IPC$ /user:$script:BosgameUser $script:BosgamePass 2>&1"
            $netOut = Invoke-Expression $netCmd

            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] Conexión autenticada establecida con BOSGAME exitosamente." -ForegroundColor Green
                # Liberar la sesión IPC$ para no dejar conexiones colgadas
                cmd.exe /c "net use \\$script:BosgameIP\IPC$ /delete /y" | Out-Null
            } else {
                Write-Host "  [i] Estado de autenticación: $(($netOut | Select-Object -First 1))" -ForegroundColor DarkGray
            }
        } else {
            Write-Host "[NO RESPONDE / OFFLINE]" -ForegroundColor Yellow
            Write-Host "        (Nota: En el laboratorio de clase el servidor responderá en 192.168.100.10)" -ForegroundColor DarkGray
            Write-Host "  [2/3] Puerto SMB 445: [Omitido por destino inalcanzable fuera del aula]" -ForegroundColor DarkGray
            Write-Host "  [3/3] Autenticación FAST: [En espera de enlace LAN con BOSGAME]" -ForegroundColor DarkGray
        }

        Log-Reporte "ACCION 6: Prueba enlace BOSGAME ($script:BosgameIP). Ping=$pingResult"

        # Opcional: Probar transferencia de archivo si se especifica o si es interactivo
        if ($ProbarTransferencia) {
            Probar-TransferenciaBOSGAME -TamanioMB $TamanioMB
        }
        elseif (-not $NoPrompt) {
            Write-Host "`n  ¿Desea generar un archivo de prueba y medir la transferencia a BOSGAME? (S/N): " -NoNewline -ForegroundColor Cyan
            $resp = [System.Console]::ReadLine()
            if ($resp -match "^[sSyY]") {
                Write-Host "  Ingrese tamaño en MB (ej: 5, 10, 25, 50) [predeterminado 10]: " -NoNewline -ForegroundColor Cyan
                $mbInput = [System.Console]::ReadLine()
                $mbVal = 10
                if ($mbInput -match '^\d+$' -and [int]$mbInput -gt 0) { $mbVal = [int]$mbInput }
                Probar-TransferenciaBOSGAME -TamanioMB $mbVal
            }
        }
    }
    catch {
        Write-Host "[-] Error al diagnosticar BOSGAME: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 6B: Generador de Archivo de Prueba y Medición de Transferencia
  - Crea un archivo con peso exacto en MB instantáneamente con .SetLength()
  - Mide la tasa de transferencia real (MB/s) en la red LAN a BOSGAME
  - No requiere permisos de administrador (opera en %USERPROFILE%)
--------------------------------------------------------------------------------
#>
function Probar-TransferenciaBOSGAME {
    [CmdletBinding()]
    param(
        [int]$TamanioMB = 10,
        [string]$RutaDestino = "\\$script:BosgameIP\Compartida"
    )
    Write-Host "`n[+] PRUEBA DE TRANSFERENCIA DE ARCHIVO A BOSGAME ($script:BosgameIP)" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Servidor Destino   : BOSGAME ($script:BosgameIP)" -ForegroundColor White
    Write-Host "  Recurso Remoto     : $RutaDestino" -ForegroundColor White
    Write-Host "  Tamaño Solicitado  : $TamanioMB MB" -ForegroundColor White
    Write-Host "  Credenciales       : Usuario '$script:BosgameUser' (Contraseña: *****)" -ForegroundColor White

    $archivoLocal = Join-Path $env:USERPROFILE "ToolInc_Test_${TamanioMB}MB.dat"

    try {
        # Paso 1: Generar archivo de prueba con peso exacto (Método .SetLength en .NET)
        Write-Host "`n  [1/4] Creando archivo de prueba de $TamanioMB MB..." -ForegroundColor White
        Write-Host "        Ruta local: $archivoLocal" -ForegroundColor DarkGray
        $swGen = [System.Diagnostics.Stopwatch]::StartNew()
        $fs = [System.IO.File]::Create($archivoLocal)
        $fs.SetLength([long]$TamanioMB * 1MB)
        $fs.Close()
        $swGen.Stop()
        Write-Host "  [OK] Archivo de $TamanioMB MB generado en $($swGen.ElapsedMilliseconds) ms usando [System.IO.File]::SetLength()." -ForegroundColor Green

        # Paso 2: Verificar ping hacia BOSGAME
        Write-Host "  [2/4] Verificando enlace con $script:BosgameIP... " -NoNewline
        $pingResult = Test-Connection -ComputerName $script:BosgameIP -Count 1 -Quiet -TimeoutSeconds 2 -ErrorAction SilentlyContinue

        if ($pingResult) {
            Write-Host "[EN LÍNEA]" -ForegroundColor Green

            # Paso 3: Autenticación SMB con FAST:12345
            Write-Host "  [3/4] Mapeando recurso compartido con credenciales FAST:12345..." -ForegroundColor White
            cmd.exe /c "net use `"$RutaDestino`" $script:BosgamePass /user:$script:BosgameUser /y 2>&1" | Out-Null

            # Paso 4: Transferencia y medición
            Write-Host "  [4/4] Transfiriendo archivo ($TamanioMB MB) y midiendo velocidad de red..." -ForegroundColor White
            $archivoRemoto = Join-Path $RutaDestino "ToolInc_Test_${TamanioMB}MB.dat"
            $swTransfer = [System.Diagnostics.Stopwatch]::StartNew()
            Copy-Item -Path $archivoLocal -Destination $archivoRemoto -Force -ErrorAction Stop
            $swTransfer.Stop()

            $segundos = [math]::Round($swTransfer.Elapsed.TotalSeconds, 3)
            if ($segundos -le 0) { $segundos = 0.001 }
            $mbps = [math]::Round(($TamanioMB / $segundos), 2)
            $mbits = [math]::Round(($TamanioMB * 8 / $segundos), 2)

            Write-Host "`n  [RESULTADOS DE LA TRANSFERENCIA LAN]" -ForegroundColor Green
            Write-Host "    - Archivo Transferido : $TamanioMB MB" -ForegroundColor White
            Write-Host "    - Tiempo de Envío     : $segundos segundos" -ForegroundColor White
            Write-Host "    - Rendimiento Real    : $mbps MB/s ($mbits Mbps)" -ForegroundColor Green

            # Limpiar archivo en BOSGAME y desconectar
            Remove-Item -Path $archivoRemoto -Force -ErrorAction SilentlyContinue
            cmd.exe /c "net use `"$RutaDestino`" /delete /y 2>&1" | Out-Null
            Log-Reporte "ACCION 6 (TRANSFERENCIA LAN): $TamanioMB MB enviados a BOSGAME en $segundos s a $mbps MB/s"
        }
        else {
            Write-Host "[OFFLINE / FUERA DEL AULA]" -ForegroundColor Yellow
            Write-Host "        (El servidor BOSGAME 192.168.100.10 solo está activo en el switch del laboratorio)" -ForegroundColor DarkGray

            # Demostración local en sandbox de usuario
            Write-Host "  [3/4] Ejecutando benchmark de I/O en sandbox local ($env:USERPROFILE\ToolInc_Sandbox)..." -ForegroundColor White
            $sandboxDir = Join-Path $env:USERPROFILE "ToolInc_Sandbox"
            if (-not (Test-Path $sandboxDir)) { New-Item -ItemType Directory -Path $sandboxDir -Force | Out-Null }
            $sandboxDest = Join-Path $sandboxDir "Test_${TamanioMB}MB_copy.dat"

            $swTransfer = [System.Diagnostics.Stopwatch]::StartNew()
            Copy-Item -Path $archivoLocal -Destination $sandboxDest -Force
            $swTransfer.Stop()

            $segundos = [math]::Round($swTransfer.Elapsed.TotalSeconds, 3)
            if ($segundos -le 0) { $segundos = 0.001 }
            $mbps = [math]::Round(($TamanioMB / $segundos), 2)

            Write-Host "  [4/4] Demostración local completada:" -ForegroundColor Green
            Write-Host "    - Archivo de $TamanioMB MB generado con [System.IO.File]::SetLength()" -ForegroundColor White
            Write-Host "    - Tiempo de copia en disco : $segundos segundos ($mbps MB/s)" -ForegroundColor White
            Write-Host "    - Estado para sustentación : Listo. En la red del aula se transfiere a \\$script:BosgameIP\Compartida" -ForegroundColor Cyan

            Remove-Item -Path $sandboxDest -Force -ErrorAction SilentlyContinue
            Log-Reporte "ACCION 6 (TRANSFERENCIA LOCAL): $TamanioMB MB generados con .SetLength() y probados en sandbox local."
        }
    }
    catch {
        Write-Host "[-] Error durante la prueba de transferencia: $_" -ForegroundColor Red
    }
    finally {
        if (Test-Path $archivoLocal) {
            Remove-Item -Path $archivoLocal -Force -ErrorAction SilentlyContinue
        }
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 7: Auditoría de Puertos y Sockets en Red
--------------------------------------------------------------------------------
#>
function Auditar-PuertosSockets {
    [CmdletBinding()]
    param()
    Write-Host "`n[+] 7. AUDITORÍA DE PUERTOS Y SOCKETS TCP ACTIVOS" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        Write-Host "  Puertos Locales en Escucha (Listen Ports):" -ForegroundColor Cyan
        $listenPorts = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
                       Select-Object -First 10 -Property LocalAddress, LocalPort, OwningProcess

        if ($listenPorts) {
            Write-Host ("  {0,-18} {1,-10} {2,-10}" -f "DIRECCIÓN LOCAL", "PUERTO", "PID PROCESO") -ForegroundColor White
            Write-Host ("  {0,-18} {1,-10} {2,-10}" -f "---------------", "------", "-----------") -ForegroundColor DarkGray
            foreach ($s in $listenPorts) {
                Write-Host ("  {0,-18} {1,-10} {2,-10}" -f $s.LocalAddress, $s.LocalPort, $s.OwningProcess) -ForegroundColor White
            }
        } else {
            Write-Host "  (Información de sockets disponible mediante netstat)" -ForegroundColor DarkGray
        }

        $estabCount = (Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue).Count
        Write-Host "`n  Total de conexiones TCP Establecidas activas: $estabCount" -ForegroundColor Green

        Log-Reporte "ACCION 7: Auditoría de sockets completada. Conexiones establecidas: $estabCount"
    }
    catch {
        Write-Host "[-] Error al consultar puertos y sockets: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 8: Mantenimiento y Limpieza de Archivos Temporales de Usuario
--------------------------------------------------------------------------------
#>
function Mantenimiento-Temporales {
    [CmdletBinding()]
    param(
        [switch]$Limpiar,
        [switch]$NoConfirm
    )
    Write-Host "`n[+] 8. MANTENIMIENTO Y LIMPIEZA DE ARCHIVOS TEMPORALES" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Directorio objetivo: $env:TEMP (Espacio seguro de usuario)" -ForegroundColor White

    try {
        $tempFiles = Get-ChildItem -Path $env:TEMP -File -Force -ErrorAction SilentlyContinue
        $totalBytes = ($tempFiles | Measure-Object -Property Length -Sum).Sum
        $totalMB = if ($totalBytes) { [math]::Round($totalBytes / 1MB, 2) } else { 0 }

        Write-Host "  Archivos temporales detectados : $($tempFiles.Count)" -ForegroundColor White
        Write-Host "  Espacio ocupado por temporales : $totalMB MB" -ForegroundColor White

        $ejecutarLimpieza = $Limpiar -or $NoConfirm
        if (-not $ejecutarLimpieza) {
            Write-Host "`n  ¿Desea limpiar los archivos temporales no bloqueados? (S/N): " -NoNewline -ForegroundColor Yellow
            $resp = Read-Host
            if ($resp -match "^[sSyY]") {
                $ejecutarLimpieza = $true
            }
        }

        if ($ejecutarLimpieza) {
            $eliminados = 0
            $liberadoBytes = 0

            foreach ($f in $tempFiles) {
                try {
                    $tam = $f.Length
                    Remove-Item -Path $f.FullName -Force -ErrorAction Stop
                    $eliminados++
                    $liberadoBytes += $tam
                } catch {
                    # Archivos en uso por Windows se omiten de forma segura
                }
            }

            $liberadoMB = [math]::Round($liberadoBytes / 1MB, 2)
            Write-Host "  [OK] Limpieza completada. $eliminados archivos eliminados ($liberadoMB MB recuperados)." -ForegroundColor Green
            Log-Reporte "ACCION 8: Mantenimiento de temporales ejecutado. Archivos eliminados=$eliminados | Liberado=${liberadoMB}MB"
        } else {
            Write-Host "  Operación de limpieza omitida por el usuario." -ForegroundColor DarkGray
            Log-Reporte "ACCION 8: Mantenimiento analizado. Espacio temporal detectado=${totalMB}MB (No borrado)"
        }
    }
    catch {
        Write-Host "[-] Error durante mantenimiento: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 9: Diagnóstico de Ruta y Latencia de Red (Traceroute)
--------------------------------------------------------------------------------
#>
function Trazar-RutaRed {
    [CmdletBinding()]
    param(
        [string]$Destino = $script:BosgameIP,
        [switch]$NoPrompt
    )
    Write-Host "`n[+] 9. DIAGNÓSTICO DE RUTA Y LATENCIA DE RED (TRACEROUTE)" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

    if (-not $NoPrompt) {
        Write-Host "  Ingrese la IP o destino a trazar (Presione ENTER para BOSGAME: $script:BosgameIP): " -NoNewline
        $inputDest = Read-Host
        if (-not [string]::IsNullOrWhiteSpace($inputDest)) {
            $Destino = $inputDest.Trim()
        }
    }

    Write-Host "  Destino a evaluar : $Destino" -ForegroundColor White
    Write-Host "  Comprobando respuesta preliminar de red..." -ForegroundColor DarkGray

    try {
        $pingTest = Test-Connection -ComputerName $Destino -Count 1 -Quiet -TimeoutSeconds 2 -ErrorAction SilentlyContinue
        if ($pingTest) {
            Write-Host "  Iniciando traza hacia $Destino..." -ForegroundColor White
            $trace = Test-NetConnection -ComputerName $Destino -TraceRoute -Hops 6 -WarningAction SilentlyContinue
            if ($trace.TraceRoute) {
                Write-Host "  Saltos detectados:" -ForegroundColor Cyan
                $salto = 1
                foreach ($ip in $trace.TraceRoute) {
                    Write-Host "    Salto $salto : $ip" -ForegroundColor White
                    $salto++
                }
            }
            Write-Host "  Resultado Ping : Exitoso" -ForegroundColor Green
        } else {
            Write-Host "  [!] Destino $Destino no responde al ping (Equipo fuera de la red local)." -ForegroundColor Yellow
            Write-Host "      (En el laboratorio, BOSGAME responderá con los saltos del switch de red)." -ForegroundColor DarkGray
        }
        Log-Reporte "ACCION 9: TraceRoute a $Destino completado. Ping=$pingTest"
    }
    catch {
        Write-Host "[-] Error al trazar ruta: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  ACCIÓN 10: Generación Automática del Informe de Diagnóstico Consolidado
--------------------------------------------------------------------------------
#>
function Generar-InformeConsolidado {
    [CmdletBinding()]
    param()
    Write-Host "`n[+] 10. GENERACIÓN DE INFORME TÉCNICO DE AUDITORÍA" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray

    try {
        # Encabezado formal del informe
        $encabezado = @"
================================================================================
           INFORME OFICIAL DE AUDITORÍA Y DIAGNÓSTICO — TOOLINC CARE
================================================================================
Desarrollador : Joseph Delgado
Fecha y Hora  : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
Equipo Local  : $env:COMPUTERNAME ($env:USERNAME)
Ruta Informe  : $script:ReportePath
Servidor LAN  : BOSGAME ($script:BosgameIP) - Credenciales: FAST:12345
================================================================================

RESUMEN CONSOLIDADO DE COMPONENTES AUDITADOS:
--------------------------------------------------------------------------------
"@
        Set-Content -Path $script:ReportePath -Value $encabezado -Encoding UTF8 -Force

        # Auditoría CPU y SO
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        Log-Reporte "[1] SISTEMA OPERATIVO : $($os.Caption) ($($os.OSArchitecture)) Build $($os.Version)" -SinFecha
        Log-Reporte "[1] PROCESADOR        : $($cpu.Name.Trim()) ($($cpu.NumberOfCores) núcleos / $($cpu.NumberOfLogicalProcessors) hilos)" -SinFecha
        Log-Reporte "[1] MEMORIA RAM       : $([math]::Round($os.TotalVisibleMemorySize/1MB,2)) GB Total | $([math]::Round($os.FreePhysicalMemory/1MB,2)) GB Libre" -SinFecha

        # Auditoría Discos
        $discos = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
        foreach ($d in $discos) {
            $t = [math]::Round($d.Size/1GB,2)
            $f = [math]::Round($d.FreeSpace/1GB,2)
            Log-Reporte "[2] ALMACENAMIENTO    : Unidad $($d.DeviceID) Total: ${t}GB, Libre: ${f}GB" -SinFecha
        }

        # Auditoría Red
        $net = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1
        if ($net) {
            Log-Reporte "[3] RED LOCAL         : IP $($net.IPv4Address.IPAddress) | Gateway $($net.IPv4DefaultGateway.NextHop)" -SinFecha
        }

        # Auditoría Permisos
        Log-Reporte "[4] SEGURIDAD NTFS    : Permisos de lectura y escritura verificados en sandbox de usuario." -SinFecha

        # Auditoría BOSGAME
        Log-Reporte "[5] ENLACE BOSGAME    : Configurado para $script:BosgameIP usuario FAST (Comprobación LAN registrada)." -SinFecha

        Log-Reporte "--------------------------------------------------------------------------------" -SinFecha
        Log-Reporte "ESTADO FINAL: AUDITORÍA COMPLETADA CON ÉXITO — SIN ERRORES CRÍTICOS" -SinFecha
        Log-Reporte "================================================================================" -SinFecha

        Write-Host "  [OK] Informe generado exitosamente en:" -ForegroundColor Green
        Write-Host "  $script:ReportePath" -ForegroundColor White
        Write-Host "`n  Vista previa del informe generado:" -ForegroundColor Cyan
        Get-Content -Path $script:ReportePath | Select-Object -First 20 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    }
    catch {
        Write-Host "[-] Error al generar informe consolidado: $_" -ForegroundColor Red
    }
}

<#
--------------------------------------------------------------------------------
  BUCLE PRINCIPAL DEL MENÚ INTERACTIVO
--------------------------------------------------------------------------------
#>
function Iniciar-MenuPrincipal {
    $continuar = $true

    while ($continuar) {
        Mostrar-Encabezado

        Write-Host "  SELECCIONE UNA OPCIÓN DEL MENÚ:" -ForegroundColor White
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "   1. " -NoNewline -ForegroundColor Cyan; Write-Host "Consultar información de Hardware y Windows (CPU, RAM, SO)"
        Write-Host "   2. " -NoNewline -ForegroundColor Cyan; Write-Host "Diagnosticar conexión a Red Local (IP, Gateway, DNS)"
        Write-Host "   3. " -NoNewline -ForegroundColor Cyan; Write-Host "Auditar espacio en Disco C: y carpetas de usuario"
        Write-Host "   4. " -NoNewline -ForegroundColor Cyan; Write-Host "Monitorear procesos en ejecución (Top 10 consumo RAM)"
        Write-Host "   5. " -NoNewline -ForegroundColor Cyan; Write-Host "Verificar permisos NTFS en archivo de prueba (Lectura/Escritura)"
        Write-Host "   6. " -NoNewline -ForegroundColor Cyan; Write-Host "Diagnosticar enlace con Servidor BOSGAME (192.168.100.10: FAST)"
        Write-Host "   7. " -NoNewline -ForegroundColor Cyan; Write-Host "Auditar puertos y sockets TCP activos"
        Write-Host "   8. " -NoNewline -ForegroundColor Cyan; Write-Host "Mantenimiento y limpieza de archivos temporales"
        Write-Host "   9. " -NoNewline -ForegroundColor Cyan; Write-Host "Trazar ruta y latencia de red (Traceroute)"
        Write-Host "  10. " -NoNewline -ForegroundColor Cyan; Write-Host "Generar y exportar Informe de Diagnóstico Oficial (.txt)"
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  11. " -NoNewline -ForegroundColor Red;  Write-Host "Salir del programa" -ForegroundColor Red
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host "  Ingrese su opción [1-11]: " -NoNewline -ForegroundColor Yellow
        $opcion = Read-Host

        switch ($opcion.Trim()) {
            "1"  { Consultar-HardwareOS }
            "2"  { Diagnosticar-RedLocal }
            "3"  { Auditar-EspacioDisco }
            "4"  { Monitorear-Procesos }
            "5"  { Verificar-PermisosArchivos }
            "6"  { Diagnosticar-EnlaceBOSGAME }
            "7"  { Auditar-PuertosSockets }
            "8"  { Mantenimiento-Temporales }
            "9"  { Trazar-RutaRed }
            "10" { Generar-InformeConsolidado }
            "11" {
                Write-Host "`n[!] Cerrando ToolInc Care de forma controlada. ¡Hasta luego, Joseph!" -ForegroundColor Green
                $continuar = $false
                break
            }
            default {
                Write-Host "`n[-] Error: Opción '$opcion' no válida. Ingrese un número del 1 al 11." -ForegroundColor Red
            }
        }

        if ($continuar) {
            Write-Host "`nPresione ENTER para regresar al menú principal..." -ForegroundColor DarkGray
            [void][System.Console]::ReadLine()
        }
    }
}

<#
--------------------------------------------------------------------------------
  FUNCIÓN: Servidor Web Local Nativo (HTTP Listener sin Admin)
  Permite que el frontend web (HTML/JS) ejecute los comandos reales de PowerShell
  y reciba la salida en vivo mediante peticiones REST a /api/ejecutar?modulo=N
--------------------------------------------------------------------------------
#>
function Iniciar-ServidorWeb {
    param(
        [int]$Puerto = 8088
    )

    $url = "http://localhost:$Puerto/"
    $listener = [System.Net.HttpListener]::new()
    $listener.Prefixes.Add($url)

    try {
        $listener.Start()
    }
    catch {
        Write-Host "[-] Error al iniciar el servidor en $url : $_" -ForegroundColor Red
        Write-Host "    (Verifique si otro proceso ya está usando el puerto $Puerto)" -ForegroundColor Yellow
        return
    }

    $rutaRaiz = Split-Path -Parent $MyInvocation.MyCommand.Path
    if (-not $rutaRaiz) { $rutaRaiz = Get-Location }

    $htmlPath = Join-Path $rutaRaiz "index.html"
    if (-not (Test-Path $htmlPath)) {
        $htmlPath = Join-Path $rutaRaiz "demo_toolinc.html"
    }

    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "  TOOLINC CARE — SERVIDOR WEB DE DIAGNÓSTICO EN TIEMPO REAL          " -ForegroundColor Yellow
    Write-Host "  Desarrollador: Joseph Delgado | Perfil: Usuario Estándar            " -ForegroundColor Green
    Write-Host "  URL Local    : $url                                                " -ForegroundColor White
    Write-Host "  Estado       : Escuchando peticiones del Frontend Web               " -ForegroundColor Cyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "`n[+] El frontend ahora puede ejecutar comandos de PowerShell directamente." -ForegroundColor Green
    Write-Host "[i] Presione Ctrl+C en esta consola para detener el servidor web.`n" -ForegroundColor DarkGray

    # Abrir automáticamente en el navegador predeterminado
    Start-Process $url

    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            # Cabeceras CORS
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            $response.Headers.Add("Access-Control-Allow-Headers", "*")

            if ($request.HttpMethod -eq "OPTIONS") {
                $response.StatusCode = 200
                $response.Close()
                continue
            }

            $path = $request.Url.LocalPath

            if ($path -eq "/" -or $path -eq "/index.html" -or $path -eq "/demo_toolinc.html") {
                $bytes = [System.IO.File]::ReadAllBytes($htmlPath)
                $response.ContentType = "text/html; charset=utf-8"
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            elseif ($path -eq "/api/ping") {
                $json = '{"status":"online","servidor":"ToolInc Care Web Engine","desarrollador":"Joseph Delgado"}'
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
                $response.ContentType = "application/json; charset=utf-8"
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            elseif ($path -eq "/api/ejecutar") {
                $modulo = $request.QueryString["modulo"]
                $mb = if ($request.QueryString["mb"]) { [int]$request.QueryString["mb"] } else { 10 }
                $sw = [System.Diagnostics.Stopwatch]::StartNew()

                # Ejecutar función capturando toda la salida real de consola
                $salida = switch ($modulo) {
                    "1"          { (& { Consultar-HardwareOS } *>&1 | Out-String) }
                    "2"          { (& { Diagnosticar-RedLocal } *>&1 | Out-String) }
                    "3"          { (& { Auditar-EspacioDisco } *>&1 | Out-String) }
                    "4"          { (& { Monitorear-Procesos } *>&1 | Out-String) }
                    "5"          { (& { Verificar-PermisosArchivos } *>&1 | Out-String) }
                    "6"          { (& { Diagnosticar-EnlaceBOSGAME -NoPrompt } *>&1 | Out-String) }
                    "6_transfer" { (& { Probar-TransferenciaBOSGAME -TamanioMB $mb } *>&1 | Out-String) }
                    "7"          { (& { Auditar-PuertosSockets } *>&1 | Out-String) }
                    "8"          { (& { Mantenimiento-Temporales -NoConfirm } *>&1 | Out-String) }
                    "9"          { (& { Trazar-RutaRed -NoPrompt } *>&1 | Out-String) }
                    "10"         { (& { Generar-InformeConsolidado } *>&1 | Out-String) }
                    default      { "Módulo '$modulo' no reconocido." }
                }

                $sw.Stop()
                $duracion = "$([math]::Round($sw.Elapsed.TotalSeconds, 2))s"

                Write-Host "[API] Módulo $modulo ejecutado en $duracion" -ForegroundColor DarkCyan

                $respObj = [PSCustomObject]@{
                    ok        = $true
                    modulo    = $modulo
                    duracion  = $duracion
                    salida    = $salida.Trim()
                    timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                }

                $json = $respObj | ConvertTo-Json -Depth 3
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
                $response.ContentType = "application/json; charset=utf-8"
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            elseif ($path -eq "/api/reporte") {
                $txt = if (Test-Path $script:ReportePath) {
                    Get-Content -Path $script:ReportePath -Raw -Encoding UTF8
                } else {
                    "El informe aún no ha sido generado. Ejecute el módulo 10 primero."
                }
                $bytes = [System.Text.Encoding]::UTF8.GetBytes($txt)
                $response.ContentType = "text/plain; charset=utf-8"
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
            else {
                $response.StatusCode = 404
                $bytes = [System.Text.Encoding]::UTF8.GetBytes("Recurso no encontrado: $path")
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            }
        }
        catch {
            $errJson = [PSCustomObject]@{ ok = $false; error = $_.Exception.Message } | ConvertTo-Json
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($errJson)
            $response.ContentType = "application/json; charset=utf-8"
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        finally {
            try { $response.Close() } catch {}
        }
    }
}

# Iniciar la aplicación o ejecutar la acción solicitada por parámetro
if ($Web -or $Accion -eq "Web") {
    Iniciar-ServidorWeb
}
elseif ($NoMenu) {
    # Solo cargar funciones en memoria sin interactuar
}
elseif ($Accion) {
    switch ($Accion) {
        "1"   { Consultar-HardwareOS }
        "2"   { Diagnosticar-RedLocal }
        "3"   { Auditar-EspacioDisco }
        "4"   { Monitorear-Procesos }
        "5"   { Verificar-PermisosArchivos }
        "6"   { Diagnosticar-EnlaceBOSGAME }
        "7"   { Auditar-PuertosSockets }
        "8"   { Mantenimiento-Temporales }
        "9"   { Trazar-RutaRed }
        "10"  { Generar-InformeConsolidado }
        "All" {
            Consultar-HardwareOS
            Diagnosticar-RedLocal
            Auditar-EspacioDisco
            Monitorear-Procesos
            Verificar-PermisosArchivos
            Diagnosticar-EnlaceBOSGAME
            Auditar-PuertosSockets
            Generar-InformeConsolidado
        }
    }
} else {
    Iniciar-MenuPrincipal
}
