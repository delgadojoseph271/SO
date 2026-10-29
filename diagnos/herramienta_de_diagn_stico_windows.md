# Mini Proyecto: Herramienta de Diagnóstico en Ambiente Windows

## 1. Descripción del Proyecto
Los estudiantes desarrollarán una herramienta de administración para Windows. La aplicación ejecutará acciones que permitirán consultar información del sistema, diagnosticar la conexión a la red local y realizar configuraciones básicas y administrativas en un entorno Windows.

* **Estructura:** El programa debe presentar un menú interactivo con **10 acciones**, además de una opción para salir.
* **Modalidad:** Individual.
* **Entorno:** Red LAN del laboratorio, **sin conexión a Internet**.
* **Requisito de red:** La aplicación debe realizar al menos una acción en red que involucre al equipo **BOSGAME**.
  * **IP de BOSGAME:** `192.168.100.10`
  * **Credenciales de acceso a BOSGAME:** 
    * **Usuario:** `FAST`
    * **Contraseña:** `12345`

---

## 2. Objetivo General
Desarrollar una herramienta funcional que integre comandos o acciones de diagnóstico, mantenimiento y configuración en ambiente Windows, aplicando variables, funciones, estructuras de control y permisos de archivos.

---

## 3. Requisitos de Desarrollo
La herramienta deberá cumplir con las siguientes pautas técnicas y funcionales:

- [ ] Mostrar el nombre de la aplicación y el nombre del desarrollador.
- [ ] Generar y mostrar el logotipo de la aplicación (arte ASCII o encabezado visual en consola).
- [ ] Mantener el menú interactivo disponible tras finalizar cada acción.
- [ ] Incluir una opción para salir del programa de forma controlada.
- [ ] Utilizar **una función modular** por cada acción del menú.
- [ ] Incorporar variables, condicionales (`if/else`) y estructuras de repetición (`loops`).
- [ ] Validar las opciones ingresadas y emitir mensajes de error claros al usuario.
- [ ] Documentar el código mediante comentarios que expliquen las secciones principales.
- [ ] Operar sobre archivos y carpetas dentro del directorio personal del usuario (`%USERPROFILE%`).
- [ ] Ejecutarse bajo un perfil de usuario habitual, **sin requerir privilegios de administrador**.
- [ ] **Gestión de permisos:** Emplear un archivo de prueba creado por la misma herramienta para comprobar que:
  - El permiso de lectura permite consultar su contenido.
  - El permiso de escritura determina si es posible modificarlo.

---

## 4. Etapas de Trabajo

1. **Diseño:** Definir el nombre de la herramienta, maquetar el menú interactivo e investigar/identificar los comandos de Windows necesarios para cada acción.
2. **Construcción:** Codificar las funciones y vincularlas a las opciones del menú interactivo.
3. **Validación:** Probar exhaustivamente las 10 acciones, verificar las salidas y corregir posibles fallas.
4. **Documentación:** Redactar una guía rápida de uso y una tabla explicativa con los comandos ejecutados.
5. **Demostración:** Presentar la aplicación en funcionamiento ante el docente y defender una sección asignada del código fuente.

---

## 5. Entregables
Los estudiantes deberán presentar los siguientes productos:

1. **Aplicación funcional:** Código ejecutable de la herramienta (script `.bat`, `.ps1` o ejecutable).
2. **Informe de diagnóstico:** Archivo de texto/log generado automáticamente por el programa.
3. **Guía breve de ejecución:** Instrucciones claras para iniciar y usar la herramienta.
4. **Tabla de comandos:** Listado detallado de comandos de Windows utilizados y su propósito técnico.
5. **Evidencias:** Capturas de pantalla o logs que demuestren la ejecución de las diez acciones y las pruebas de validación.
6. **Conclusión:** Breve reflexión técnica sobre los aprendizajes obtenidos y los problemas solucionados.

---

> **Observación:** Construyan una herramienta útil y aplicable para auditar una computadora del laboratorio. Cada salida debe ser comprensible y cada cambio de configuración debe ser verificable. No basta con que el código corra: el estudiante debe entender con precisión qué realiza cada comando y cómo se comprueba su resultado.