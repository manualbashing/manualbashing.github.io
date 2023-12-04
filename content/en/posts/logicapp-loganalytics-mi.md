---
title: " Query Azure Log Analytics from Logic App using Managed Identity"
date: 2022-04-01T17:15:55+02:00
draft: false
tags: 
 - LogicApps
 - bicep
 - Azure
 - ManagedServiceIdentity
 - LogAnalytics
---

While [Azure Log Analytics Workspaces](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) supports access using a [Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) (formally known as: Managed Service Identity, MSI), the official [Logic Apps connector for Azure Log Analytics (Azure Monitor Logs)](https://docs.microsoft.com/en-us/azure/azure-monitor/logs/logicapp-flow-connector) does not.

> **Edit 2023-12-04**:  The Logic App connctor for Azure Log Analytics supports managed identities now. So the following workaround is no longer needed.

As a  workaround queries to a Log Analytics Workspace can also be send directly to the [Azure REST API](https://docs.microsoft.com/en-us/rest/api/loganalytics/), as the built-in HTTP connector in Logic Apps supports Managed  Identities.

![](/static/logicapp-workspace-msi.png)

> ⌨️ **Example**
> 
> I have added a minimal example to my bicep-snippets repository: [bicep-snippets/logicapp-msi-workspace at mother · manualbashing/bicep-snippets (github.com)](https://github.com/manualbashing/bicep-snippets/tree/mother/logicapp-msi-workspace)