$ErrorActionPreference = 'Stop'
New-Item -Path (Join-Path $PSScriptRoot 'collector.stop') -ItemType File -Force | Out-Null
$pidFile = Join-Path $PSScriptRoot 'collector.pid'
if (Test-Path $pidFile) {
    $running = Get-Process -Id ([int](Get-Content $pidFile)) -ErrorAction SilentlyContinue
    if ($running -and $running.ProcessName -eq 'python') {
        Wait-Process -Id $running.Id -Timeout 40 -ErrorAction Stop
    }
    Remove-Item -LiteralPath $pidFile
}
Write-Output 'Manufacturing collector stopped. Shared MySQL server stays running.'
