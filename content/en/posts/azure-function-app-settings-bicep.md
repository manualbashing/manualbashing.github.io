---
title: "Azure Function App Settings Bicep"
date: 2022-03-08T18:04:31+01:00
draft: true
---

```json
union(list('${functionApp.id}/config/appSettings', '2020-12-01').properties, newSetting)
```

[ARM template should not delete and replace application settings for a function app · Issue #11718 · Azure/azure-cli (github.com)](https://github.com/Azure/azure-cli/issues/11718)

Module is needed to solve circular dependency problem.

```json
// file: modules\function_app_settings.bicep
param functionAppName string
param currentAppSettings object
param appSettings object

resource siteconfig 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${functionAppName}/appsettings'
  properties: union(currentAppSettings, appSettings)
}

// file: main.bicep
module functionAppSettings 'modules/function_app_settings.bicep' = {
  name: 'functionAppSettingsDeployment'
  params: {
    functionAppName: functionAppName
    currentAppSettings: list('Microsoft.Web/sites/${functionAppName}/config/appsettings', '2020-06-01').properties
    appSettings: {
      AZURE_KEY_VAULT_URI: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}'
      AzureWebJobsStorage: storage.outputs.storageConnectionString
      FUNCTIONS_EXTENSION_VERSION: '~3'
    }
  }
}
```