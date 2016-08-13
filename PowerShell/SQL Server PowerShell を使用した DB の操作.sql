# SQL Server PowerShell

# Windows 認証
$ret = Invoke-Sqlcmd -ServerInstance . -Query "SELECT @@VERSION" -QueryTimeout 30

# SQL Server 認証
$ret = Invoke-Sqlcmd -ServerInstance . -Username $UserId -Password $Password -Query "SELECT @@version"


# ストアドプロシージャの実行
$sql = @"
sp_configure @configname = `$(config)
"@
$ret = Invoke-Sqlcmd -ServerInstance . -Query $sql -Variable "config = 'show advanced options'"

$config = "show advanced options"
$sql = @"
sp_configure @configname = '$config'
"@
$ret = Invoke-Sqlcmd -ServerInstance . -Query $sql


# Input Object によるクエリタイムアウトの設定
$server = New-Object Microsoft.SqlServer.Management.Smo.Server
$server.ConnectionContext.ServerInstance = "."
# $server = New-Object Microsoft.SqlServer.Management.Smo.Server localhost
$server.ConnectionContext.StatementTimeout = 1200

Backup-SqlDatabase -InputObject $server -Database "master" -BackupFile "master.bak"

