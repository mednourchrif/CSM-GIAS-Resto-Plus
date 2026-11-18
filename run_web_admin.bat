@echo off
setlocal
cd /d "%~dp0"

set "TARGET_DIR=web_dist"
if not exist "%TARGET_DIR%\index.html" (
  if exist "web_dist.zip" (
    echo Decompressing web_dist.zip...
    powershell -NoProfile -Command "Expand-Archive -Path 'web_dist.zip' -DestinationPath 'web_dist' -Force"
  )
)

if not exist "%TARGET_DIR%\index.html" (
  if exist "mobile_app\build\web\index.html" (
    set "TARGET_DIR=mobile_app\build\web"
  ) else (
    echo Web build not found. Attempting to build with Flutter...
    pushd "mobile_app"
    call flutter build web --release --dart-define-from-file=env.local.json
    popd
    set "TARGET_DIR=mobile_app\build\web"
  )
)

if not exist "%TARGET_DIR%\index.html" (
  echo ERROR: Web build could not be found or extracted.
  echo Please make sure web_dist\ or web_dist.zip exists in the project root.
  pause
  exit /b 1
)

set "PYTHON_EXE=03_Backend\.venv\Scripts\python.exe"
if not exist "%PYTHON_EXE%" (
  set "PYTHON_EXE=python"
)

echo ======================================================
echo   CSM-GIAS Resto+ - Web Administration Server
echo ======================================================
echo   Directory: %TARGET_DIR%
echo   Local URL: http://localhost:8088
echo   LAN URL:   http://172.16.3.80:8088
echo ======================================================
"%PYTHON_EXE%" -m http.server 8088 --bind 0.0.0.0 --directory "%TARGET_DIR%"
