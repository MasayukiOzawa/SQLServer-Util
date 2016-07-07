# クラスター IP アドレスの設定
$ClusterNetworkName = "<クラスターネットワーク名>"
$IPResourceName = "<IP アドレスリソース名>"

Get-ClusterResource -Name $IPResourceName | Set-ClusterParameter `
-Multiple @{
Network=$ClusterNetworkName;`
Address="169.254.1.1";`
SubnetMask="255.255.255.255";`
OverrideAddressMatch=1;`
EnableDhcp=0
}

# 可用性グループリスナーの IP アドレスの設定
$ClusterNetworkName = "<クラスターネットワーク名>"
$IPResourceName = "<IP アドレスリソース名>"
$LBIP = "<ロードバランサー IP アドレス>"

Get-ClusterResource -Name $IPResourceName | Set-ClusterParameter `
-Multiple @{
Network=$ClusterNetworkName;`
Address=$LBIP;`
ProbePort="59999";`
SubnetMask="255.255.255.255";`
OverrideAddressMatch=1;`
EnableDhcp=0
}

# クラスターネットワークの障害検知の設定調整
# 設定値の確認
Get-Cluster | Select SameSubnet*, CrossSubnet*

# 設定の変更
(Get-Cluster).SameSubnetDelay = 1000
(Get-Cluster).SameSubnetThreshold = 5
(Get-Cluster).CrossSubnetDelay = 1000
(Get-Cluster).CrossSubnetThreshold = 5
