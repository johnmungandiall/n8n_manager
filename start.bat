@echo off
setlocal

REM Configuration
set N8N_PORT=8080
set LT_SUBDOMAIN=my-n8n-instance-12433
set "TUNNEL_LOG_FILE=%~dp0tunnel_url.log"

echo =================================================
echo  n8n Starter with Localtunnel
echo =================================================
echo.

REM Step 1: Check for Node.js and npm
echo Checking for Node.js and npm...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Node.js not found. Please install it to continue.
    pause
    exit /b 1
)
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: npm not found. Please ensure Node.js is installed correctly.
    pause
    exit /b 1
)
echo Found Node.js and npm.
echo.

REM Step 2: Start localtunnel in a new window
echo Starting localtunnel for port %N8N_PORT% in a new window...
echo Subdomain: %LT_SUBDOMAIN%
echo.
if exist "%TUNNEL_LOG_FILE%" del "%TUNNEL_LOG_FILE%"
start "localtunnel" cmd /c "npx lt --port %N8N_PORT% --subdomain %LT_SUBDOMAIN% --local-host localhost > "%TUNNEL_LOG_FILE%" 2>&1"

REM Step 3: Wait for the tunnel URL
echo Waiting for localtunnel to establish a connection...
:wait_for_tunnel
timeout /t 5 /nobreak >nul
if not exist "%TUNNEL_LOG_FILE%" goto :wait_for_tunnel
findstr /C:"your url is:" "%TUNNEL_LOG_FILE%" >nul
if %errorlevel% neq 0 (
    echo Still waiting...
    goto :wait_for_tunnel
)

for /f "tokens=4" %%i in ('findstr /C:"your url is:" "%TUNNEL_LOG_FILE%"') do (
    set "WEBHOOK_URL=%%i"
)

if not defined WEBHOOK_URL (
    echo ERROR: Could not retrieve the tunnel URL from the log file.
    echo Please check the localtunnel window for errors.
    pause
    exit /b 1
)

echo =================================================
echo  Tunnel URL Ready!
echo.
echo  %WEBHOOK_URL%
echo.
echo =================================================
echo.

REM Step 4: Set environment variables for n8n
echo Setting n8n environment variables...
set "N8N_USER_FOLDER=%~dp0"
set "WEBHOOK_TUNNEL_URL=%WEBHOOK_URL%"
set "N8N_RUNNERS_ENABLED=true"
echo Webhook URL set to: %WEBHOOK_TUNNEL_URL%
echo n8n data will be stored in: %N8N_USER_FOLDER%
echo.

REM Step 5: Start n8n
echo Starting n8n...
echo Access n8n locally at http://localhost:%N8N_PORT%
echo.
npx n8n start

echo.
echo n8n has stopped.
pause
