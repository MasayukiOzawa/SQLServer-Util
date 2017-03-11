$connectionString = "Data Source=localhost; Integrated Security=true;Database=DemoDB; Column Encryption Setting=enabled";
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
 
$connection.Open()
 
 
$command4 = New-Object System.Data.SqlClient.SqlCommand
$command4.Connection = $connection
 
$command4.CommandType = [System.Data.CommandType]::Text
$command4.CommandText = "SELECT * FROM AlwaysEncrypted WHERE PersonalID = @PersonalID"
 
$command4.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PersonalId",[Data.SQLDBType]::VarChar, 11))) | Out-Null
 
$command4.Parameters[0].Value = "111-22-3333"
 
$reader = $command4.ExecuteReader()
$sb = New-Object System.Text.StringBuilder
while($reader.Read())
{ 
    Write-Output ("{0} {1} {2}" -f $reader[0], $reader[1], $reader[2])
 }
 $reader.Close() 
