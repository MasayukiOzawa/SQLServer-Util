<#
# スクリプトを汎用アプリケーションに登録
$AGName = "AG-01"
Add-ClusterResource -Name "AGMonitor" -Group $AGName -ResourceType "Generic Application" 
$Resource = Get-ClusterResource -Name "AGMonitor"
$Resource | Set-ClusterParameter -Multiple @{CommandLine = "powershell.exe -Command ""C:\Scripts\AGMonitor.ps1""";CurrentDirectory="C:\Scripts"}
$Resource | Set-ClusterResourceDependency -Dependency "([$AGName])"
$Resource | Start-ClusterResource
#>

$QueryTimeout = 30
$WaitTime = 5

Import-Module SQLPS -DisableNameChecking
$sql = @"
SELECT 
	ag.name,
	ar.replica_server_name,
	drs.is_primary_replica,
	ags.primary_replica,
	DB_NAME(drs.database_id) AS database_name,
	drs.database_state_desc,
	ags.secondary_recovery_health_desc,
	ags.synchronization_health_desc,
	drs.synchronization_state_desc,
	drs.last_commit_time,
	drs.last_redone_time,
	drs.last_sent_time,
	drs.last_received_time,
	drs.last_hardened_time
FROM 
	sys.dm_hadr_availability_group_states ags
	LEFT JOIN
	sys.availability_groups ag
	ON
	ags.group_id = ag.group_id
	LEFT JOIN
	sys.dm_hadr_database_replica_states drs
	ON
	drs.group_id = ag.group_id
	LEFT JOIN
	sys.availability_replicas ar
	ON 
	ar.replica_id = drs.replica_id
WHERE
	replica_server_name = @@SERVERNAME
    {0}
OPTION (RECOMPILE)
"@

While ($true){
    # セカンダリとなっている AG を取得
    $SecondaryAGs = Invoke-Sqlcmd -ServerInstance . -Database master -Query ($sql -f "AND is_primary_replica = 0") -QueryTimeout $QueryTimeout

    foreach ($AG in $SecondaryAGs){
        $AGState = Invoke-Sqlcmd -ServerInstance . -Database master -Query ($sql -f "AND ag.name = '$($AG.name)'") -QueryTimeout $QueryTimeout

        # フェールオーバー対象の AG が同期済みの状態でない場合は、フェールオーバーを待機
        while($AGState.synchronization_state_desc -ne "SYNCHRONIZED"){
            Write-Host ("AG:[{0}] Sync Status:{1}.Sync Wait... " -f $AG.name, $agstate.synchronization_state_desc)
            Start-Sleep -Seconds $WaitTime
            $AGState = Invoke-Sqlcmd -ServerInstance . -Database master -Query ($sql -f "AND ag.name = '$($AG.name)'") -QueryTimeout $QueryTimeout
        }
        Write-Host ("AG:[{0}] Failover Start" -f $AG.name)
        Invoke-Sqlcmd -ServerInstance . -Database master -Query "ALTER AVAILABILITY GROUP [$($AG.Name)] FAILOVER" -QueryTimeout 0
        Write-Host ("AG:[{0}] Failover End" -f $AG.name)
    }
    Write-Host "Waiting..."
    Start-Sleep -Seconds $WaitTime
}