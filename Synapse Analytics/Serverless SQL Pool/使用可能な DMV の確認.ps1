$conString = "Server=xxxxxx.sql.azuresynapse.net;User=xxxx;password=xxxxxx;Database=xxxxxx"
$con = New-Object System.Data.Sqlclient.SqlConnection($conString)

$con.Open()
$cmd = $con.CreateCommand()
$cmd.CommandText = @"
select 'sys.' +  name AS name
from sys.all_objects 
where type = 'V' AND name like 'dm[_]%'
order by 1
"@
$dt = New-Object System.Data.DataTable
$reader = $cmd.ExecuteReader()

$dt.Load($reader)
$dt | %{
    $cmd.CommandText = "SELECT COUNT(*) FROM $($_.name)"
    try{
        [void]$cmd.ExecuteNonQuery()
        Write-Host "SELECT * FROM $($_.name)"
    }catch{
        
    }
}

$con.Dispose()