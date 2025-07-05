@echo off
title n8n Advanced Manager
setlocal enabledelayedexpansion

:: Default settings
set "DEFAULT_SUBDOMAIN=my-n8n-instance"
set "N8N_DATA_FOLDER=%~dp0n8n_data"

:main_menu
cls
echo ==================================================
echo  n8n Advanced Manager
echo ==================================================
echo  Data Folder: %N8N_DATA_FOLDER%
echo.
echo  [ Tunnel Settings ]
echo    1. Start n8n with Fixed Tunnel (Subdomain: %DEFAULT_SUBDOMAIN%)
echo    2. Start n8n with Custom Tunnel
echo.
echo  [ Local n8n ]
echo    3. Start n8n Locally (no tunnel)
echo.
echo  [ Management ]
echo    4. Stop All (n8n and Tunnel)
echo    5. Test Connection
echo    6. Get Active URL
echo.
echo  [ Data Management ]
echo    7. Backup Workflows
echo    8. Restore Workflows
echo    9. View Backups
echo    0. Open n8n Data Folder
echo.
echo  [ DANGER ZONE ]
echo    R. Reset n8n Data (Deletes all data!)
echo.
echo  [ Other ]
echo    E. Exit
echo.
choice /c 1234567890RE /n /m "Enter your choice: "

if errorlevel 12 goto :exit
if errorlevel 11 call :reset_data
if errorlevel 10 call :open_data_folder
if errorlevel 9 call :view_backups
if errorlevel 8 call :restore_workflows
if errorlevel 7 call :backup_workflows
if errorlevel 6 call :get_url
if errorlevel 5 call :test_connection
if errorlevel 4 call :stop_all
if errorlevel 3 call :start_local
if errorlevel 2 call :start_custom_tunnel
if errorlevel 1 call :start_fixed_tunnel

goto :main_menu

:start_fixed_tunnel
call :_start_n8n_and_tunnel %DEFAULT_SUBDOMAIN%
goto :main_menu

:start_custom_tunnel
echo.
set /p "subdomain=Enter custom subdomain (leave blank to cancel): "
if not defined subdomain (
    echo Canceled.
    timeout /t 2 >nul
    goto :main_menu
)
call :_start_n8n_and_tunnel %subdomain%
goto :main_menu

:start_local
echo.
echo --- Starting n8n Locally ---
set N8N_USER_FOLDER=%N8N_DATA_FOLDER%
set N8N_ENCRYPTION_KEY=ClineIsAwesome
start "n8n Local" cmd /c "npx n8n start --tunnel"
echo.
echo n8n is starting in a new window.
timeout /t 3 >nul
goto :main_menu

:_start_n8n_and_tunnel
set "subdomain=%~1"
echo.
echo --- Stopping any existing processes... ---
call :stop_all_silent
echo.
echo --- Starting n8n and Tunnel (Subdomain: %subdomain%) ---
if exist "n8n_output.txt" del "n8n_output.txt"
if exist "tunnel_output.txt" del "tunnel_output.txt"

echo 1. Starting n8n in the background...
set N8N_USER_FOLDER=%N8N_DATA_FOLDER%
set N8N_ENCRYPTION_KEY=ClineIsAwesome
set WEBHOOK_URL=https://%subdomain%.loca.lt/
powershell -Command "Start-Process -WindowStyle Hidden cmd -ArgumentList '/c npx n8n start --tunnel > n8n_output.txt 2>&1'"

echo    Waiting for n8n to initialize...
:wait_n8n
timeout /t 2 /nobreak >nul
netstat -an | findstr ":5678" >nul
if errorlevel 1 goto wait_n8n
echo    n8n is running on http://localhost:5678

echo.
echo 2. Starting Localtunnel in the background...
start "LocalTunnel" /min cmd /c "lt --port 5678 --subdomain %subdomain% > tunnel_output.txt 2>&1"

echo    Waiting for tunnel to establish...
timeout /t 5 /nobreak >nul

echo.
echo 3. Verifying tunnel connection...
set "tunnel_url=https://%subdomain%.loca.lt"
curl -s -I %tunnel_url% | findstr "200 OK" >nul
if errorlevel 1 (
    echo    [!] Tunnel might still be starting... Retrying in 5s...
    timeout /t 5 /nobreak >nul
    curl -s -I %tunnel_url% | findstr "200 OK" >nul
    if errorlevel 1 (
        echo    [X] Tunnel connection failed. Check tunnel_output.txt for details.
    ) else (
        echo    [V] Tunnel is active!
    )
) else (
    echo    [V] Tunnel is active!
)
echo.
echo ==================================================
echo  SUCCESS! n8n is accessible via:
echo    - Public URL: %tunnel_url%
echo    - Local URL:  http://localhost:5678
echo ==================================================
echo.
echo --- Opening tunnel URL in browser... ---
echo If a password is required, it will be displayed on the page.
start "" "%tunnel_url%"
echo.
echo.
echo.
echo ==================================================
echo  ACTION REQUIRED: Enter Your IP as the Password
echo ==================================================
echo The tunnel password is your public IP address.
echo.
echo A new browser tab will now open to show you your IP.
echo Please copy the IP address from that page and paste
echo it into the "Tunnel Password" box.
echo ==================================================
echo.
echo --- Performance Note ---
echo If n8n is running slow, it may be due to system resource
echo limitations (CPU/RAM) or network latency.
echo Consider closing other applications to free up resources.
echo ==================================================
echo.
start "" "https://ifconfig.me"
pause
goto :eof

