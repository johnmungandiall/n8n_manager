@echo off
REM Simple localtunnel setup script for n8n HTTPS tunneling
REM Run this in a separate terminal before starting n8n

echo Setting up localtunnel for n8n...
echo.

REM Check if localtunnel is installed
where lt >nul 2>&1
if %errorlevel% neq 0 (
    echo Localtunnel not found. Installing via npm...
    echo.
    npm install -g localtunnel
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install localtunnel
        echo Please make sure Node.js and npm are installed
        pause
        exit /b 1
    )
)

REM Start localtunnel
echo Starting localtunnel on port 8080...
echo.
echo Keep this terminal open while using n8n
echo The HTTPS URL will be displayed below:
echo.
echo NOTE: No authentication required with localtunnel!
echo.

lt --port 8080