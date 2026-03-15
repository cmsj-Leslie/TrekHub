@echo off
echo Starting TrekHub...
echo.
echo [1/2] Starting Backend (port 3000)...
start "TrekHub Backend" cmd /k "cd /d %~dp0backend && npm run dev"
timeout /t 2 /nobreak >nul
echo [2/2] Starting Frontend (port 5173)...
start "TrekHub Frontend" cmd /k "cd /d %~dp0frontend && npm run dev"
echo.
echo Done! Open http://localhost:5173
