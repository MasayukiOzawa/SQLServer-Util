/*
$vmName = "<vm name"
$rgName = "<resource group name>"
$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName 
Remove-AzSqlVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName
New-AzResourceGroupDeployment -ResourceGroupName $vm.ResourceGroupName  -Name "SQLServerDeploy" -TemplateFile main.bicep -vmName $vm.Name
*/
param vmName string

param sqlManagement string = 'Full'
param sqlServerLicenseType string = 'PAYG'
param leastPrivilegeMode string = 'Enabled'
param autoPatchingSettings object = {
  enable: false
}

param sqlDataFileSettings object = {
  lun:[0] 
  dataPath: 'F:\\data'
}
param sqlLogFileSettings object = {
  lun:[0] 
  logPath: 'F:\\data'
}
param storageWorkloadType string = 'OLTP'
param tempdbSettings object = {
  tempdbPath: 'D:\\tepmdb'
  dataFileCount: 4
  dataFileSize: 8
  dataGrowth: 64
  logFileSize: 8
  logGrowth: 64
}

param serverConfigurationsManagementSettings object = {
  sqlConnectivityUpdateSettings: {
    connectivityType: 'PRIVATE'
    port: 1433
    sqlAuthUpdatePassword: ''
    sqlAuthUpdateUserName: ''
  }
  additionalFeaturesServerConfigurations: {
    isRServicesEnabled: false
  }
  sqlInstanceSettings: {
    maxdop: 0
    isOptimizeForAdHocWorkloadsEnabled: false
    // collation: 'Japanese_CI_AS'
    minServerMemoryMB: 0
    maxServerMemoryMB: 2147483647
    isLPIMEnabled: false
    isIFIEnabled: false
  }

}


resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' existing = {
  name: vmName
}
resource sqlserver 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2023-01-01-preview' = {
  name: vmName
  location: resourceGroup().location
  properties: {
    virtualMachineResourceId: virtualMachine.id
    sqlManagement: sqlManagement
    sqlServerLicenseType: sqlServerLicenseType
    leastPrivilegeMode: leastPrivilegeMode
    autoPatchingSettings: {
      enable: autoPatchingSettings.enable
    }
    keyVaultCredentialSettings: {
      enable: false
      credentialName: ''
    }
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      sqlSystemDbOnDataDisk: false
      enableStorageConfigBlade: true
      storageWorkloadType: storageWorkloadType
      sqlDataSettings: {
        luns: sqlDataFileSettings.lun
        defaultFilePath: sqlDataFileSettings.dataPath
      }
      sqlLogSettings:{
        luns: sqlLogFileSettings.lun
        defaultFilePath: sqlLogFileSettings.logPath
      }
      sqlTempDbSettings: {
        defaultFilePath: tempdbSettings.tempdbPath
        dataFileCount: tempdbSettings.dataFileCount
        dataFileSize: tempdbSettings.dataFileSize
        dataGrowth: tempdbSettings.dataGrowth
        logFileSize: tempdbSettings.logFileSize
        logGrowth: tempdbSettings.logGrowth
      }

    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType:serverConfigurationsManagementSettings.sqlConnectivityUpdateSettings.connectivityType
        port: serverConfigurationsManagementSettings.sqlConnectivityUpdateSettings.port
        sqlAuthUpdatePassword: serverConfigurationsManagementSettings.sqlConnectivityUpdateSettings.sqlAuthUpdatePassword
        sqlAuthUpdateUserName: serverConfigurationsManagementSettings.sqlConnectivityUpdateSettings.sqlAuthUpdateUserName
      }
      additionalFeaturesServerConfigurations: {
        isRServicesEnabled: serverConfigurationsManagementSettings.additionalFeaturesServerConfigurations.isRServicesEnabled
      }
      sqlInstanceSettings: {
        maxDop: serverConfigurationsManagementSettings.sqlInstanceSettings.maxdop
        isOptimizeForAdHocWorkloadsEnabled: serverConfigurationsManagementSettings.sqlInstanceSettings.isOptimizeForAdHocWorkloadsEnabled
        //collation: serverConfigurationsManagementSettings.sqlInstanceSettings.collation
        minServerMemoryMB: serverConfigurationsManagementSettings.sqlInstanceSettings.minServerMemoryMB
        maxServerMemoryMB: serverConfigurationsManagementSettings.sqlInstanceSettings.maxServerMemoryMB
        isLpimEnabled: serverConfigurationsManagementSettings.sqlInstanceSettings.isLPIMEnabled
        isIfiEnabled: serverConfigurationsManagementSettings.sqlInstanceSettings.isIFIEnabled
      }
    }
  }
}
