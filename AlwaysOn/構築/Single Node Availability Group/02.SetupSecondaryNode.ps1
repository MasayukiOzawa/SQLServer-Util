$ErrorActionPreference = "Stop"

$dnsSuffix = "wsfc.local"

$sqlLogin = @{
    loginName = "xxxxxxxx"
    password = "xxxxxxxx"
}

$sqlserverSetup = "D:\setup.exe"
$sqlserverConiguraitonFile = "C:\Scripts\ConfigurationFile.ini"
$ssmsSetup = "C:\Scripts\SSMS-Setup-JPN.exe"

$connectionString = "Server=.;Integrated Security=SSPI;Database=master"
$logFile = "C:\Scripts\log.txt"

function Write-Log(){
    Param($Msg)
    $logMsg = ("{0} : {1}" -f (Get-Date), $Msg)
    Add-Content -Path $logFile -Value $logMsg 
}

# 処理用のタスクスケジューラーの登録
if ($null -eq (Get-ScheduledTask -TaskName "Setup Single Node AG" -ErrorAction SilentlyContinue)) {
    Write-Log "Start : タスクスケジューラーの登録"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument ("-File {0}" -f $MyInvocation.MyCommand.Path)
    $trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName "Setup Single Node AG" -Action $action -Trigger $trigger -User "NT AUTHORITY\SYSTEM"
    Write-Log "End : タスクスケジューラーの登録"
    Restart-Computer -Force
}

# プライマリ DNS サフィックスの設定
if ($null -eq (Get-ItemProperty "registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters")."NV Domain") {
    Write-Log "Start : プライマリ DNS サフィックスの設定"
    Set-ItemProperty "registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "NV Domain" -Value $dnsSuffix
    Write-Log "End : プライマリ DNS サフィックスの設定"
}

# WSFC の機能追加
if ((Get-WindowsFeature -Name Failover-Clustering).Installed -eq $false) {
    Write-Log "Start : WSFC の機能追加"
    Add-WindowsFeature -Name Failover-Clustering -IncludeManagementTools
    Write-Log "End : WSFC の機能追加"
    Restart-Computer -Force
}

# SQL Server のインストール
do{
    Write-Log "Start : SQL Server のインストール"
    if((Test-path "C:\Scripts\temp" -ErrorAction SilentlyContinue) -eq $false){
        New-Item -Path "C:\Scripts\temp" -ItemType Directory
    }
    $ENV:TEMP = "C:\Scripts\Temp"
    $ENV:TMP = "C:\Scripts\Temp"
    Invoke-Expression -Command ("{0} /CONFIGURATIONFILE='{1}' /IACCEPTSQLSERVERLICENSETERMS" -f $sqlserverSetup, $sqlserverConiguraitonFile)
    Write-Log $LASTEXITCODE
    Write-Log "End : SQL Server のインストール"
    Start-Sleep -Seconds 5
}while ($null -eq (Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue)) 

# SSMS のインストール
# Invoke-WebRequest -uri "https://go.microsoft.com/fwlink/?linkid=2125901&clcid=0x411" -OutFile .\SSMS-Setup-JPN.exe
Write-Log "Start : SSMS のインストール"
Start-Process $ssmsSetup  -ArgumentList @("/install", "/quiet", "/norestart") -Wait
Write-Log "Ebd : SSMS のインストール"



# SQL Server 向けの F/W 設定
if ($null -eq (Get-NetFirewallRule -Name "Sql Server" -ErrorAction SilentlyContinue)) {
    Write-Log "Start : Windows Fire Wall の設定"
    New-NetFirewallRule -Name "SQL Server" -DisplayName "SQL Server" -Protocol "TCP" -LocalPort "1433"
    New-NetFirewallRule -Name "SQL Server AlwaysOn Endpoint" -DisplayName "SQL Server" -Protocol "TCP" -LocalPort "5022"
    Write-Log "End : Windows Fire Wall の設定"
}

