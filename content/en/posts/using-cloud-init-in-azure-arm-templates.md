---
layout: post
title:  "Azure ARM Templates and cloud-init"
date:   2021-06-24 11:13:00 -0500
draft: true
tags: 
- IaC Azure
---

## Why cloud-init for Linux VMs on Azure?

> **TLDR**: ARM template define VMs only as resources. They are limited in defining what happens inside of the vm. cloud-init is a well established tool that allows the initial configuration of VMs with using a descriptive syntax.

Deploying a Linux VM using Azure ARM or bicep template is a common task und pretty straight forward. So why would you need to use any other tool? 

An ARM or bicep template allows you to describe something on the resource level. When you deploy a vm, you not only set name and size of your vm, you also describe how  it relates to dependent infrastructure like virtual networks, managed disks, maybe a public IP address and so on. 

When it comes to the inside world of a VM, ARM/bicep templates are very limited. You can specify things like, the OS image, the name of the administrative user, that you want to use to connect to the VM and have ssh set up for administrative access.

What you can not do in an ARM template directly is describing the software packages, that should be installed, the configuration files that should be created within the system, and so on. So how do you do this? There are several options:

- Use a custom script extension and execute a configuration script
- Use a configuration management tool like ansible or chef
- Build a custom image for your vm with everything preinstalled
- Use cloud-init with a cloud-config file

These are all valid approaches in the right context and I want to deal with them separately in later posts. Right now we will focus on cloud-init, as it has some advantages when deploying Linux VMs:

- well-established
- allows not only the execution of imperative scripts but also the use of a cloud-config file that uses a descriptive approach.
- Supported with azure cli and ARM/bicep templates

[Overview of cloud-init support for Linux VMs in Azure - Azure Virtual Machines | Microsoft Docs](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init)

## Passing the cloud-init data to ARM/bicep

[Custom Data and Cloud-Init on Microsoft Azure | Azure Blog and Updates | Microsoft Azure](https://azure.microsoft.com/en-us/blog/custom-data-and-cloud-init-on-windows-azure/)


```json
"osProfile": {
    "computerName": "manualbashing",
    "customData": "[parameters('cloudInitDataBase64')]"
}
```

There is a quickstart template that illustrates how to pass in script code directly: [azure-quickstart-templates/101-vm-customdata (github.com)](https://github.com/Azure/azure-quickstart-templates/tree/master/101-vm-customdata)

## Passing the data in directly

When do you want to do that? 

- Only if the data doesn't change. 
- Otherwise you loose flexibility. 
- Am ARM-Template cannot be redeployed (as part of a CI/CD pipeline) if the `customData` property changes.

```json
"osProfile": {
    "computerName": "redis",
    "customData": "[parameters('cloudInitDataBase64')]",
    "adminUsername": "[parameters('adminUsername')]",
    "linuxConfiguration": {
        "disablePasswordAuthentication": true,
        "ssh": {
            "publicKeys": [
                {
                    "path" :  "[concat('/home/', parameters('adminUsername'), '/.ssh/authorized_keys')]",
                    "keyData": "[parameters('sshPublicKey')]"
                }
            ]
        }
    }
}
```

- It is possible to use the base64 template function in ARM template
- Watch out for line breaks when passing custom data in as parameter!
- In bash use `\n` 
- In powershell `` `n``
- More save to convert to base64 outside of the template?

## Pass in the reference to a cloud-init file

- Configuration can change without creating errors in the CI/CD pipeline

## Hand off configuration management to ansible

```yaml
#cloud-config
packages:
  - python-pip
runcmd:
  - sudo pip install ansible[azure]
```