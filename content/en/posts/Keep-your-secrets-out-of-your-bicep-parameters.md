---
title: Keep your secrets out of your bicep parameters
date: 2023-11-17T13:37:45
draft: false
tags:
  - bicep
  - Azure
   - InfrastructureAsCode
---
Imagine the following scenario: We have to deploy an Azure Key Vault that comes already populated with a secret, let's say, some third party's API access key. Our bicep file (`azuredeploy.bicep`) could look like this:

```json
param location string = resourceGroup().location
param tenantId string = tenant().tenantId
@secure()
param keyvaultSecretCatfunValue string

var name = 'kv-${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

resource keyvaultSecretCatfun 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'Catfun'
  properties: {
    value: keyvaultSecretCatfunValue
  }
}
```

But how to we deploy this to Azure without entering the secret's value every time we call `az deployment`?

## Loading individual secrets from external files

One trick that worked well for me so far, was to use an external text file, that would be excluded from version control.

For this to work would create a file `Catfun.secret` that contains the API secret and make sure, that it is excluded from version control via `.gitignore`.

This secret would then be loaded by the bicep template as the default value for the  `keyvaultSecretCatfunValue` parameter: 

```json
@secure()
#disable-next-line secure-parameter-default
param keyvaultSecretCatfunValue string = loadTextContent('Catfun.secret')
```

(We have to add `#disable-next-line secure-parameter-default`) to ignore the warning, that secure parameters should not use default values. Our scenario is a reasonable exception to this rule.)

![[vscode-secrets-file.png]]

## Loading several secrets from the same file

If you need to deploy several secrets in a secure way it is not necessary to create a secret file for each. Instead you can save your secrets in a json file, that can be parsed by bicep.

The content of my `MoreSecrets.json`  file looks like this:

```json
{
    "Catfun": "MySuperSecretAPIKey!",
    "Fishfun": "TheSameButBetter##!"
}
```

The file can then be parsed using the `loadJsonContent()` function in bicep:

```json
param location string = resourceGroup().location
param tenantId string = tenant().tenantId
@secure()
#disable-next-line secure-parameter-default
param secrets object = loadJsonContent('MoreFun.secret')

var name = 'kv-${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

resource keyvaultSecretCatfun 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'Catfun'
  properties: {
    value: secrets.Catfun
  }
}

resource keyvaultSecretFishfun 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: 'Fishfun'
  properties: {
    value: secrets.Fishfun
  }
}
```

## Protect your local secret files

So far we have managed to keep our secrets out of version control, but they are still laying around in plain text files, which is not what we want for any type of secret.

One way I like to do this is by encrypting the secrets using the [OpenPGP extension](https://marketplace.visualstudio.com/items?itemName=ugosan.vscode-openpgp) in vscode (`ugosan.vscode-openpgp`). 

This allows me to protect the files that contain the secrets using a private key and passphrase.

![[secrets-gpg-animation.gif]]