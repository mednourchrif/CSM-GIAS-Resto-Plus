@echo off
setlocal
cd /d "%~dp0\03_Backend"
if not exist ".venv\Scripts\python.exe" (
  echo Python virtual environment not found. Run deploy_windows.bat first.
  exit /b 1
)
if not exist "..\mobile_app\build\web\index.html" (
  echo Web build not found. Building Flutter Web...
  pushd "..\mobile_app"
  call flutter build web --release --dart-define-from-file=env.local.json
  popd
)
echo ======================================================
echo   CSM-GIAS Resto+ - Web Administration Server
echo ======================================================
echo   Local URL: http://localhost:8088
echo   LAN URL:   http://172.16.3.80:8088
echo ======================================================
".venv\Scripts\python.exe" -m http.server 8088 --bind 0.0.0.0 --directory "..\mobile_app\build\web"
