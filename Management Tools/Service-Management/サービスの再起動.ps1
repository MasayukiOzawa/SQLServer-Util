$ServiceName = "MSSQLSERVER"

# 依存関係のあるサービスの停止
$DependentServices = Get-Service $ServiceName -DependentServices | ? Status -ne "Stopped"
$DependentServices | %{Write-Host "Stop Service [$($_.Name)]";$_ | Stop-Service}

# サービスの停止
Write-Host "Stop Service [$($ServiceName)]";Stop-Service -Name $ServiceName -Force

# サービスの開始
Write-Host "Start Service [$($ServiceName)]";Start-Service -Name $ServiceName

# 依存関係のあるサービスの開始
$DependentServices = Get-Service "MSSQLSERVER" -DependentServices | ? Status -eq "Stopped"
$DependentServices |  %{Write-Host "Start Service [$($_.Name)]";$_ | Start-Service}
