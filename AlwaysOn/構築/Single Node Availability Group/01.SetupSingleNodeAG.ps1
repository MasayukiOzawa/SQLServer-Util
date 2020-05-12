$ErrorActionPreference = "Stop"

$dnsSuffix = "wsfc.local"

$clusterName = "2019-WSFC"
$clusterIpSettings = @{
    Address    = "10.85.0.10"
    SubNetMask = "255.0.0.0"
    EnableDhcp = $false
}
$listnerName = "AG-LN"
$listenerIpSettings = @{
    Address    = "10.85.0.11"
    SubNetMask = "255.0.0.0"
}

$nodeSettings = @(
    @{Address="10.85.0.1";Name="AG-01"},
    @{Address="10.85.0.2";Name="AG-02"},
    @{Address="10.85.0.3";Name="AG-03"}
)

$sharedFolderSettings = @{
    directoryPath = "\\10.0.0.100\VMShared"
    userName      = "10.0.0.100\SharedUser"
    password      = "xxxxxxxxx"
}

$sqlLogin = @{
    loginName = "xxxxxxx"
    password = "xxxxxxxx"
}

$sqlserverSetup = "D:\setup.exe"
$sqlserverConiguraitonFile = "C:\Scripts\ConfigurationFile.ini"
$ssmsSetup = "C:\Scripts\SSMS-Setup-JPN.exe"

$hosts = "C:\Windows\System32\drivers\etc\hosts"

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

# WSFC の構築
if ((Get-Service -Name "ClusSvc").Status -eq "stopped") {
    Write-Log "Start : WSFC のセットアップ"
    New-Cluster -Name $clusterName -node $env:COMPUTERNAME -AdministrativeAccessPoint Dns -StaticAddress $clusterIpSettings.Address

    # クラスター IP の設定 (DHCP の場合、エラーが発生して割り当てられなかったので、静的 IP を設定)
    <#
    $clusterIpResource = Get-ClusterResource | ? ResourceType -eq "IP Address"
    $clusterIpResource | Set-ClusterParameter -Multiple $clusterIpSettings
    $clusterIpResource | Start-ClusterResource
    #>

    # クォーラムの設定 (共有ディレクトリ型のクォーラムの利用)
    $smbPassword = ConvertTo-SecureString $sharedFolderSettings.password  -AsPlainText -Force
    $smbCred = New-Object System.Management.Automation.PSCredential($sharedFolderSettings.userName, $smbPassword)
    New-SmbGlobalMapping -RemotePath $sharedFolderSettings.directoryPath -Credential $smbCred

    Set-ClusterQuorum -FileShareWitness $sharedFolderSettings.directoryPath
    Write-Log "End : WSFC のセットアップ"
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

<#
Install-PackageProvider -Name NuGet -Force
Install-Module -Name SqlServer -Force
Enable-SqlAlwaysOn -ServerInstance $env:COMPUTERNAME -Force
#>


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
$sqlWmi = Get-WmiObject -Namespace 'root\Microsoft\SqlServer\ComputerManagement15' -Class HADRServiceSettings
if ($sqlWmi.HADRServiceEnabled -eq $false) {
    Write-Log "Start : AlwaysOn の設定"
    $sqlwmi.ChangeHADRService(1)
    Restart-Service "MSSQLSERVER"

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

    # エンドポイントの接続に使用する証明書にユーザーをマッピング 
    $cmd.CommandText = @"
CREATE CERTIFICATE AlwaysOnEndpoint_Cert 
AUTHORIZATION AlwaysOnEndpoint 
WITH SUBJECT = 'AlwaysOn Endpoint',START_DATE = '01/01/2015',EXPIRY_DATE = '01/01/2100'
"@
    $cmd.ExecuteNonQuery()


    # 証明書のバックアップ
    $cmd.CommandText = @"
BACKUP CERTIFICATE AlwaysOnEndpoint_Cert 
TO FILE = 'C:\Scripts\certbackup.cer'
WITH PRIVATE KEY (FILE='C:\Scripts\certbackup.pvk', ENCRYPTION BY PASSWORD='Enc Passw0rd')
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

    # 可用性グループの作成
    $cmd.CommandText = @"
CREATE AVAILABILITY GROUP [AG01]
WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY,
DB_FAILOVER = ON,
DTC_SUPPORT = PER_DB,
CLUSTER_TYPE = WSFC,
REQUIRED_SYNCHRONIZED_SECONDARIES_TO_COMMIT = 0)
FOR
REPLICA ON 
N'{0}' WITH (
    ENDPOINT_URL = N'TCP://{0}:5022', 
    FAILOVER_MODE = AUTOMATIC, 
    AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, 
    SESSION_TIMEOUT = 10, 
    BACKUP_PRIORITY = 50, 
    SEEDING_MODE = AUTOMATIC
)
"@ -f $ENV:COMPUTERNAME, ("$($ENV:COMPUTERNAME).$($dnsSuffix)")
    $cmd.ExecuteNonQuery()

    # 自動シード処理の有効化
    $cmd.CommandText = "ALTER AVAILABILITY GROUP AG01 GRANT CREATE ANY DATABASE"
    $cmd.ExecuteNonQuery()

    # リスナーの作成
    $cmd.CommandText = @"
ALTER AVAILABILITY GROUP [AG01]
ADD LISTENER N'{0}' (
WITH IP((N'{1}', N'{2}'))
, PORT=1433)
"@ -f $listnerName, $listenerIpSettings.Address, $listenerIpSettings.SubNetMask
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
}


# hosts の設定
Write-Log "Start : Host の設定"

"`n" | Add-Content $hosts -Encoding Default

$nodeSettings  | %{
    "{0}`t{1}.{2}" -f $_.Address, $_.Name, $dnsSuffix  | Add-Content $hosts -Encoding Default
}

"{0}`t{1}.{2}" -f $clusterIpSettings.Address, $clusterName, $dnsSuffix   | Add-Content $hosts -Encoding Default
"{0}`t{1}.{2}" -f $listenerIpSettings.Address, $listnerName, $dnsSuffix   | Add-Content $hosts -Encoding Default
Copy-Item $hosts "C:\Scripts\hosts"
Write-Log "End : Host の設定"


# タスクスケジューラーの削除
Unregister-ScheduledTask -TaskName "Setup Single Node AG" -Confirm:$false

# 完了後の再起動
Restart-Computer -Force