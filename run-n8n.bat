@echo off
REM Set environment variables
set N8N_HOST=127.0.0.1
set N8N_PORT=8080
set N8N_RUNNERS_ENABLED=true

echo Starting n8n with HTTPS tunneling via localtunnel...
echo.
echo IMPORTANT: This script will start both n8n and localtunnel.
echo Localtunnel provides HTTPS URL required for webhooks (no auth needed).
echo.

REM Check if localtunnel is installed
where lt >nul 2>&1
if %errorlevel% neq 0 (
    echo Localtunnel not found. Installing via npm...
    echo.
    npm install -g localtunnel
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install localtunnel
        echo Please install manually: npm install -g localtunnel
        pause
        exit /b 1
    )
)

REM Start localtunnel in background
echo Starting localtunnel on port %N8N_PORT%...
start /b cmd /c "lt --port %N8N_PORT% > tunnel.log 2>&1"

REM Wait for tunnel to start
timeout /t 5 /nobreak >nul

REM Try to get the tunnel URL from log
echo Retrieving tunnel URL...
if exist tunnel.log (
    for /f "tokens=*" %%i in ('findstr "https://" tunnel.log') do (
        echo.
        echo ================================
        echo HTTPS Tunnel URL: %%i
        echo ================================
        echo.
        echo Use this URL for webhook endpoints in your n8n workflows
        echo Example: %%i/webhook/your-webhook-id
        echo.
    )
) else (
    echo Could not retrieve tunnel URL. Check tunnel.log for details.
)

echo Starting n8n...
echo Access n8n locally at: http://127.0.0.1:%N8N_PORT%
echo.

REM Start n8n using npx
npx n8n

REM Cleanup: Kill localtunnel when n8n stops
taskkill /f /im node.exe /fi "WINDOWTITLE eq lt*" 2>nul
pause
