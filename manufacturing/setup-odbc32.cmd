@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0register-dsn.ps1"
if errorlevel 1 (
    echo ODBC registration failed. See the error above.
    pause
    exit /b 1
)
start "" "%SystemRoot%\SysWOW64\odbcad32.exe"
