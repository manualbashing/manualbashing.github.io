---
title:  "How to restore or purge soft-deleted Azure API management services"
date: 2022-02-10
tags:
  - APIM
  - AzureCLI
---

Starting with REST API version, `2020-06-01-preview` , Microsoft introduced the soft-delete feature to API Management service (APIM) (See: [Azure API Management soft-delete (preview) | Microsoft Docs](https://docs.microsoft.com/en-us/azure/api-management/soft-delete))

Deleting an APIM using the REST API version `2020-06-01-preview` or higher will not obliterate the service but put it into the soft-delete state. It can be restored or purged (deleted forever) from this state. If nothing is done, the APIM will purge itself after a specific time.

No need to mention that this is a valuable feature, but it has downsides too, that have caused people headaches: [APIM gets stuck in soft-delete state · Issue #16138 · Azure/azure-cli (github.com)](https://github.com/Azure/azure-cli/issues/16138)

As far as I see it, the problem lies in a combination of three factors:

1. Once soft-deleted, the name of the APIM is still reserved, and attempts to deploy an APIM with the same name will fail.
2. Functionality to manage soft-deleted APIM instances has not yet (10th of Feb. 2022) been added to neither azure CLI nor the Azure portal.
3. Deleting an APIM from the Azure Portal by either deleting it directly or removing its resource group will put it into the soft-delete state.

So far, the only way to manage a soft-deleted APIM is the Azure REST API: [Deleted Services - REST API (Azure API Management) | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/apimanagement/current-ga/deleted-services)

Fortunately, the Azure REST API can be called directly from the Azure CLI using the `az rest` namespace: [az | Microsoft Docs](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-rest)

Here are some examples of how to manage soft-deleted APIM instances using the Azure REST API with Azure CLI:

## List all soft-deleted instances

```bash
  subscriptionId=$(az account show --query id --output tsv)
  az rest \
    --method GET \
    --header "Accept=application/json" \
    --uri "https://management.azure.com/subscriptions/${subscriptionId}/providers/Microsoft.ApiManagement/deletedservices?api-version=2021-08-01"
```

Source: [Deleted Services - List By Subscription - REST API (Azure API Management) | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/apimanagement/current-ga/deleted-services/list-by-subscription)

## Restore a soft-deleted instance

```bash
apimName="{ name of the APIM instance that you want to restore }"

# we will try to derive the remaining parameters from context
subscriptionId=$(az account show --query id --output tsv)
apimObj=$(az rest \
  --method GET \
  --header "Accept=application/json" \
  --uri "https://management.azure.com/subscriptions/${subscriptionId}/providers/Microsoft.ApiManagement/deletedservices?api-version=2021-08-01" \
  --query "value[?name == '${apimName}']")
location=$(echo $apimObj | jq -r '.[].location')
resourceGroupName=$(
  echo $apimObj |
  jq -r '.[].properties.serviceId' |
  sed -E 's|.*resourceGroups/([^/]+).*|\1|g')


# Here comes the actual call to the api to restore the APIM instance
az rest \
  --method PUT \
  --header "Accept=application/json" \
  --uri "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.ApiManagement/service/${apimName}?api-version=2021-08-01" \
  --body "{\"location\":\"${location}\",\"properties\": {\"restore\" : true} }"
}
```

Source: [Api Management Service - Create Or Update - REST API (Azure API Management) | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/apimanagement/current-ga/api-management-service/create-or-update)

## Purge a soft-deleted instance

```bash
apimName="{ name of the APIM instance that you want to purge }"

# we will try to derive the remaining parameters from context
subscriptionId=$(az account show --query id --output tsv)
apimObj=$(az rest \
  --method GET \
  --header "Accept=application/json" \
  --uri "https://management.azure.com/subscriptions/${subscriptionId}/providers/Microsoft.ApiManagement/deletedservices?api-version=2021-08-01" \
  --query "value[?name == '${apimName}']")
location=$(echo $apimObj | jq -r '.[].location')
resourceGroupName=$(
  echo $apimObj |
  jq -r '.[].properties.serviceId' |
  sed -E 's|.*resourceGroups/([^/]+).*|\1|g')


# Here comes the actual call to the api to purge the APIM instance
az rest \
  --method DELETE \
  --header "Accept=application/json" \
  --uri "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.ApiManagement/service/${apimName}?api-version=2021-08-01"
```

Source: [Azure API Management soft-delete (preview) | Microsoft Docs](https://docs.microsoft.com/en-us/azure/api-management/soft-delete#purge-a-soft-deleted-instance)