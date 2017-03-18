[CmdletBinding()]
param(
[string]$NewPort = "1433"
)

$ServiceName = (Get-WmiObject -Class win32_service | where PathName -match "sqlservr.exe").Name
$InstanceName = ($ServiceName -split "\$")[-1]

Import-Module SQLPS -DisableNameChecking

$MachineObject = new-object ("Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer")
$ProtocolUri = "ManagedComputer[@Name='" + (get-item env:computername).Value + "']/ServerInstance[@Name='$InstanceName']/ServerProtocol"

$tcp = $MachineObject.getsmoobject($ProtocolUri + "[@Name='Tcp']")

$ipall = $MachineObject.getsmoobject($tcp.urn.value + "/IPAddress[@Name='IPAll']")
$ipall.IPAddressProperties["TcpPort"].Value = $NewPort
$tcp.Alter()

Restart-Service $Servicename -Force
Get-NetTCPConnection -LocalPort $NewPort
