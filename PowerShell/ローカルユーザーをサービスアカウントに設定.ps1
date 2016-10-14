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

# ローカルユーザーの作成
$Password = New-RandomPassword
$ADSI = [adsi]"WinNT://$ENV:COMPUTERNAME"
$User = $ADSI.Create('User', 'SQLServiceUser')
$User.SetPassword($Password)
$User.PasswordExpired = 0
$User.setInfo()
$user.Put('UserFlags', ($User.Get('UserFlags') -bor 0x10040))
$User.setInfo()

# サービスアカウントの変更
# https://blogs.msdn.microsoft.com/timomta/2014/02/20/automating-sql-service-accountpassword-changes/
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
$mc = New-Object Microsoft.SQLServer.Management.SMO.WMI.ManagedComputer localhost
$service = $mc.Services["MSSQLSERVER"]
$service.SetServiceAccount("SQLServiceUser",$Password)
$service.Alter()
