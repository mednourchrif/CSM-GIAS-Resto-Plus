@echo off
setlocal
cd /d "%~dp0\03_Backend"
if not exist ".venv\Scripts\python.exe" (
  echo Backend is not installed. Run deploy_windows.bat first.
  exit /b 1
)
if not exist ".env" (
  echo Missing 03_Backend\.env. Run deploy_windows.bat first.
  exit /b 1
)
echo Starting CSM-GIAS Resto+ API on 0.0.0.0:8000...
".venv\Scripts\python.exe" -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
