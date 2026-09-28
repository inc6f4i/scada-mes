$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Test-Path '.venv/Scripts/python.exe')) {
    & python.exe -m venv .venv
    if ($LASTEXITCODE -ne 0) { throw 'Python virtual environment creation failed.' }
}
& ./.venv/Scripts/python.exe -m pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
$templates = @('manufacturing/config','manufacturing/mysql-client','manufacturing/mes/scada-client','manufacturing/mes/scada-source','manufacturing/mes/web-config')
foreach ($template in $templates) {
    $extension = if ($template -like '*client') { 'ini' } else { 'json' }
    $target = "$template.$extension"
    if (-not (Test-Path $target)) { Copy-Item -LiteralPath "$template.example.$extension" -Destination $target }
}
if (-not (Test-Path 'manufacturing/mes/mode.json')) {
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot 'manufacturing/mes/mode.json'), '{"mode":"TEST"}', [Text.UTF8Encoding]::new($false))
}
Write-Output 'Setup complete. Configure MySQL credentials locally, initialize both schemas, then run start.cmd.'
