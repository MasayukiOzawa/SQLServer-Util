$connectionString = "Data Source=localhost; Integrated Security=true;Database=DemoDB; Column Encryption Setting=enabled";
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
 
$connection.Open()
 
$command = New-Object System.Data.SqlClient.SqlCommand
$command.Connection = $connection
 
$command.CommandType = [System.Data.CommandType]::Text
 
$command.CommandText = "INSERT INTO AlwaysEncrypted VALUES(@Name,@PersonalId,@Age)"
 
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Name",[Data.SQLDBType]::NVarChar, 60))) | Out-Null
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PersonalId",[Data.SQLDBType]::VarChar, 11))) | Out-Null
$command.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Age",[Data.SQLDBType]::Int))) | Out-Null
 
$Command.Parameters[0].Value = "Jim Gray"
$Command.Parameters[1].Value = "111-22-3333"
$Command.Parameters[2].Value = 63
 
$command.ExecuteNonQuery()
$command.ExecuteNonQuery()
