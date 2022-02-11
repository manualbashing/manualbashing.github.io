---
title: "Using bicep to Deploy a Logic App that accesses a Key Vault via managed service identity"
date: 2021-11-19
draft: true
tags: 
 - InfrastructureAsCode
 - LogicApps
 - bicep
 - Azure
---

It is a common (and good) practice to use an [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/) to store any secrets that might be needed when building integrations or fooling around with [Azure Logic Apps](https://docs.microsoft.com/en-us/azure/logic-apps/).

## Access a Key Vault from a Logic App

### Using an user account to access a Key Vault

But how to connect to the key vault? One option is to create an API connection object that allow you to authenticate with an user accout that has sufficient permissions on the key vault.

This has downsides:

- Manual interaction after deployment due to MFA
- Others could use this connection object in Logic Apps that should not have access to this vault

### Using a MSI to access a Key Vault

A good alternative to access a Key Vault from a Logic App is a (system assigned) [managed service identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview). This is currently still a preview feature but already incredibly useful. See more about this here: [Authenticate connections with managed identities - Azure Logic Apps | Microsoft Docs](https://docs.microsoft.com/en-us/azure/logic-apps/create-managed-service-identity).

This site explains well how to enable a MSI in a Logic App using the azure portal.

- But what about bicep?

## Enable a MSI on a Logic App using bicep

```bicep
resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {

 name: logicAppName
 location: location
 identity: {
 type: 'SystemAssigned'
 }
 properties: {}
}
```