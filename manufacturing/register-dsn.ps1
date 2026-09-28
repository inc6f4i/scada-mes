$ErrorActionPreference = 'Stop'
$dsnName = 'opcua-manufacturing'
$driverName = 'MySQL ODBC 5.3 Unicode Driver'
$machineKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)
$driverKey = $machineKey.OpenSubKey("SOFTWARE\ODBC\ODBCINST.INI\$driverName")
if (-not $driverKey) { throw 'The 32-bit MySQL ODBC 5.3 Unicode driver is not installed.' }
$driverPath = $driverKey.GetValue('Driver')
$driverKey.Dispose()
$machineKey.Dispose()
$userKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::CurrentUser, [Microsoft.Win32.RegistryView]::Registry32)
$dsnKey = $null
$sourcesKey = $null
try {
    $dsnKey = $userKey.CreateSubKey("SOFTWARE\ODBC\ODBC.INI\$dsnName")
    $properties = @{
        Driver=$driverPath; SERVER='127.0.0.1'; PORT='3306'; DATABASE='opcua-manufacturing';
        UID='scada_learning'; PWD=''; OPTION='3'; DISABLE_SSL_DEFAULT='1'; SSL_ENFORCE='0';
        Description='Learning project - robot, vision, order and PLC status'
    }
    foreach ($entry in $properties.GetEnumerator()) {
        $dsnKey.SetValue($entry.Key, $entry.Value, [Microsoft.Win32.RegistryValueKind]::String)
    }
    $sourcesKey = $userKey.CreateSubKey('SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources')
    $sourcesKey.SetValue($dsnName, $driverName, [Microsoft.Win32.RegistryValueKind]::String)
    Write-Output "Registered User DSN $dsnName using $driverName (32-bit)."
} finally {
    if ($dsnKey) { $dsnKey.Dispose() }
    if ($sourcesKey) { $sourcesKey.Dispose() }
    $userKey.Dispose()
}
