---
title: "How to export csv watchlists from Azure Sentinel"
date: 2023-03-09T15:30:37+02:00
draft: false
tags: 
 - Azure
 - Sentinel
---

Azure Sentinel is Microsoft's *Security Information and Event Management* (SIEM) tool, that helps to identify security threats and to respond quickly when they occur.  One could say that it is an organization's enhanced ears and eyes, like.. you know:

[![The Sentinel](/static/the-sentinel.png)](https://en.wikipedia.org/wiki/The_Sentinel_(TV_series))

Sentinel supports so called watchlists. Watchlists are csv files, that add custom information to the assets that you want to monitor closely. 

Creating and uploading watchlists is a piece of cake and can be done in the Azure Portal: [Create watchlists - Microsoft Sentinel | Microsoft Learn](https://learn.microsoft.com/en-us/azure/sentinel/watchlists-create).

But what if you need to download an existing watchlist? This appears to be unreasonably difficult. At the time of this writing there is no download button in the Azure Portal. And the [Azure CLI extention for Sentinel](https://learn.microsoft.com/en-us/cli/azure/service-page/microsoft%20sentinel?view=azure-cli-latest) doesn't offer this option either.

Fortunately the Azure Management REST API allows us to work around this limitation.

## Export csv watchlists using the REST API

There is an API method, that allows us to list the contents of the Sentinel watchlists in JSON format: [Watchlist Items - List - REST API (Azure Sentinel) | Microsoft Learn](https://learn.microsoft.com/en-us/rest/api/securityinsights/preview/watchlist-items/list?tabs=HTTP).

The only thing we need to do is to translate this output into the schema of the CSV files that Sentinel supports. This can be done with the following PowerShell cmdlet. 

{{< gist manualbashing d52f7a74e03a2942628caa45fe3c8f65 >}}

[Export-SentinelWatchlist.ps1](https://gist.github.com/manualbashing/d52f7a74e03a2942628caa45fe3c8f65)

To run this cmdlet the following requirements need to be met:

- It needs to be run in PowerShell Core
- The Az PowerShell module is installed
- You are connected to the correct Azure subscription with the Az PowerShell module (Run `Get-AzContext` to check).

You can run this cmdlet for example like this: 

```powershell
. ./Export-SentinelWatchlist.ps1 # dotsourcing the file that contains the cmdlet
Export-SentinelWatchlist -ResourceGroupName 'rg-sentinel' -WorkspaceName 'sws-sentinel-workspace' -WatchlistName 'Customer'
```


