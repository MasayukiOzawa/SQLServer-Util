# https://blog.engineer-memo.com/2021/01/13/sql-server-on-azure-vm-%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E6%B8%88%E3%81%BF%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8-%E3%81%AE%E6%97%A5%E6%9C%AC%E8%AA%9E%E5%8C%96-2021-1-%E7%89%88/
# https://learn.microsoft.com/ja-jp/rest/api/sqlvm/2022-07-01-preview/sql-virtual-machines/get?tabs=HTTP
# https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.SqlVirtualMachine/sqlVirtualMachines/{2}?api-version=2022-07-01-preview
<#
400 SqlServerSettingCollationNotAllowedToUpdate - SQL Server照合順序を管理容易性で更新することはできません。
400 SqlServerSettingLPIMNotAllowedToUpdate - SQL Server メモリ内のページのロックは、管理容易性で更新できません。
400 SqlServerSettingIFINotAllowedToUpdate - SQL SERVER IFI は管理容易性で更新できません。
#>
# Connect-AzAccount


$subscriptionID = (Get-AzContext).Subscription.id
$resourceGroup = "xxxxxxx"
$vmName = "xxxxxxx"
 
$token = "Bearer " + (Get-AzAccessToken).Token
  
$uri = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.SqlVirtualMachine/sqlVirtualMachines/{2}?api-version=2022-07-01-preview" -f $subscriptionID, $resourceGroup, $vmName

$header = @{
    "Authorization" = $token
    "Content-type" = "application/json"
}
$body = @{
    "location" = "japaneast"
    "properties" = @{
    "type" = "SqlIaaSAgent"
    "virtualMachineResourceId" = "/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Compute/virtualMachines/{2}" -f $subscriptionID, $resourceGroup, $vmName
            "StorageConfigurationSettings" = @{
                "DiskConfigurationType"= "EXTEND"
                "SQLTempDbSettings" = @{
                    "PersistFolder" = $true
                    "DataFileSize" = "8"
                    "DataGrowth" = "64"
                    "DataFileCount"= "8"
                    "LogFileSize" = "8"
                    "LogGrowth" = "64"
                    "PersistFolderPath" = "D:\tempdb"
                }
            }
            "ServerConfigurationsManagementSettings"= @{
                "SQLInstanceSettings" = @{
                    "maxDop" = 4
                    "isOptimizeForAdHocWorkloadsEnabled" = $true
                    "minServerMemoryMB" = 0
                    "maxServerMemoryMB" = 20480
                }
            }
        }
    } | ConvertTo-Json -Depth 10 -Compress

$results = Invoke-WebRequest -Method "PUT" -Uri $uri -Headers $header -Body $body -SkipHttpErrorCheck
Write-Host ("{0}: {1}" -f $results.StatusCode, $results.Content)

$extensionUri = "https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/Microsoft.Compute/virtualMachines/{2}/extensions/SqlIaasExtension?api-version=2018-10-01`&`$expand=instanceView" -f $subscriptionID, $resourceGroup, $vmName
$contents =Invoke-WebRequest -Method "GET" -Uri $extensionUri -Headers $header
$contents.Content

<#
$uri = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Compute/virtualMachines/{2}?api-version=2017-03-30" -f $subscriptionID, $resourceGroup, $vmName
$ret = Invoke-WebRequest -Method "GET" -Uri $uri -Headers $header
$json = $ret.Content | Convertfrom-Json
($json.resources | Where-Object Name -eq SqlIaasExtension).properties.Settings.ServerConfigurationsManagementSettings.SQLStorageUpdateSettingsV2
#>
