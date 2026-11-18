@echo off
setlocal
cd /d "%~dp0"

echo ======================================================
echo   CSM-GIAS Resto+ - Automatic VM Setup
echo ======================================================

echo [1/4] Configuring Windows Firewall...
netsh advfirewall firewall add rule name="CSM-GIAS Resto+ API (4212)" dir=in action=allow protocol=TCP localport=4212 >nul 2>&1
netsh advfirewall firewall add rule name="CSM-GIAS Resto+ Web Admin (8088)" dir=in action=allow protocol=TCP localport=8088 >nul 2>&1

echo [2/4] Setting up environment configuration...
cd 03_Backend
if not exist ".env" (
  if exist ".env.production" (
    copy /Y ".env.production" ".env" >nul
    echo Copied .env.production to .env
  )
)

echo [3/4] Initializing Python virtual environment...
if not exist ".venv\Scripts\python.exe" (
  python -m venv .venv
)
".venv\Scripts\python.exe" -m pip install --upgrade pip --quiet
".venv\Scripts\python.exe" -m pip install -r requirements.txt --quiet

echo [4/4] Applying database migrations and seed data...
".venv\Scripts\python.exe" -m alembic upgrade head
".venv\Scripts\python.exe" scripts\seed.py

cd ..
echo ======================================================
echo   Setup completed successfully!
echo ======================================================
echo To start the services, run:
echo   1. run_backend.bat
echo   2. run_web_admin.bat
echo ======================================================
pause
