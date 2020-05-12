Connect-AzAccount
$subscriptionId = ""
$resourceGroup = ""
$actionGroupName = ""
$activityLogAlertName = ""

Select-AzSubscription -Subscription $subscriptionId

$jsonTemplate = @"
{
    "`$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "activityLogAlertName": {
        "type": "string",
        "metadata": {
          "description": "Unique name (within the Resource Group) for the Activity log alert."
        }
      },
      "actionGroupResourceId": {
        "type": "string",
        "metadata": {
          "description": "Resource Id for the Action group."
        }
      }
    },
    "resources": [   
      {
        "type": "Microsoft.Insights/activityLogAlerts",
        "apiVersion": "2017-04-01",
        "name": "[parameters('activityLogAlertName')]",
        "location": "Global",
        "properties": {
          "enabled": true,
          "scopes": [
              "[subscription().id]"
          ],        
          "condition": {
            "allOf": [
              {
                "field": "category",
                "equals": "ResourceHealth"
              },
              {
                "field": "status",
                "equals": "Active"
              }
            ]
          },
          "actions": {
            "actionGroups":
            [
              {
                "actionGroupId": "[parameters('actionGroupResourceId')]"
              }
            ]
          }
        }
      }
    ]
  }
"@


$actionGroup = Get-AzActionGroup -ResourceGroupName $resourceGroup -Name $actionGroupName
$tempFile = New-TemporaryFile 
$jsonTemplate | Out-File $tempFile -Force
$templateParameter = @{
    activityLogAlertName = $activityLogAlertName
    actionGroupResourceId = $actionGroup.Id
}

New-AzResourceGroupDeployment -Name "ResourceHealth" -ResourceGroupName  $resourceGroup -TemplateFile $tempFile.FullName -TemplateParameterObject $templateParameter


Remove-Item -Path $tempFile.FullName