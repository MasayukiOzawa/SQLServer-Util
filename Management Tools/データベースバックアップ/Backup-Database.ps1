<#
.SYNOPSIS
SQL Server Backup Database / Log Script

.DESCRIPTION
SQL Server のデータベース / トランザクションログのバックアップを取得します。
開発環境 : 
Windows Server 2016 + Windows PowerShell (5.1)
Ubuntu 16.04 + PowerShell Core  (6.1.0-preview.2)

.EXAMPLE
./Backup-Database.ps1 -ServerInstance <SQL Server 名> -Username <SQL Login> -P <Login Password> -RunSpaceSize 5

.LINK
- PowerShell による同期処理、非同期処理、並列処理 を考えてみる 
http://tech.guitarrapc.com/entry/2013/10/29/100946

- RunspacePoolを使って、PowerShellを非同期実行
https://www.gmo.jp/report/single/?art_id=195

- Weekend Scripter: Max Out PowerShell in a Little Bit of Time—Part 2
https://blogs.technet.microsoft.com/heyscriptingguy/2013/09/29/weekend-scripter-max-out-powershell-in-a-little-bit-of-timepart-2/

- Beginning Use of PowerShell Runspaces: Part 1
https://blogs.technet.microsoft.com/heyscriptingguy/2015/11/26/beginning-use-of-powershell-runspaces-part-1/
#>

[CmdletBinding()]
Param(
    [int]$CommandTimeout = 600,
    [int]$ConnectionTimeout = 15,
    [int]$RunspaceSize = 2,
    [Parameter(Mandatory=$True)]
    [string]$ServerInstance,
    [Parameter(Mandatory=$True)]
    [string]$Username,
    [Parameter(Mandatory=$True)]
    [string]$Password,
    [string]$BackupPath = ".",
    [switch]$Log
)


