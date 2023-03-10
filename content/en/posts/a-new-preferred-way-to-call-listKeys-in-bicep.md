---
title: "A new preferred way to call listKeys() in bicep"
date: 2023-03-10T11:45:00+01:00
tags: 
 - InfrastructureAsCode
 - bicep
 - Azure
draft: false
---

After upgrading to `Bicep CLI version 0.15.31 (3ba6e06a8d)` I got a linter warning in one of my bicep files:

> Use a resource reference instead of invoking function "listKeys". This simplifies the syntax and allows Bicep to better understand your deployment dependency graph.bicep core [https://aka.ms/bicep/linter/use-resource-symbol-reference](https://aka.ms/bicep/linter/use-resource-symbol-reference)

The offensive line was where I am reading the access key from a log analytics workspace:

```json
listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
```

Unfortunately the URL in the linter message did not resolve to any help page but redirected me to bing instead. 

So I tried my best guess as to what the linter tried to tell me and I got lucky:

```json
logAnalyticsWorkspace.listKeys().primarySharedKey
```

[primarySharedKeyNew.bicep](https://gist.github.com/manualbashing/f7e6a388e4089f93063232c2927bb8e4)

The linter warning disappeared and my deployment continued to work just fine.

This syntax is indeed easier to read. I had no idea, that it was possible to use methods on symbolic references. 