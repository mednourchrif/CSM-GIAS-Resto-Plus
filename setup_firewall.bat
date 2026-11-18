@echo off
setlocal
echo ======================================================
echo   CSM-GIAS Resto+ - Windows Firewall Configuration
echo ======================================================
echo Opening ports 4212 (API) and 8088 (Web Admin)...
netsh advfirewall firewall add rule name="CSM-GIAS Resto+ API (4212)" dir=in action=allow protocol=TCP localport=4212
netsh advfirewall firewall add rule name="CSM-GIAS Resto+ Web Admin (8088)" dir=in action=allow protocol=TCP localport=8088
echo.
echo Firewall rules added successfully.
pause
