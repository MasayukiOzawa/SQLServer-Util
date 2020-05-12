$ErrorActionPreference = "Stop"
$logFile = "C:\Scripts\log.txt"

function Write-Log(){
    Param($Msg)
    $logMsg = ("{0} : {1}" -f (Get-Date), $Msg)
    Add-Content -Path $logFile -Value $logMsg 
}

# AlwaysOn の設定
# https://docs.microsoft.com/ja-jp/sql/relational-databases/wmi-provider-configuration/working-with-the-wmi-provider-for-configuration-management?view=sql-server-ver15
$sqlWmi = Get-WmiObject -Namespace 'root\Microsoft\SqlServer\ComputerManagement15' -Class HADRServiceSettings
if ($sqlWmi.HADRServiceEnabled -eq $false) {
    Write-Log "Start : AlwaysOn の設定"
    $sqlwmi.ChangeHADRService(1)
    Restart-Service "MSSQLSERVER"

    Write-Log "End : AlwaysOn の設定"
}
