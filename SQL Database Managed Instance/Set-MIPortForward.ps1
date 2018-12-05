[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [int[]]$localport,
    [Parameter(Mandatory=$true)]
    [String]$ServerInstance,
    [Parameter(Mandatory=$true)]
    [String]$UserName,
    [Parameter(Mandatory=$true)]
    [String]$Password      
)

$ErrorActionPreference = "Stop"
try{
    # 既存の portproxy のルール削除
    $netsh = netsh interface portproxy show v4tov4
    $retline = @()

    foreach($val in $netsh){
        if(![System.String]::IsNullOrEmpty($val) -and $val[0] -match "\d"){
            $retline += $val
        }
    }

    $netsh_rule = @()
    foreach($ret_netsh in $retline){
        $netsh_val = $ret_netsh -split " "
        $tmpval = @()
        for($i = 0; $i -le $netsh_val.Count; $i++){
            if(![System.String]::IsNullOrEmpty($netsh_val[$i])){
                $tmpval += $netsh_val[$i]
            }
        }

        $netsh_rule += [PSCustomObject]@{
            sourceAddress = $tmpval[0]
            sourcePort = $tmpval[1]
            destAdress = $tmpval[2]
            destPort = $tmpval[3]
        }
    }

    $netsh_rule | %{Invoke-Expression ("netsh interface portproxy delete v4tov4 listenport={0} listenaddress={1}" -f $_.sourcePort, $_.sourceAddress)}


    # MI のローカルポートと IP を取得
    $sql = @"
    SELECT
        r.node_name, 
	    ps.primary_replica_server_name, 
	    n.ip_address_or_FQDN, 
	    d.name,
        r.replica_role_desc, 
	    ps.service_type_desc, 
	    r.replica_address, 
	    ps.service_uri, 
	    ps.database_name
    FROM
        sys.dm_hadr_fabric_replicas r
        LEFT JOIN sys.dm_hadr_fabric_partition_states ps
        ON  r.partition_id = ps.partition_id
        LEFT JOIN sys.databases d
        ON  ps.service_name = d.physical_database_name
        LEFT JOIN sys.dm_hadr_fabric_nodes n
        ON  r.node_name = n.node_name
    WHERE
        name IS NOT NULL
	    AND
	    name = 'msdb'
"@

    $ret = Invoke-Sqlcmd -ServerInstance $ServerInstance -Username $UserName -Password $Password -Query $sql
    $tdsaddress = $ret.ip_address_or_FQDN
    $replicaAddress = $ret.replica_address -split ","
    $tdsport = $replicaAddress -match "dtds"

    $localip = Get-NetIPConfiguration
    $localport | %{Invoke-Expression ("netsh interface portproxy add v4tov4 listenaddress={0} listenport={1} connectaddress={2} connectport={3}" -f $localip.IPv4Address.IPAddress, $_, $tdsaddress, $($tdsport -split ":")[1] )}


    Invoke-Expression "netsh interface portproxy show v4tov4"
}catch{
    $_.Exception

}