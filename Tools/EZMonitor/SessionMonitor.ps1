Clear-Host
$conStr = ""
$sessionId = 162

$sqlText = @"
SELECT 
    es.session_id,
    es.host_name,
    es.program_name,
    es.client_interface_name,
    er.command,
    er.status AS er_status,
    es.status AS es_status,
    wt.exec_context_id,
    wt.blocking_exec_context_id,
    wt.wait_duration_ms,
    wt.blocking_session_id,
    wt.resource_description,
    wt.wait_type AS wt_wait_type,
    er.wait_type AS er_wait_type,
    er.last_wait_type,
    er.wait_resource,
    er.wait_time,
    er.total_elapsed_time,
    er.cpu_time AS er_cpu_time,
    es.cpu_time AS es_cpu_time,
    er.reads AS er_reads,
    es.reads AS es_reads,
    er.logical_reads AS er_logical_reads,
    es.logical_reads AS es_logical_reads,
    er.writes AS er_writes,
    es.writes AS es_writes,
    ot.task_count,
    ot.context_switches_count,
    ot.pending_io_count,
    ot.pending_io_byte_count,
    object_name(st.objectid, es.database_id) as object_name
FROM 
    sys.dm_exec_sessions AS es
    LEFT JOIN sys.dm_exec_requests AS er
        ON es.session_id = er.session_id
    OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
    LEFT JOIN sys.dm_os_waiting_tasks AS wt
        ON wt.session_id = es.session_id
           AND wt.session_id <> wt.blocking_session_id
    LEFT JOIN
        (SELECT 
            session_id, 
            COUNT(*) AS task_count,
            SUM(context_switches_count) AS context_switches_count, 
            SUM(pending_io_count) AS pending_io_count, 
            SUM(pending_io_byte_count) AS pending_io_byte_count 
        FROM 
            sys.dm_os_tasks 
        GROUP BY 
            session_id) AS ot
        ON ot.session_id = es.session_id
WHERE
    host_name IS NOT NULL AND es.session_id <> @@spid AND es.program_name NOT LIKE '%mpdwsvc%'
--    AND es.session_id = {0};
"@ -f $sessionId

Clear-Host
try{
    $dt = New-Object System.Data.DataTable
    $con = New-Object System.Data.SqlClient.SqlConnection($conStr)
    $con.Open()
    $cmd = $con.CreateCommand()
    $cmd.CommandText = $sqlText
    
    0..[int32]::MaxValue | %{
        $reader = $cmd.ExecuteReader()
        [void]$dt.Clear()
        [void]$dt.Load($reader)
        Write-output $dt.Rows
        $reader.Close()
        $reader.Dispose()
        Start-Sleep -Milliseconds 100
    } | Select-Object * -ExcludeProperty RowError, RowState, Table, ItemArray, HasErrors | Out-GridView -Title "Session Monitor"
<#
      |  %{"{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}`t{7:#,##0}`t{8:#,##0}`t{9:#,##0}`t{10:#,##0}`t{11:#,##0}`t{12:#,##0}`t{13:#,##0}`t{14:#,##0}`t{15:#,##0}`t{16}" `
        -f $_.session_id, $_.command, $_.er_status,$_.es_status, $_.wait_type, $_.last_wait_type, $_.wait_resource, $_.wait_time, $_.total_elapsed_time, $_.cpu_time, $_.er_reads, $_.es_reads, $_.er_logical_reads, $_.es_logical_reads, $_.er_writes, $_.es_writes, $_.object_name}
#>
}catch{
    Write-Host "Catch Exception."
    Write-Host $_
}finally{
    Write-Host "End."
    $con.Close()
    $con.Dispose()
}
