```bat
@echo off
setlocal
title Omni - Iniciador

cd /d "%~dp0"

echo ============================================
echo              INICIANDO OMNI
echo ============================================
echo.

if not exist ".env" (
    echo [ERROR] No se encuentra el archivo .env
    pause
    exit /b 1
)

echo [1/5] Cargando configuracion...

for /f "usebackq tokens=1,* delims==" %%A in (`findstr /b "DATABASE_URL=" ".env"`) do set "DATABASE_URL=%%B"
for /f "usebackq tokens=1,* delims==" %%A in (`findstr /b "OPENAI_API_KEY=" ".env"`) do set "OPENAI_API_KEY=%%B"

if not defined DATABASE_URL (
    echo [ERROR] DATABASE_URL no configurada.
    pause
    exit /b 1
)

if not defined OPENAI_API_KEY (
    echo [ERROR] OPENAI_API_KEY no configurada.
    pause
    exit /b 1
)

echo [OK] Configuracion cargada.
echo.

echo [2/5] Preparando API...

set NODE_ENV=development
set PORT=8080

echo [3/5] Iniciando servidor API...

start "Omni API" cmd /k "cd /d "%~dp0" && set NODE_ENV=development && set PORT=8080 && pnpm.cmd --filter @workspace/api-server run dev"

timeout /t 8 /nobreak >nul

echo [4/5] Iniciando pagina web...

start "Omni Web" cmd /k "cd /d "%~dp0" && set PORT=3000 && set BASE_PATH=/ && pnpm.cmd --filter @workspace/chat-app run dev"

echo Esperando a que arranque la pagina...
timeout /t 12 /nobreak >nul

echo [5/5] Buscando Microsoft Edge...

set "EDGE=%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe"

if not exist "%EDGE%" (
    set "EDGE=%ProgramFiles%\Microsoft\Edge\Application\msedge.exe"
)

if not exist "%EDGE%" (
    set "EDGE=%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe"
)

if exist "%EDGE%" (
    echo [OK] Abriendo Microsoft Edge...
    start "" "%EDGE%" "http://localhost:3000"
) else (
    echo [ERROR] No se encontro Microsoft Edge.
    echo Abriendo navegador predeterminado...
    start "" "http://localhost:3000"
)

echo.
echo ============================================
echo              OMNI INICIADO
echo ============================================
echo.
echo Web: http://localhost:3000
echo API: http://localhost:8080
echo.
echo NO CIERRES LAS VENTANAS DE LOS SERVIDORES.
echo.
pause
```