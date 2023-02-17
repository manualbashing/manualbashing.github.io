---
title:  "How to restore or purge a soft-deleted Azure API management service instance"
date: 2022-02-10
tags:
  - APIM
  - AzureCLI
---

> **Edit 2023-02-17**: The approach described below is not necessary anymore. Current versions of *azure CLI* (f.e. 2.45.0+) provide commands to identify and remove soft deleted apim instances:
> 
>- List: `az apim deletedservice list`
>- Remove: `az apim deletedservice purge --service-name "{name}" -l {location}`
>
>See here for more information: [az apim deletedservice](https://learn.microsoft.com/en-us/cli/azure/apim/deletedservice?view=azure-cli-latest)

Starting with REST API version, `2020-06-01-preview` , Microsoft introduced the soft-delete feature to API Management service (APIM) (See: [Azure API Management soft-delete (preview) | Microsoft Docs](https://docs.microsoft.com/en-us/azure/api-management/soft-delete))

Deleting an APIM using the REST API version `2020-06-01-preview` or higher will not obliterate the service but put it into the soft-delete state. It can be restored or purged (deleted forever) from this state. If nothing is done, the APIM will purge itself after a specific time.

![](/static/apim-meme.jpg)

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
subscriptionId=$(az account show --query id --output tsv)
location="{ location of the APIM} "
resourceGroupName="{ name of the resource group where the APIM resides }"

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
subscriptionId=$(az account show --query id --output tsv)
location="{ location where the APIM resides }"

# Here comes the actual call to the api to purge the APIM instance
az rest \
  --method DELETE \
  --header "Accept=application/json" \
  --uri "https://management.azure.com/subscriptions/${subscriptionId}/providers/Microsoft.ApiManagement/locations/${location}/deletedservices/${apimName}?api-version=2021-08-01"
```

Source: [Azure API Management soft-delete (preview) | Microsoft Docs](https://docs.microsoft.com/en-us/azure/api-management/soft-delete#purge-a-soft-deleted-instance)

## Derive parameter values from the context

Instead of setting all the required parameters manually, you can actually derive them from the context, if you specify the name of the APIM instance.

```bash
apimName="{ name of the APIM instance }"
subscriptionId=$(az account show --query id --output tsv)
apimObj=$(az rest \
  --method GET \
  --header "Accept=application/json" \
  --uri "https://management.azure.com/subscriptions/${subscriptionId}/providers/Microsoft.ApiManagement/deletedservices?api-version=2021-08-01" \
  --query "value[?name == '${apimName}']")

# location will be converted to lowercase without spaces
location=$(echo $apimObj |
  jq -r '.[].location' |
  sed -e 's/./\L&/g' -e 's/ //g')

resourceGroupName=$(
  echo $apimObj |
  jq -r '.[].properties.serviceId' |
  sed -E 's|.*resourceGroups/([^/]+).*|\1|g')
```
