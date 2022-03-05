$ErrorActionPreference = "Stop"

$sourceConnectionstring = "Server=localhost;Integrated security=true;Application Name=DataCopy;Database=tpch"
$destinationConnectionstring = "Server=localhost;Integrated security=true;Application Name=DataCopy;;Database=tpch2"

$tableName = "LINEITEM"
$targetTableStatsQuery = "DBCC SHOW_STATISTICS('LINEITEM', 'PK_LINEITEM') WITH HISTOGRAM;"
$query1 = "SELECT * FROM LINEITEM WHERE L_ORDERKEY < {0} ORDER BY L_ORDERKEY ASC, L_LINENUMBER ASC"
$query2 = "SELECT * FROM LINEITEM WHERE L_ORDERKEY >= {0} AND L_ORDERKEY < {1} ORDER BY L_ORDERKEY ASC, L_LINENUMBER ASC"
$query3 = "SELECT * FROM LINEITEM WHERE L_ORDERKEY >= {0} ORDER BY L_ORDERKEY ASC, L_LINENUMBER ASC"
 
<#
select *  from sys.dm_exec_sessions where program_name = 'DataCopy' order by login_time asc
select 
FORMAT(row_count, '#,##0') AS rows, 
FORMAT(reserved_page_count * 8 / 1024, '#,##0') AS reserved_page_MB,
FORMAT(used_page_count * 8 / 1024, '#,##0') AS used_page_count
from sys.dm_db_partition_stats where object_id = OBJECT_ID('LINEITEM')
 
select * from sys.dm_exec_query_profiles  AS p
outer apply sys.dm_exec_input_buffer(p.session_id, 1) 
where p.session_id in(
    select session_id from sys.dm_exec_sessions where program_name = 'DataCopy'
)
#>
 
 
Add-type -Path "C:\SqlClient\microsoft.identity.client.4.21.1.nupkg\lib\net461\Microsoft.Identity.Client.dll"
Add-Type -Path "C:\SqlClient\microsoft.data.sqlclient.2.1.2.nupkg\runtimes\win\lib\net46\Microsoft.Data.SqlClient.dll"
 
function CopyData($sourceConnection, $destinationConnection, $query){
    while($true){
        try{
            if($sourceConnection.State -ne "Open"){
                $sourceConnection.Open()
            }

            if($destinationConnection.State -ne "Open"){
                $destinationConnection.Open()
            }

            $option = [System.Data.SqlClient.SqlBulkCopyOptions]::1 -bor [System.Data.SqlClient.SqlBulkCopyOptions]::KeepNulls -bor [System.Data.SqlClient.SqlBulkCopyOptions]::TableLock -bor [System.Data.SqlClient.SqlBulkCopyOptions]::UseInternalTransaction
            $sqlBulk = New-Object Microsoft.Data.SqlClient.SqlBulkCopy($destinationConnection, $option, $null)
 
            [Microsoft.Data.SqlClient.SqlCommand]$sourceDataCommand = $sourceConnection.CreateCommand()
            $sourceDataCommand.CommandText = $query
            $sourceDataCommand.CommandTimeOut = 0
            $r = $sourceDataCommand.ExecuteReader()
     
            $sqlBulk.DestinationTableName = $tableName
            $sqlBulk.BulkCopyTimeout = 0
            $sqlBulk.BatchSize = 0
 
            [void]$sqlBulk.ColumnOrderHints.Add((New-Object Microsoft.Data.SqlClient.SqlBulkCopyColumnOrderHint("L_ORDERKEY", ([Microsoft.Data.SqlClient.SortOrder]::Ascending))))
            [void]$sqlBulk.ColumnOrderHints.Add((New-Object Microsoft.Data.SqlClient.SqlBulkCopyColumnOrderHint("L_LINENUMBER", ([Microsoft.Data.SqlClient.SortOrder]::Ascending))))
 
            $sqlBulk.WriteToServer($r)

            break
        }catch{
                Write-Host ("Error (Loop Retry) : {0}" -f $Error[0].Exception.Message)
                Start-Sleep -Seconds (1 * (Get-Random -Minimum 1 -Maximum 10))
        }finally{
            $r.Dispose()
        }
    }
 
}
 
$sourceConnection = New-Object Microsoft.Data.SqlClient.SqlConnection($sourceConnectionstring)
$destinationConnection = New-Object Microsoft.Data.SqlClient.SqlConnection($DestinationConnectionstring)
 
$sourceConnection.Open()
$destinationConnection.Open()
 
$sourceStatsCommand = $sourceConnection.CreateCommand()
$sourceStatsCommand.CommandText = $targetTableStatsQuery
 
$r = $sourceStatsCommand.ExecuteReader()
 
$dtStats = New-Object System.Data.DataTable
$dtStats.Load($r)
$r.Close()
$r.Dispose()
 
$dtStats | ft
 
$count = 1
 
foreach($statsRow in $dtStats.Rows){
    if($count -eq 1){
        $query = $query1 -f $statsRow["RANGE_HI_key"]
    }else{        
        $query = $query2 -f $lowKey,$statsRow["RANGE_HI_key"] 
    }
    Write-Host ("[{0:000}/{1:000}] : Start : {2}" -f $count, $dtStats.Rows.Count, $query)
 
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    CopyData $sourceConnection $destinationConnection $query
    $sw.Stop()
 
    Write-Host ("[{0:000}/{1:000}] : End : {2:#,##0} ms" -f $count,  $dtStats.Rows.Count, $sw.ElapsedMilliseconds)
 
 
    $lowKey = $statsRow["RANGE_HI_key"]        
 
    if($count -eq $dtStats.Rows.Count){
        $query = $query3 -f $statsRow["RANGE_HI_key"] 
 
        Write-Host ("[{0:000}/{1:000}] : Start : {2}" -f $count, $dtStats.Rows.Count, $query)
 
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        CopyData $sourceConnection $destinationConnection $query
        $sw.Stop()
 
        Write-Host ("[{0:000}/{1:000}] : End : {2:#,##0} ms" -f $count,  $dtStats.Rows.Count, $sw.ElapsedMilliseconds)
    }
    $count++
 
}
 
$sourceConnection.Close()
$sourceConnection.Dispose()
 
$destinationConnection.Close()
$destinationConnection.Dispose()