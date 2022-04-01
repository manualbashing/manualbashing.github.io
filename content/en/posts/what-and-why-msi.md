---
title: "What is a MSI and why should you care?"
date: 2022-04-01T17:44:37+02:00
draft: true
tags: 
 - ManagedServiceIdentity
 - Azure
 - AzureAD
---

## What is a MSI?

A [Managed Service Identity (MSI)](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) is a method to provide access between Azure resources. A MSI uses Azure AD authentication but does not require management of any accounts or credentials.

When enabling a system-assigned MSIs (the only type of MSI we want to talk about in this post) on a service like a Logic App, an identity for this service gets created in Azure AD. Like users or service principals this identity can be used for [RBAC role assignments](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview).
**For example**: instead of providing credentials to a Logic App that would allow this app full access to my Azure Key Vault, I can enable a MSI on this Logic App and assign this MSI reading access to my Key Vault secrets. 

## Why using a MSI in a Logic App?

The default way to connect to a service from an Azure Logic App is to create an API connection object resource  on Azure that will store the connection to the service in question.

In most cases this requires an Azure AD user to manually connect the API connections via Azure Portal.

This can become cumbersome if a solution uses serveral API connections, as each needs to manually connected at least once after initial deployment.