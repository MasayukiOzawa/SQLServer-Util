# パスワード生成
function New-RandomPassword {
	param(
		$length = 10,
		$characters = 'abcdefghkmnprstuvwxyzABCDEFGHKLMNPRSTUVWXYZ0123456789'
	)

	$random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
	$private:ofs=""
	$password = $characters[$random]

    $lower = [string]'abcdefghkmnprstuvwxyz'
    $upper= [string]'ABCDEFGHKLMNPRSTUVWXYZ'
    $num = [string]'0123456789'

    for ($i = 0; $i -lt $length; $i++){ 
        for ($j = 0; $j -lt $lower.Length; $j ++){
            if ($password[$i] -ceq $lower.Substring($j, 1)) {$bolLower = $true;break}
            else{$bolLower = $false}
        }
        if($bolLower -eq $true){break}
    }
    for ($i = 0; $i -lt $length; $i++){ 
        for ($j = 0; $j -lt $upper.Length; $j ++){
            if ($password[$i] -ceq $upper.Substring($j, 1)) {$bolUpper = $true;break}
            else{$bolUpper = $false}
        }
        if($bolUpper -eq $true){break}
    }
    for ($i = 0; $i -lt $length; $i++){ 
        for ($j = 0; $j -lt $num.Length; $j ++){
            if ($password[$i] -eq $num.Substring($j, 1)) {$bolNum = $true;break}
            else{$bolNum = $false}
        }
        if($bolNum -eq $true){break}
    }
    if ($bolLower -eq $true -and $bolUpper -eq $true -and $bolNum -eq $true){
        [string]$password
    }else{
        New-RandomPassword -length $length
    }
}

$ServiceUser = "SQLServiceUser"
$BackupServer = "192.168.0.1"
$BackupUser = "domain\backupusername"
$BackupUserPassword = "backupuserpassword"

# ローカルユーザーの作成
$Password = New-RandomPassword
$ADSI = [adsi]"WinNT://$ENV:COMPUTERNAME"
$User = $ADSI.Create("User", "$ServiceUser")
$User.SetPassword($Password)
$User.PasswordExpired = 0
$User.setInfo()
$user.Put("UserFlags", ($User.Get("UserFlags") -bor 0x10040))
$User.setInfo()

# サービスアカウントの変更
# https://blogs.msdn.microsoft.com/timomta/2014/02/20/automating-sql-service-accountpassword-changes/
# https://msdn.microsoft.com/ja-jp/library/hh245202.aspx
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
$mc = new-object Microsoft.SQLServer.Management.SMO.WMI.ManagedComputer localhost
$service = $mc.Services["MSSQLSERVER"]
$service.SetServiceAccount($ServiceUser, $Password)
$service.Alter()

# https://technet.microsoft.com/ja-jp/sysinternals/pxexec.aspx
# https://gallery.technet.microsoft.com/scriptcenter/PowerShell-Credentials-d44c3cde
# ローカルシステムの資格情報として、サービスアカウントの情報を追加
C:\Scripts\PsExec.exe -accepteula -s cmd.exe "/c Powershell.exe C:\Scripts\CredMan.ps1 -AddCred -Target '$ServiceUser' -User '$ServiceUser' -Pass $Password -CredType GENERIC"
$LASTEXITCODE
# ローカルシステムの資格情報から、サービスアカウントのパスワードを取得
$ServicePassword = (((C:\Scripts\PsExec.exe -s cmd.exe "/c Powershell.exe C:\Scripts\CredMan.ps1 -GetCred -Target '$ServiceUser' -CredType GENERIC" | Select-String "Password") -split ":")[1]).ToString().Trim()
$LASTEXITCODE

# SQL Server のサービスアカウントに共有フォルダーへの資格情報を追加
C:\Scripts\PsExec.exe -accepteula -u "$ServiceUser" -p "$ServicePassword" cmd.exe "/c Powershell.exe C:\Scripts\CredMan.ps1 -AddCred -Target '$BackupServer' -User '$BackupUser' -Pass '$BackupUserPassword' -CredPersist ENTERPRISE -CredType DOMAIN_PASSWORD"
$LASTEXITCODE