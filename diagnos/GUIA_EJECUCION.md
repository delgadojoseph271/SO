# Guía de Ejecución y Uso — ToolInc Care

**Proyecto:** Herramienta de Diagnóstico en Ambiente Windows  
**Desarrollador:** Joseph Delgado  
**Archivo principal:** `ToolInc.ps1`  

---

## 1. Requisitos Previos

- Sistema Operativo: **Windows 10 o Windows 11**.
- Intérprete: **Windows PowerShell 5.1** (incluido por defecto en Windows) o **PowerShell 7+ (pwsh)**.
- Privilegios: **Usuario estándar habitual** (NO requiere ejecutar como Administrador).
- Red: Conexión física o inalámbrica a la red LAN del laboratorio.

---

## 2. Instrucciones de Ejecución Paso a Paso

### Método 1: Modo Web con Ejecución en Vivo (¡Recomendado!)

Permite interactuar con la interfaz moderna de **ToolInc Care** y **ejecutar los comandos reales directamente desde el navegador**:

1. Haga doble clic en el archivo:
   ```text
   Iniciar_ToolInc_Web.bat
   ```
   *(O ejecute en PowerShell: `powershell.exe -ExecutionPolicy Bypass -File .\ToolInc.ps1 -Web`)*
2. Se iniciará el micro-servidor HTTP nativo en `http://localhost:8088/` y se abrirá automáticamente su navegador web predeterminado (Edge / Chrome).
3. En la esquina superior observará el indicador: **🟢 PowerShell en Vivo Activo**.
4. Al hacer clic en cualquier botón ("Revisar Mi PC", "Escanear Todo", etc.), el comando de PowerShell se ejecutará en tiempo real en su computadora y la salida oficial se mostrará en pantalla y en la consola drawer.

### Método 2: Modo Consola Interactiva (CLI Tradicional)

1. Abra una ventana de PowerShell:
   - Presione `Windows + R`, escriba `powershell` y presione `Enter`.
2. Navegue al directorio del proyecto:
   ```powershell
   cd "$HOME\Desktop\scripts\Practica de la universidad\SO\diagnos"
   ```
3. Ejecute el script:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\ToolInc.ps1
   ```

### Método 3: Ejecución directa de una acción específica
```powershell
powershell.exe -File .\ToolInc.ps1 -Accion 1   # Hardware y SO
powershell.exe -File .\ToolInc.ps1 -Accion 5   # Permisos NTFS
powershell.exe -File .\ToolInc.ps1 -Accion 6   # Enlace BOSGAME
powershell.exe -File .\ToolInc.ps1 -Accion 10  # Generar informe .txt
```

---

## 3. Navegación por el Menú Interactivo

Al iniciar la aplicación, observará el encabezado ASCII oficial y las 11 opciones disponibles:

```text
======================================================================
  TOOLINC CARE — DIAGNÓSTICO AMIGABLE & SALUD DEL SISTEMA            
  Desarrollador: Joseph Delgado | Perfil: Usuario Estándar            
  Entorno: Red de Laboratorio (LAN Offline) | BOSGAME: 192.168.100.10
======================================================================

   1. Consultar información de Hardware y Windows (CPU, RAM, SO)
   2. Diagnosticar conexión a Red Local (IP, Gateway, DNS)
   3. Auditar espacio en Disco C: y carpetas de usuario
   4. Monitorear procesos en ejecución (Top 10 consumo RAM)
   5. Verificar permisos NTFS en archivo de prueba (Lectura/Escritura)
   6. Diagnosticar enlace con Servidor BOSGAME (192.168.100.10: FAST)
   7. Auditar puertos y sockets TCP activos
   8. Mantenimiento y limpieza de archivos temporales
   9. Trazar ruta y latencia de red (Traceroute)
  10. Generar y exportar Informe de Diagnóstico Oficial (.txt)
  ----------------------------------------------------------------
  11. Salir del programa
```

- Ingrese el número de la acción deseada (1 a 11) y presione `Enter`.
- Cada acción mostrará los resultados con colores claros.
- Al terminar la acción, el sistema le pedirá presionar `Enter` para volver al menú principal sin cerrarse.
- Para salir de forma controlada y segura, seleccione la opción **11**.

---

## 4. Archivo de Informe Generado

Al seleccionar la **Opción 10** (o tras realizar auditorías), el programa guarda y consolida automáticamente el informe técnico en:
```text
%USERPROFILE%\ToolInc_Diagnostico_Reporte.txt
```
(Normalmente `C:\Users\<SuUsuario>\ToolInc_Diagnostico_Reporte.txt`).

Este archivo puede abrirse con el Bloc de notas o enviarse al docente como evidencia de la práctica.

---

## 5. Visualización de la Interfaz Web (Mockup / Dashboard)

Si desea mostrar el dashboard gráfico moderno de **ToolInc Care** en cualquier navegador (Edge / Chrome):
1. Haga doble clic en el archivo [demo_toolinc.html](demo_toolinc.html).
2. Verá la interfaz con el anillo de salud del 98%, las tarjetas interactivas de cada módulo y el visor de comandos de PowerShell integrado.

