$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run enable-remote.cmd as Administrator on the MES PC.'
}
$ruleName = 'Team2MES-8765-10.10.24.170'
$existing = Get-NetFirewallRule -Name $ruleName -ErrorAction SilentlyContinue
if ($existing) {
    Write-Output 'The MES firewall rule already exists.'
} else {
    New-NetFirewallRule -Name $ruleName -DisplayName 'TEAM2 MES from 10.10.24.170' -Direction Inbound -Action Allow -Protocol TCP -LocalAddress 10.10.24.174 -LocalPort 8765 -RemoteAddress 10.10.24.170 -Profile Any | Out-Null
    Write-Output 'MES TCP 8765 allowed from 10.10.24.170.'
}
