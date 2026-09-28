$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$settings = Get-Content manufacturing/config.json -Raw | ConvertFrom-Json
& $settings.mysql_exe "--defaults-file=$PSScriptRoot/manufacturing/mysql-client.ini" --execute="source $($PSScriptRoot.Replace('\','/'))/manufacturing/schema.sql"
if ($LASTEXITCODE -ne 0) { throw 'MySQL database/schema creation failed.' }
& ./.venv/Scripts/python.exe manufacturing/mes/app.py --init-db
if ($LASTEXITCODE -ne 0) { throw 'MES schema initialization failed.' }
