# Tabla de Comandos y Fundamentos Técnicos — ToolInc Care

**Proyecto:** Herramienta de Diagnóstico en Ambiente Windows  
**Desarrollador:** Joseph Delgado  
**Curso:** Sistemas Operativos  
**Entorno:** Red LAN de Laboratorio (Offline) & Servidor BOSGAME (`192.168.100.10`)  

---

## 1. Matriz de Comandos por Módulo

| N° | Módulo / Acción | Comando(s) de Windows / PowerShell | Propósito Técnico y Justificación | ¿Requiere Admin? |
|---|---|---|---|---|
| **1** | **Hardware y SO** | `Get-CimInstance Win32_Processor`<br>`Get-CimInstance Win32_OperatingSystem` | Consulta el modelo del microprocesador, núcleos físicos/lógicos y la distribución de memoria RAM física total vs. libre mediante la interfaz WMI/CIM nativa. | No |
| **2** | **Red Local LAN** | `Get-NetIPConfiguration`<br>`Test-Connection -ComputerName <GW> -Count 1` | Obtiene la configuración de red IP de los adaptadores activos (IPv4, máscara, Gateway por defecto y servidores DNS) y valida el enlace con la puerta de enlace mediante paquetes ICMP. | No |
| **3** | **Espacio en Disco** | `Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"`<br>`Get-ChildItem $env:USERPROFILE -Recurse \| Measure-Object` | Audita las particiones lógicas fijas (C:\), calculando espacio total, usado y libre, además de cuantificar el consumo de almacenamiento en carpetas del usuario (Documentos, Descargas, Escritorio). | No |
| **4** | **Monitor de Procesos** | `Get-Process \| Sort-Object WorkingSet64 -Descending \| Select -First 10` | Captura los procesos en tiempo de ejecución, ordenándolos por su memoria de trabajo activa (`WorkingSet64`) para identificar aplicaciones que saturan la RAM. | No |
| **5** | **Permisos de Archivo** | `Set-Content`<br>`Get-Content`<br>`Add-Content`<br>`Set-ItemProperty -Name IsReadOnly -Value $true` | Gestiona un archivo de prueba en `$env:USERPROFILE` para comprobar que la cuenta de usuario puede leer, escribir y que el sistema respeta el bloqueo de modificación cuando se activa el atributo de solo lectura. | No |
| **6** | **Enlace BOSGAME y Transferencia** | `Test-Connection 192.168.100.10`<br>`Test-NetConnection -Port 445`<br>`net use \\192.168.100.10\IPC$ /user:FAST 12345`<br>`[System.IO.File]::Create().SetLength()`<br>`Measure-Command { Copy-Item }` | Diagnóstico hacia el servidor central: comprueba conectividad ICMP, apertura del puerto SMB (445), autentica con credenciales `FAST:12345` y ejecuta prueba de velocidad LAN generando un archivo con peso configurable (5, 10, 25, 50 MB) con `.SetLength()` sin requerir administrador. | No |
| **7** | **Puertos y Sockets** | `Get-NetTCPConnection -State Listen, Established` | Inspecciona el subsistema de red local para enumerar qué puertos TCP se encuentran escuchando conexiones y cuántas sesiones activas están establecidas. | No |
| **8** | **Mantenimiento Temp** | `Get-ChildItem $env:TEMP -File -Recurse`<br>`Remove-Item -Force` | Audita y depura de forma segura archivos temporales generados por aplicaciones dentro del directorio personal del usuario (`%TEMP%`), recuperando espacio en disco sin tocar áreas protegidas. | No |
| **9** | **Traceroute de Red** | `Test-NetConnection -ComputerName <IP> -TraceRoute` | Mapea la ruta de paquetes capa 3 a través de los conmutadores y enrutadores del laboratorio, indicando saltos y estado del viaje de los paquetes hasta el destino. | No |
| **10** | **Informe Consolidado** | `Add-Content -Path $ReportePath -Encoding UTF8` | Agrega los resultados diagnósticos de cada auditoría en un archivo plano estructurado (`ToolInc_Diagnostico_Reporte.txt`) para su entrega y revisión docente. | No |

---

## 2. Aspectos Técnicos Destacados para la Defensa

1. **Cumplimiento estricto de privilegios:** Todos los comandos seleccionados operan con seguridad bajo una cuenta estándar de Windows, protegiendo la integridad del sistema operativo.
2. **Compatibilidad nativa:** No se requieren librerías de terceros (`npm`, `pip`, etc.); todo corre sobre PowerShell 5.1/7+ nativo de Windows.
3. **Manejo de errores:** Cada acción está protegida con bloques `try/catch` para evitar caídas si un recurso de red o archivo está momentáneamente inaccesible.

