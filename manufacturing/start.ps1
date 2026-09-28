$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot
$python = Join-Path $base '../.venv/Scripts/python.exe'
if (-not (Test-Path $python)) { throw 'Run repository setup.cmd first.' }
$pidFile = Join-Path $base 'collector.pid'
if (Test-Path $pidFile) {
    $running = Get-Process -Id ([int](Get-Content $pidFile)) -ErrorAction SilentlyContinue
    if ($running -and $running.ProcessName -eq 'python') { Write-Output 'Collector is running.'; exit }
}
$process = Start-Process -FilePath $python -ArgumentList @('-u', "`"$(Join-Path $base 'collector.py')`"") -WorkingDirectory $base -WindowStyle Hidden -RedirectStandardOutput (Join-Path $base 'collector.stdout.log') -RedirectStandardError (Join-Path $base 'collector.stderr.log') -PassThru
$process.Id | Set-Content $pidFile
