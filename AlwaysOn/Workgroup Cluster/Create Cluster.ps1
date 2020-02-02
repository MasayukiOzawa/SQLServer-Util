# https://docs.microsoft.com/ja-jp/sql/database-engine/availability-groups/windows/domain-independent-availability-groups
# https://docs.microsoft.com/ja-jp/azure/virtual-machines/windows/sql/virtual-machines-windows-portal-sql-availability-group-tutorial
# https://techcommunity.microsoft.com/t5/premier-field-engineering/azure-rm-sql-server-alwayson-availability-groups-listener/ba-p/370918
# https://techcommunity.microsoft.com/t5/premier-field-engineering/azure-rm-configure-a-second-availability-group-with-a-listener/ba-p/371191
# https://blog.engineer-memo.com/2015/10/19/tp%ef%bc%93-で-azure-上でワークグループクラスターを構築し、/

# WSFC の機能の追加
Install-WindowsFeature -Name "Failover-Clustering" -IncludeManagementTools
Restart-Computer

# クラスターの作成
New-Cluster -Name "SQLVM-WSFC" -Node @("SQLVM-01", "SQLVM-02") -AdministrativeAccessPoint Dns

# クラスター名の名前解決のために、IP アドレスリソースを追加 (クラスター名が DNS で名前解決でき、接続ができないとクラウド監視が設定できないため)
## IP アドレスの設定
$CoreClusterGroup = Get-ClusterGroup | ? GroupType -eq "Cluster"
$ClusterIp = Add-ClusterResource -Group $CoreClusterGroup.Name -Name "Cluster IP Address" -ResourceType "IP Address"  
$ClusterIp | Set-ClusterParameter -Multiple @{Network="$((Get-ClusterNetwork).Name)";Address="10.1.6.10";SubnetMask="255.255.255.0"}

$ClusterDNN = (Get-ClusterResource | ? ResourceType -eq "Distributed Network Name")
$ClusterDNN | Stop-ClusterResource
Set-ClusterResourceDependency -Resource $ClusterDNN.Name -Dependency "[$($ClusterIp.Name)]"
$ClusterDNN | Start-ClusterResource


# クラウド監視設定時の WinRm のため、Trusted Host 登録 (WSFC の各ノードで実行)
Set-Item WSMan:\localhost\Client\TrustedHosts * -Force

# クラウド監視の設定
Get-ClusterGroup | ? State -eq "Online" | Move-ClusterGroup -Node $ENV:COMPUTERNAME
Set-ClusterQuorum -CloudWitness -AccountName "<Storage Account Name>" -AccessKey "<Storage Access Key>"

# クラスター名リソースの DNS 登録の正常性チェックを無効にするため、NIC の DNS の自動登録の無効化 (WSFC の各ノードで実行)
Get-NetAdapter | ? InterfaceDescription -Like "*Hyper-V*" | Set-DnsClient -RegisterThisConnectionsAddress $false

# Windows Firewall の設定 (WSFC の各ノードで実行)
New-NetFirewallRule -Name "SQL Server" -DisplayName "SQL Server" -Action Allow -Protocol tcp -LocalPort @(1433,5022,59999)

# リスナーの IP アドレスに Probe Port を設定
$AGIP = Get-ClusterResource -Name "AG01*" | ? ResourceType -eq "IP Address" 
$AGIP | Set-ClusterParameter -Multiple @{OverrideAddressMatch=0;Address="<LB IP Address>";SubnetMask="255.255.255.255";ProbePort=59999}
Get-ClusterGroup -Name "AG01" | Stop-ClusterGroup
Get-ClusterGroup -Name "AG01" | Start-ClusterGroup
