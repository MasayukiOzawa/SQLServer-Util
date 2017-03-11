# https://github.com/Azure/azure-powershell/releases

$ContainerName = "managed-backup"

Add-AzureAccount
$Subscription = Get-AzureSubscription | Out-GridView -OutputMode Single
$Subscription | Select-AzureSubscription -Current
$StorageAccount = Get-AzureStorageAccount | Out-GridView -OutputMode Single
$context = New-AzureStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey (Get-AzureStorageKey -StorageAccountName $StorageAccount.StorageAccountName).Primary

if ((Get-AzureStorageContainer -Name $ContainerName -Context $context -ErrorAction SilentlyContinue) -eq $null){
    New-AzureStorageContainer -Name $ContainerName -Context $context
}

Write-output $StorageAccount.StorageAccountName
Write-Output (Get-AzureStorageKey -StorageAccountName $StorageAccount.StorageAccountName).Primary
New-AzureStorageContainerSASToken -Name $ContainerName  -Permission rwdl  -ExpiryTime "2050/1/1" -FullUri -Context $context
