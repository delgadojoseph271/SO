@echo off
title ToolInc Care - Servidor Web de Diagnostico Local
chcp 65001 >nul
cd /d "%~dp0"
echo ======================================================================
echo   TOOLINC CARE — INICIANDO SERVIDOR WEB LOCAL
echo   Desarrollador: Joseph Delgado
echo   URL: http://localhost:8088/
echo   (No requiere privilegios de Administrador)
echo ======================================================================
echo.
powershell.exe -ExecutionPolicy Bypass -NoProfile -File ".\ToolInc.ps1" -Web
pause