##### Function definition ####
function Out-Message([string]$Msg){
    Write-Host ("[{0}] $Msg" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss.fff"),  $Msg)
}
############################

$ErrorActionPreference = "Stop"

$success = 0
$failed = 0

$TargetDatabaseQuery = @"
USE [master];
SET NOCOUNT ON;
SELECT
	name,
	create_date,
	recovery_model,
	recovery_model_desc,
	D AS full_backup_finish_date,
	I AS diff_backup_finish_date,
	L AS log_backup_finish_date
FROM
(
SELECT
	d.database_id,
	d.name,
	d.create_date,
	d.recovery_model,
	d.recovery_model_desc,
	backup_tbl.type,
	backup_tbl.backup_finish_date
FROM 
	sys.databases AS d
	LEFT JOIN
	(SELECT 
		database_name, 
		type, 
		MAX(backup_finish_date) AS backup_finish_date
		FROM
		msdb.dbo.backupset 
		GROUP BY 
		database_name, 
		type
	) AS backup_tbl
	ON
		d.name = backup_tbl.database_name
) AS T
PIVOT
(
	MAX(backup_finish_date)
	FOR type IN(D, I, L)
)AS PVT
ORDER BY 
	database_id ASC
"@
Out-Message -Msg ("=" * 20)
Out-Message "Script Settings:"
Out-Message ("Connection Timeout:[{0}] / Command Timeout:[{1}] / Runspace Size:[{2}]" -f $ConnectionTimeout, $CommandTimeout, $RunspaceSize)
Out-Message -Msg ("=" * 20)
Out-Message "Backup $(if($Log){"Log "}else{"Database "})start."

$sw = [system.diagnostics.stopwatch]::startNew()

$constring = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
$constring.psbase.DataSource = $ServerInstance
$constring.psbase.InitialCatalog = "master"
$constring.psbase.UserID = $Username
$constring.psbase.Password = $Password
$constring.psbase.ConnectTimeout = $ConnectionTimeout

$con = New-Object System.Data.SqlClient.SqlConnection

$con.ConnectionString = $constring

$con.Open()

$cmd = $con.CreateCommand()
$cmd.CommandText = $TargetDatabaseQuery


$da = New-Object System.Data.SqlClient.SqlDataAdapter
$da.SelectCommand = $cmd

$ds = New-Object System.Data.DataSet

[void]$da.Fill($ds)

$con.Close()
$con.Dispose()

try{
    $minpoolsize = $maxpoolsize = $RunspaceSize
    $runspacePool = [runspacefactory]::CreateRunspacePool($minPoolSize, $maxPoolSize)
    # Linux の PowerShell Core では、ApartmentState の設定ができなかったため、Windows PowerShell を対象に STA 設定
    if($PSVersionTable.PSEdition -eq "Desktop"){
        $runspacePool.ApartmentState = "STA"
    }
    $runspacePool.Open()

    $Command = {
        Param(
            [string]$constring,
            [string]$dbname,
            [string]$backupsql,
            [int]$CommandTimeout
        )
        try{
            $orgErrorActionPreference = $ErrorActionPreference
            $ErrorActionPreference = "SilentlyContinue"
            $con = New-Object System.Data.SqlClient.SqlConnection
            $con.ConnectionString = $constring

            $con.Open()
            $cmd = $con.CreateCommand()
            $cmd.CommandTimeout = $CommandTimeout

            $cmd.CommandText = $backupsql
            
            [void]$cmd.ExecuteNonQuery()
            
            $cmd.Dispose()

            Write-Output ("Backup Success [{0}] " -f $dbname)
        }catch{
            return $Error[0]
        }finally{
            if($con -ne $null){
                $con.Close()
                $con.Dispose()
            }
            $ErrorActionPreference = $orgErrorActionPreference
        }
    }
    $RunspaceCollection  = New-Object System.Collections.ArrayList
    $Result = New-Object System.Collections.ArrayList

    foreach ($row in $ds.Tables[0].Rows){
        # tempdb はバックアップが取得できないため処理対象外とする
        if ($row["name"] -notcontains ("tempdb")){
            # Transaction Log Backup
            if ($Log){
                $backupfile = Join-Path -Path $BackupPath -ChildPath (($row["name"] + "_" + (Get-Date).ToString("yyyyMMdd")) + ".trn")
                $backupfile = $backupfile -replace "\\" , "/"
                $backupsql = "BACKUP LOG {0} TO DISK=N'{1}' WITH COMPRESSION, STATS=5" -f $row["name"], $backupfile
            # Database Full Backup
            }else{
                $backupfile = Join-Path -Path $BackupPath -ChildPath (($row["name"] + "_" + (Get-Date).ToString("yyyyMMdd")) + ".bak")
                $backupfile = $backupfile -replace "\\" , "/"
                $backupsql = "BACKUP DATABASE {0} TO DISK=N'{1}' WITH COMPRESSION, STATS=5" -f $row["name"], $backupfile
            }

            # 単純復旧 / 初回完全バックアップが取得されていない場合、ログバックアップはスキップ
            if (!(($row.recovery_model -eq 3 -or [String]::IsNullOrEmpty($row.full_backup_finish_date)) -and $Log)){
                $powershell = [PowerShell]::Create().AddScript($Command).AddArgument($constring.ConnectionString).AddArgument($row["name"]).AddArgument($backupsql).AddArgument($CommandTimeout)
                $powershell.RunspacePool = $runspacePool
                Out-Message -Msg ("Available Runspaces in RunspacePool: [{0}]" -f $RunspacePool.GetAvailableRunspaces())
                [void]$RunspaceCollection.Add([PSCustomObject] @{
                    Runspace = $powershell.BeginInvoke();
                    PowerShell = $powershell
                    DBName = $row["name"]
                    BackupFile = $backupfile
                    StartTime = Get-Date
                })
                Out-Message -Msg ("[{0}] Backup waiting." -f $row["name"])
            }
        }
    }

    # 処理完了の待機
    while($RunspaceCollection){
        foreach($runspace in $RunspaceCollection){
            if ($runspace.Runspace.IsCompleted){
                $ret = $runspace.powershell.EndInvoke($runspace.Runspace)
                $runspace.PowerShell.Dispose()
                
                if (($ret | Get-Member).TypeName[0] -eq [System.Management.Automation.ErrorRecord]){
                    Out-Message -Msg ("[{0}] Backup failed : {1} (Start:[{2}] / End:[{3}])" -f $runspace.DBName, $ret.Exception.Message, $runspace.StartTime, (Get-Date))
                    $failed +=1
                }else{
                    Out-Message -Msg ("[{0}] Backup completed (File:[{1}] / Start:[{2}] / End:[{3}])" -f $runspace.DBName, $runspace.BackupFile, $runspace.StartTime, (Get-Date))
                    $success +=1
                }
                [void]$Result.Add($ret)
                $RunspaceCollection.Remove($runspace)
                break
            }
        }
        Start-Sleep -Milliseconds 100
    }

}catch{
  Write-Output $Error[0]
}finally{
    if ($runspacePool -ne $null){
        $runspacePool.Close()
        $runspacePool.Dispose()
    }
}

$ds.Dispose()
$da.Dispose()

$con.Close()
$con.Dispose()

$sw.Stop()

Out-Message -Msg ("Backup $(if($Log){"Log "}else{"Database "})End.")
Out-Message -Msg ("=" * 20)
Out-Message -Msg ("Total execution time (sec) : [{0}]" -f $sw.Elapsed.TotalSeconds)
Out-Message -Msg ("[Result] Success : [{0}] / Failed : [{1}]" -f $success, $failed)
Out-Message -Msg ("=" * 20)
