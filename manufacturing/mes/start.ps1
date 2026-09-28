$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot
$python = Join-Path $base '../../.venv/Scripts/python.exe'
if (-not (Test-Path $python)) { throw 'Run repository setup.cmd first.' }
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $base '../start.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Collector startup failed.' }
$pidFile = Join-Path $base 'mes.pid'
if (Test-Path $pidFile) {
    $running = Get-Process -Id ([int](Get-Content $pidFile)) -ErrorAction SilentlyContinue
    if ($running -and $running.ProcessName -eq 'python') { Write-Output 'MES already running.'; exit }
}
& $python (Join-Path $base 'app.py') --init-db
if ($LASTEXITCODE -ne 0) { throw 'Initialize manufacturing schema first.' }
$process = Start-Process -FilePath $python -ArgumentList @('-u', "`"$(Join-Path $base 'app.py')`"") -WorkingDirectory $base -WindowStyle Hidden -RedirectStandardOutput (Join-Path $base 'server.stdout.log') -RedirectStandardError (Join-Path $base 'server.stderr.log') -PassThru
$process.Id | Set-Content $pidFile
Write-Output 'MES http://127.0.0.1:8765'