:stop_all
echo.
echo --- Stopping All n8n and Tunnel Processes ---
call :stop_all_silent
echo All processes have been stopped.
echo.
pause
goto :main_menu

:stop_all_silent
taskkill /F /IM node.exe /T >nul 2>&1
taskkill /F /IM lt.exe /T >nul 2>&1
goto :eof

:test_connection
echo.
echo --- Testing n8n and Tunnel Connection ---
netstat -an | findstr ":5678" >nul
if errorlevel 1 (
    echo [X] n8n is NOT RUNNING locally on port 5678.
) else (
    echo [V] n8n is RUNNING locally on port 5678.
)
echo.
echo --- Checking for active tunnel URL... ---
if exist "tunnel_output.txt" (
    for /f "tokens=4" %%a in ('findstr /i "your url is:" tunnel_output.txt') do (
        set "tunnel_url=%%a"
    )
)
if defined tunnel_url (
    echo    Found potential URL in tunnel_output.txt: !tunnel_url!
    curl -s -I !tunnel_url! | findstr "200 OK" >nul
    if not errorlevel 1 (
        echo [V] SUCCESS: Tunnel is active at !tunnel_url!
        start "" "!tunnel_url!"
    ) else (
        echo [X] FAILURE: Tunnel at !tunnel_url! is not responding.
    )
) else (
    echo [!] No dynamic URL found in tunnel_output.txt.
    echo     Checking for fixed subdomain URL...
    set "fixed_tunnel_url=https://%DEFAULT_SUBDOMAIN%.loca.lt"
    curl -s -I %fixed_tunnel_url% | findstr "200 OK" >nul
    if not errorlevel 1 (
        echo [V] SUCCESS: Fixed tunnel is active at %fixed_tunnel_url%
        start "" "%fixed_tunnel_url%"
    ) else (
        echo [X] FAILURE: Fixed tunnel at %fixed_tunnel_url% is not responding.
    )
)
echo.
pause
goto :main_menu

:get_url
echo.
echo --- Getting Active URL ---
if exist "tunnel_output.txt" (
    for /f "tokens=4" %%a in ('findstr /i "your url is:" tunnel_output.txt') do (
        set "tunnel_url=%%a"
    )
)
if defined tunnel_url (
    echo Active Tunnel URL: !tunnel_url!
) else (
    echo No active dynamic tunnel URL found.
    echo Default Fixed URL is: https://%DEFAULT_SUBDOMAIN%.loca.lt
)
echo.
pause
goto :main_menu

:backup_workflows
echo.
echo --- Backing up Workflows ---
set "BACKUP_DIR=%~dp0backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set "TIMESTAMP=%mydate%_%mytime%"
set "WORKFLOW_DIR=%BACKUP_DIR%\workflows-%TIMESTAMP%"

if not exist "%N8N_DATA_FOLDER%\database.sqlite" (
    echo [X] n8n database not found. Make sure n8n has been initialized.
    pause
    goto :main_menu
)

mkdir "%WORKFLOW_DIR%"
echo Exporting all workflows to %WORKFLOW_DIR%...
npx n8n export:workflow --backup --output="%WORKFLOW_DIR%"
if errorlevel 1 (
    echo [X] Failed to export workflows.
) else (
    echo [V] Workflow backup complete!
)
echo.
pause
goto :main_menu

:restore_workflows
echo.
echo --- Restoring Workflows ---
set "BACKUP_DIR=%~dp0backups"
if not exist "%BACKUP_DIR%" (
    echo [X] No backup directory found.
    pause
    goto :main_menu
)
start "Restore Workflows" cmd /c "explorer.exe %BACKUP_DIR%"
echo.
echo The backup folder has been opened in Windows Explorer.
echo.
echo To restore, drag and drop the desired workflow JSON files
echo directly into the n8n UI in your browser.
echo.
pause
goto :main_menu

:view_backups
echo.
echo --- Viewing Backups ---
set "BACKUP_DIR=%~dp0backups"
if not exist "%BACKUP_DIR%" (
    echo [X] No backup directory found.
) else (
    start "Backups" cmd /c "explorer.exe %BACKUP_DIR%"
    echo The backup folder has been opened in Windows Explorer.
)
echo.
pause
goto :main_menu

:open_data_folder
echo.
echo --- Opening n8n Data Folder ---
if not exist "%N8N_DATA_FOLDER%" (
    echo [X] Data folder not found.
) else (
    start "n8n Data" cmd /c "explorer.exe %N8N_DATA_FOLDER%"
)
echo.
pause
goto :main_menu

:reset_data
echo.
echo ================================================================
echo  [!] WARNING: THIS WILL DELETE ALL YOUR N8N DATA!
echo      This action is irreversible and cannot be undone.
echo ================================================================
echo.
choice /c yn /m "Are you absolutely sure you want to proceed? (y/n): "
if errorlevel 2 (
    echo.
    echo Operation cancelled.
    timeout /t 2 >nul
    goto :main_menu
)
echo.
echo --- Stopping all processes before deletion... ---
call :stop_all_silent
echo.
echo --- Deleting n8n data folder... ---
if exist "%N8N_DATA_FOLDER%" (
    rmdir /s /q "%N8N_DATA_FOLDER%"
    if exist "%N8N_DATA_FOLDER%" (
        echo [X] ERROR: Failed to delete the data directory.
        echo     Please close any applications that might be using it and try again.
    ) else (
        echo [V] SUCCESS: All n8n data has been permanently deleted.
    )
) else (
    echo [!] Data folder not found. Nothing to delete.
)
echo.
pause
goto :main_menu


:exit
exit /b
