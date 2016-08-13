# SMO
  
# アセンブリのロード
# Windows PowerShell への SMO アセンブリの読み込み
# https://msdn.microsoft.com/ja-jp/library/hh245202.aspx

Add-Type -AssemblyName "Microsoft.SqlServer.SMO, Version=13.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
# [Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

([AppDomain]::CurrentDomain).GetAssemblies() | ? FullName -Match "SqlServer"

$smo = New-Object Microsoft.SqlServer.Management.Smo.Server

([AppDomain]::CurrentDomain).GetAssemblies() | ? FullName -Match "SqlServer"

# Windows 認証
$smo.ConnectionContext.ServerInstance = "localhost"
$smo.ConnectionContext.LoginSecure = $true
$smo.Databases

# SQL Server 認証
$smo = New-Object Microsoft.SqlServer.Management.Smo.Server
$smo.ConnectionContext.ServerInstance = "localhost"
$smo.ConnectionContext.LoginSecure = $false
$smo.ConnectionContext.Login = $user
$smo.ConnectionContext.Password = $password
$smo.Databases
