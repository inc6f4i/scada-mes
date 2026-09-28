$ErrorActionPreference = 'Stop'
$pidFile = Join-Path $PSScriptRoot 'mes.pid'
if (Test-Path $pidFile) {
    $process = Get-Process -Id ([int](Get-Content $pidFile)) -ErrorAction SilentlyContinue
    if ($process -and $process.ProcessName -eq 'python') { Stop-Process -Id $process.Id }
    Remove-Item -LiteralPath $pidFile
}
Write-Output 'MES GUI stopped. MySQL and OPC UA collector keep running.'
