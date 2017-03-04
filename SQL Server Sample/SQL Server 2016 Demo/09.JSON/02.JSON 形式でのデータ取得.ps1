$connectionString = "Data Source=localhost; Integrated Security=true;";
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
 
$connection.Open()
 
 
$command = $connectionString = "Data Source=localhost; Integrated Security=true";
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
 
$connection.Open()
 
$command = $connection.CreateCommand()
 
$command.CommandType = [System.Data.CommandType]::Text
$command.CommandText = "SELECT * FROM sys.objects FOR JSON AUTO"
 
$reader = $command.ExecuteReader()
$sb = New-Object System.Text.StringBuilder
while($reader.Read())
{ 
    $sb.Append($reader[0]) | Out-Null
}

$sb.ToString()
$json = ($sb.ToString() | ConvertFrom-Json)
$json | Out-GridView

$command.Dispose()
$connection.Close()
$connection.Dispose()
