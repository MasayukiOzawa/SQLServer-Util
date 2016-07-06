<#
複数のバージョンの SQLPS をインストールしており、'InputObject' をバインドできません。"のエラーが発生する場合、以下の実施を検討する
http://dba.stackexchange.com/questions/102682/backup-sqldatabase-cannot-bind-parameter-inputobject-error-being-thrown
http://powershelldiaries.blogspot.in/2015/08/backup-sqldatabase-restore-sqldatabase.html

# 確認
Get-Module -ListAvailable 
([appdomain]::CurrentDomain.GetAssemblies() | where {$_.FullName -like "*smo*"}).Location

# PSModulePath を操作
$TempArray = @()
$TempArray = $env:PSModulePath -split ';'
# 110 for SQL 2012, 120 for SQL 2014, 130 for SQL 2016
$env:PSModulePath = ($TempArray -notmatch '110') -join ';'  

#>

function Start-SQLServerFullBackup(){
<#
.DESCRIPTION
SQL Server の完全バックアップを取得
#>
[CmdletBinding()]
param(
    [string]$Instance = $env:COMPUTERNAME
)

    Import-Module SQLPS -DisableNameChecking

    $Server = New-Object Microsoft.SqlServer.Management.Smo.Server $Instance
    $Server.ConnectionContext.StatementTimeout = 0

    foreach($Database in $Server.Databases){
        # tempdb はバックアップを取得できないためスキップ
        if($Database.Name -ne "tempdb"){
            Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile ("{0}-{1}-{2}_FULL.bak" -f $env:COMPUTERNAME, $Database.Name,(Get-Date).ToString("yyyyMMdd")) -BackupAction Database -CompressionOption On -Checksum -ContinueAfterError
            # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_FULL.bak' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
        }
    }
}

function Start-SQLServerDiffBackup(){
<#
.DESCRIPTION
SQL Server の差分バックアップを取得
#>
[CmdletBinding()]
param(
    [string]$Instance = $env:COMPUTERNAME
)
    Import-Module SQLPS -DisableNameChecking

    $Server = New-Object Microsoft.SqlServer.Management.Smo.Server $Instance
    $Server.ConnectionContext.StatementTimeout = 0

    $BackupCheckSQL = @"
SELECT db_id(database_name) AS database_id,database_name, type, database_creation_date,backup_start_date,backup_finish_date 
FROM msdb.dbo.backupset 
WHERE 
type = '{0}'
and
db_id(database_name) = DB_ID('{1}')
"@

    foreach($Database in $Server.Databases){
        # master は差分バックアップが取得できないため毎回完全バックアップを取得
        if ($Database.Name -eq "master"){
            Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile ("{0}-{1}-{2}_DIFF.bak" -f $env:COMPUTERNAME, $Database.Name,(Get-Date).ToString("yyyyMMdd")) -BackupAction Database -CompressionOption On -Checksum -ContinueAfterError
            # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_FULL.bak' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
        # tempdb はバックアップを取得できないためスキップ
        }elseif ($Database.name -ne "tempdb"){
            # 完全バックアップの取得状況を確認
            $FullBackupCount = Invoke-Sqlcmd -ServerInstance $env:COMPUTERNAME -Query ($BackupCheckSQL -f "D", $Database.Name)

            if($FullBackupCount.count -eq 0){
                Write-Output ("{0} の完全バックアップが取得されていないため、初回完全バックアップを取得します" -f $Database.Name)
                Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile ("{0}-{1}-{2}_DIFF.bak" -f $env:COMPUTERNAME, $Database.Name,(Get-Date).ToString("yyyyMMdd")) -BackupAction Database -CompressionOption On -Checksum -ContinueAfterError
                # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_FULL.bak' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
            }else{
                Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile ("{0}-{1}-{2}_DIFF.bak" -f $env:COMPUTERNAME, $Database.Name,(Get-Date).ToString("yyyyMMdd")) -BackupAction Database -CompressionOption On -Checksum -Incremental -ContinueAfterError
                # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_DIFF.bak' WITH  DIFFERENTIAL , NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
            }
        }
    }
}

function Start-SQLServerLogBackup(){
<#
.DESCRIPTION
SQL Server のログバックアップを取得
#>
[CmdletBinding()]
param(
    [string]$Instance = $env:COMPUTERNAME
)

    Import-Module SQLPS -DisableNameChecking
    
    $Server = New-Object Microsoft.SqlServer.Management.Smo.Server $Instance
    $Server.ConnectionContext.StatementTimeout = 0

    $BackupCheckSQL = @"
SELECT db_id(database_name) AS database_id,database_name, type, database_creation_date,backup_start_date,backup_finish_date 
FROM msdb.dbo.backupset 
WHERE 
type = '{0}'
and
db_id(database_name) = DB_ID('{1}')
"@

    foreach($Database in $Server.Databases){
        # 単純復旧モデルはログバックアップをスキップ
        if ($database.RecoveryModel -ne "Simple"){
            # 完全バックアップの取得状況を確認
            $FullBackupCount = Invoke-Sqlcmd -ServerInstance $env:COMPUTERNAME -Query ($BackupCheckSQL -f "D", $Database.Name)

            # 一度も完全バックアップを取得していない場合はログバックアップを取得できないためスキップ
            if ($FullBackupCount.count  -eq 0) {
                Write-Output ("{0} の完全バックアップが取得されていないため、ログバックアップの取得をスキップします" -f $database.Name)
            }else{
                Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile ("{0}-{1}-{2}_LOG.trn" -f $env:COMPUTERNAME, $Database.Name,(Get-Date).ToString("yyyyMMdd"))  -BackupAction Log  -CompressionOption On -Checksum -ContinueAfterError
                # BACKUP LOG [xxxxx] TO  DISK = N'xxxxx-xxxx-yyyymmdd_LOG.trn' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
            }
        }
    }
}



Start-SQLServerFullBackup
Start-SQLServerDiffBackup
Start-SQLServerLogBackup
