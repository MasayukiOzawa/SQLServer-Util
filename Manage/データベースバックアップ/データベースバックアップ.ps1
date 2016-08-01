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

Push-Location
Import-Module SQLPS -DisableNameChecking
Pop-Location

$global:VerifySQL = @"
RESTORE VERIFYONLY FROM DISK=N'{0}'
"@

function Start-SQLServerFullBackup(){
<#
.DESCRIPTION
SQL Server の完全バックアップを取得
#>
[CmdletBinding()]
param(
    [string]$Instance = $env:COMPUTERNAME,
    [string]$BackupPath = "",
    [switch]$NoVerify
)
    $Server = New-Object Microsoft.SqlServer.Management.Smo.Server $Instance
    $Server.ConnectionContext.StatementTimeout = 0

    foreach($Database in ($Server.Databases | ? Status -eq "Normal")){
        try{
            # tempdb はバックアップを取得できないためスキップ
            if($Database.Name -ne "tempdb"){
                $BackupFile =  ("{0}-{1}-{2}_FULL.bak" -f $Instance, $Database.Name,(Get-Date).ToString("yyyyMMdd"))

                if ($BackupPath -ne ""){
                    $BackupFile = Join-Path -Path $BackupPath -ChildPath $BackupFile
                }

                Write-Output ("{0} [{1}] 完全バックアップ取得開始" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile $BackupFile -BackupAction Database -CompressionOption On -Checksum -ContinueAfterError -ErrorAction Stop
                # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_FULL.bak' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR{
                Write-Output ("{0} [{1}] 完全バックアップ取得終了" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)

                if(!($NoVerify)){
                    Write-Output ("{0} [{1}] バックアップ整合性検証開始" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                    Invoke-Sqlcmd -ServerInstance $Instance -Query ($VerifySQL -f $BackupFile) -QueryTimeout 1200 -ErrorAction Stop
                    Write-Output ("{0} [{1}] バックアップ整合性検証終了" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                }
            }
        }catch{
            throw $_
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
    [string]$Instance = $env:COMPUTERNAME,
    [string]$BackupPath = "",
    [switch]$NoVerify
)
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

    foreach($Database in ($Server.Databases | ? Status -eq "Normal")){
        try{
            $BackupFile =  ("{0}-{1}-{2}_DIFF.bak" -f $Instance, $Database.Name,(Get-Date).ToString("yyyyMMdd"))

            if ($BackupPath -ne ""){
                $BackupFile = Join-Path -Path $BackupPath -ChildPath $BackupFile
            }
            # master は差分バックアップが取得できないため毎回完全バックアップを取得
            if ($Database.Name -eq "master"){
                Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile $BackupFile -BackupAction Database -CompressionOption On -Checksum -ContinueAfterError -ErrorAction Stop
                # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_FULL.bak' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
                if(!($NoVerify)){
                     Invoke-Sqlcmd -ServerInstance $Instance -Query ($VerifySQL -f $BackupFile) -QueryTimeout 1200
                }
            # tempdb はバックアップを取得できないためスキップ
            }elseif ($Database.name -ne "tempdb"){
                # 完全バックアップの取得状況を確認
                $FullBackupCount = Invoke-Sqlcmd -ServerInstance $Instance -Query ($BackupCheckSQL -f "D", $Database.Name)  -QueryTimeout 120

                if($FullBackupCount.count -eq 0){
                    Write-Output ("{0} の完全バックアップが取得されていないため、初回完全バックアップを取得します" -f $Database.Name)
                    Write-Output ("{0} [{1}] 完全バックアップ取得開始" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                    Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile $BackupFile -BackupAction Database -CompressionOption On -Checksum -ContinueAfterError -ErrorAction Stop
                    # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_FULL.bak' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
                    Write-Output ("{0} [{1}] 完全バックアップ取得終了" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                }else{
                    Write-Output ("{0} [{1}] 差分バックアップ取得開始" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                    Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile $BackupFile -BackupAction Database -CompressionOption On -Checksum -Incremental -ContinueAfterError -ErrorAction Stop
                    # BACKUP DATABASE [xxxx] TO  DISK = N'xxxx-xxxx-yyyymmdd_DIFF.bak' WITH  DIFFERENTIAL , NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
                    Write-Output ("{0} [{1}] 差分バックアップ取得終了" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                }

                if(!($NoVerify)){
                    Write-Output ("{0} [{1}] バックアップ整合性検証開始" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                    Invoke-Sqlcmd -ServerInstance $Instance -Query ($VerifySQL -f $BackupFile) -QueryTimeout 1200 -ErrorAction Stop
                    Write-Output ("{0} [{1}] バックアップ整合性検証終了" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                }
            }
        }catch{
            throw $_
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
    [string]$Instance = $env:COMPUTERNAME,
    [string]$BackupPath = "",
    [switch]$NoVerify
)
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

    foreach($Database in ($Server.Databases | ? Status -eq "Normal")){
        try{
            $BackupFile =  ("{0}-{1}-{2}_Log.trn" -f $Instance, $Database.Name,(Get-Date).ToString("yyyyMMdd"))

            if ($BackupPath -ne ""){
                $BackupFile = Join-Path -Path $BackupPath -ChildPath $BackupFile
            }

            # 単純復旧モデルはログバックアップをスキップ
            if ($database.RecoveryModel -ne "Simple"){
                # 完全バックアップの取得状況を確認
                $FullBackupCount = Invoke-Sqlcmd -ServerInstance $Instance -Query ($BackupCheckSQL -f "D", $Database.Name) -QueryTimeout 120

                # 一度も完全バックアップを取得していない場合はログバックアップを取得できないためスキップ
                if ($FullBackupCount.count  -eq 0) {
                    Write-Output ("{0} の完全バックアップが取得されていないため、ログバックアップの取得をスキップします" -f $database.Name)
                }else{
                    Write-Output ("{0} [{1}] ログバックアップ取得開始" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                    Backup-SqlDatabase -InputObject $Server -Database $Database.Name -BackupFile $BackupFile -BackupAction Log  -CompressionOption On -Checksum -ContinueAfterError  -ErrorAction Stop
                    # BACKUP LOG [xxxxx] TO  DISK = N'xxxxx-xxxx-yyyymmdd_LOG.trn' WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 10, CHECKSUM, CONTINUE_AFTER_ERROR
                    Write-Output ("{0} [{1}] ログバックアップ取得終了" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)

                    if(!($NoVerify)){
                        Write-Output ("{0} [{1}] バックアップ整合性検証開始" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                        Invoke-Sqlcmd -ServerInstance $Instance -Query ($VerifySQL -f $BackupFile) -QueryTimeout 1200 -ErrorAction Stop
                        Write-Output ("{0} [{1}] バックアップ整合性検証終了" -f (Get-Date).ToString("yyyy/MM/dd HH:mm:ss"), $Database.Name)
                    }
                }
            }
        }catch{
            throw $_
        }
    }
}