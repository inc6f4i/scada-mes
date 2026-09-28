$ErrorActionPreference = 'Stop'
$connection = New-Object System.Data.Odbc.OdbcConnection
$connection.ConnectionString = 'Driver={MySQL ODBC 5.3 Unicode Driver};Server=127.0.0.1;Port=3306;Database=opcua-manufacturing;Uid=scada_learning;Pwd=;Option=3;DISABLE_SSL_DEFAULT=1;SSL_ENFORCE=0;'
try {
    $connection.Open()
    $metadata = $connection.GetSchema('Tables')
    Write-Output "ODBC table metadata: $($metadata.Rows.Count) entries"
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT CAST(VARIABLE_VALUE AS CHAR CHARACTER SET utf8mb4) COLLATE utf8mb4_unicode_ci FROM performance_schema.session_status WHERE VARIABLE_NAME='Ssl_cipher'"
    $sslReader = $command.ExecuteReader()
    try {
        if ($sslReader.Read()) {
            $cipher = $sslReader.GetString(0)
            if ($cipher) { throw "SSL is active: $cipher" }
            Write-Output 'SSL disabled: session cipher is empty.'
        }
    } finally { $sslReader.Dispose() }
    $command.CommandText = 'SELECT tag_name,value_text,value_number,status_code FROM `team2-robotdb` ORDER BY tag_name'
    $table = New-Object System.Data.DataTable
    $adapter = New-Object System.Data.Odbc.OdbcDataAdapter($command)
    $null = $adapter.Fill($table)
    Write-Output "ODBC 5.3 Unicode: connected, read $($table.Rows.Count) tags"
    $table | Select-Object -First 5 | Format-Table -AutoSize
    $command.CommandText = 'SELECT tag_name,value_text,value_number,status_code FROM `team2-vision` ORDER BY tag_name'
    $vision = New-Object System.Data.DataTable
    $visionAdapter = New-Object System.Data.Odbc.OdbcDataAdapter($command)
    $null = $visionAdapter.Fill($vision)
    Write-Output "ODBC 5.3 Unicode: read $($vision.Rows.Count) vision tags"
    $vision | Select-Object -First 5 | Format-Table -AutoSize
    $command.CommandText = 'SELECT tag_name,value_text,value_number,status_code FROM `team2-order` ORDER BY tag_name'
    $order = New-Object System.Data.DataTable
    $orderAdapter = New-Object System.Data.Odbc.OdbcDataAdapter($command)
    $null = $orderAdapter.Fill($order)
    Write-Output "ODBC 5.3 Unicode: read $($order.Rows.Count) order tags"
    $order | Select-Object -First 5 | Format-Table -AutoSize
    $command.CommandText = 'SELECT tag_name,value_text,value_number,status_code FROM `team2-plcstatus` ORDER BY tag_name'
    $plcstatus = New-Object System.Data.DataTable
    $plcstatusAdapter = New-Object System.Data.Odbc.OdbcDataAdapter($command)
    $null = $plcstatusAdapter.Fill($plcstatus)
    Write-Output "ODBC 5.3 Unicode: read $($plcstatus.Rows.Count) PLC status tags"
    $plcstatus | Format-Table -AutoSize
} finally {
    $connection.Dispose()
}
