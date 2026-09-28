@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0manufacturing\mes\stop.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0manufacturing\stop.ps1"
pause
