az acr build  --resource-group <Resource Group> --registry <ACR Name> --image ddagent:7.52.0 <Dockerfile Path>


az container create `
    --resource-group <Resource Group> `
    --name ddagent `
    --image <ACR Name>.azurecr.io/ddagent:7.52.0 `
    --cpu 1 --memory 1 `
    --registry-login-server $AcrLoginServer `
    --registry-username  $AcrUserName `
    --registry-password  $AcrUserPassword `
    --environment-variables `
    "DD_API_KEY=<Datadog API Key>" `
    "DD_HOSTNAME=ddagent" `
    "DD_SERVER=<SQL Database Server Name>" `
    "DD_DATABASE=<Database Name>" `
    "DD_USER=<Database Login>" `
    "DD_USER_PASSWORD=<Login Password>" `
    --azure-file-volume-account-name "<Azure File Share>" `
    --azure-file-volume-account-key "<Account Key>" `
    --azure-file-volume-share-name "<Share Name>" `
    --azure-file-volume-mount-path "/etc/datadog-agent/conf.d/"
