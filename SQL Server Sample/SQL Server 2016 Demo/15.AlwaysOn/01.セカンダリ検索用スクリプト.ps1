$ConString = "Server=SQL-2016-LN.alwayson.local;Database=SyncDB01;Integrated Security=True;ApplicationIntent=ReadOnly;pooling=false"
 
Clear-Host
for ($i = 1 ;$i -le 100; $i++){
    $Con = New-Object System.Data.SqlClient.SqlConnection
    $con.ConnectionString = $ConString
    $con.Open()
 
    $command = New-Object System.Data.SqlClient.SqlCommand
    $command.Connection = $con
    $command.CommandText = "SELECT @@SERVERNAME"
    $ret = $command.ExecuteReader() 
    $ret.read()| Out-Null
    "{0} {1} {2}" -f $i.ToString("0#"), (Get-Date).ToString("yyyy/MM/dd hh:mm:ss"), $ret[0]
 
    $con.Close() | Out-Null
    $con.Dispose()
    Start-Sleep -Seconds 2
}