# ウイルススキャンの除外設定
# https://support.microsoft.com/ja-jp/help/309422/choosing-antivirus-software-for-computers-that-run-sql-server
# https://docs.microsoft.com/ja-jp/windows/security/threat-protection/windows-defender-antivirus/configure-extension-file-exclusions-windows-defender-antivirus
Write-Log "Start : Windows Defender の除外設定"
Add-MpPreference -ExclusionExtension @(".mdf", ".ldf", ".ndf", ".trn", ".bak", ".xel")
Add-MpPreference -ExclusionProcess "sqlservr.exe"
Write-Log "End : Windows Defender の除外設定"


# AlwaysOn の設定
# https://docs.microsoft.com/ja-jp/sql/relational-databases/wmi-provider-configuration/working-with-the-wmi-provider-for-configuration-management?view=sql-server-ver15
Write-Log "Start : AlwaysOn の設定"

# SQL Server への接続
$con = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$con.Open()
$cmd = $con.CreateCommand()
$cmd.CommandTimeout = 0


# マスターキーの作成
$cmd.CommandText = "CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MASTER KEY Passw0rd'"
$cmd.ExecuteNonQuery()

# エンドポイントの接続用ログイン/ユーザーを作成
$cmd.CommandText = @"
DECLARE @password varchar(36) = (SELECT NEWID())
EXECUTE ('CREATE LOGIN AlwaysOnEndpoint WITH PASSWORD = ''' +  @password + ''',CHECK_EXPIRATION=OFF')
CREATE USER AlwaysOnEndpoint FOR LOGIN AlwaysOnEndpoint;
"@
$cmd.ExecuteNonQuery()

# 証明書の復元
$cmd.CommandText = @"
CREATE CERTIFICATE AlwaysOnEndpoint_Cert 
AUTHORIZATION AlwaysOnEndpoint 
FROM FILE='C:\Scripts\certbackup.cer' 
WITH PRIVATE KEY (FILE='C:\Scripts\certbackup.pvk', DECRYPTION BY PASSWORD='Enc Passw0rd')
"@
$cmd.ExecuteNonQuery()


# エンドポイントの作成
$cmd.CommandText = @"
CREATE ENDPOINT AlwaysOnEndpoint
STATE = STARTED
AS TCP (LISTENER_PORT = 5022, LISTENER_IP = ALL)
FOR DATABASE_MIRRORING (AUTHENTICATION = CERTIFICATE AlwaysOnEndpoint_Cert,ROLE = ALL)
GRANT CONNECT ON ENDPOINT::AlwaysOnEndpoint TO AlwaysOnEndpoint
"@
$cmd.ExecuteNonQuery()


# SQL Server 認証の有効化 (ワークグループクラスターの場合は SQL Server 認証でのアクセスを行う機会のほうが多いため)
$cmd.CommandText = "EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', REG_DWORD, 2"
$cmd.ExecuteNonQuery()
Restart-Service "MSSQLSERVER"

# SQL Server 認証の有効化 (ワークグループクラスターの場合は SQL Server 認証でのアクセスを行う機会のほうが多いため)
$cmd.CommandText = @"
CREATE LOGIN [{0}] WITH PASSWORD=N'{1}', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
ALTER SERVER ROLE [sysadmin] ADD MEMBER [{0}]
"@ -f $sqlLogin.loginName, $sqlLogin.password
$cmd.ExecuteNonQuery()

$con.Close()
$con.Dispose()

Write-Log "End : AlwaysOn の設定"

# hosts の設定
Write-Log "Start : Host の設定"
Copy-Item C:\Scripts\hosts C:\Windows\system32\drivers\etc\hosts
Write-Log "End : Host の設定"

# タスクスケジューラーの削除
Unregister-ScheduledTask -TaskName "Setup Single Node AG" -Confirm:$false

# 完了後の再起動
Restart-Computer -Force