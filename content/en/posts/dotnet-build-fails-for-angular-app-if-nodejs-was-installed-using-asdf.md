---
title:  "dotnet build would fail for an angular app if nodejs were installed using asdf"
date:   2021-06-24
tags:
  - dotnet
---

I was creating a new angular project using a template via [dotnet cli](https://docs.microsoft.com/en-us/dotnet/core/tools/) today:

```bash
dotnet new angular
```
 
Id did not have Node.js installed, so I installed it using [asdf](https://asdf-vm.com/): 

```bash
asdf plugin add nodejs
asdf install nodejs latest
```

This successfully installed Node.js `v16.4.0`. But when I tried to build the example project using `dotnet build`, I ran into the following error:

```bash
❯ dotnet build

Microsoft (R) Build Engine version 16.7.2+b60ddb6f4 for .NET
Copyright (C) Microsoft Corporation. All rights reserved. 

 Determining projects to restore...

 All projects are up-to-date for restore.

 foo -> /home/mbatsching/git/foo/bin/Debug/netcoreapp3.1/foo.dll
 foo -> /home/mbatsching/git/foo/bin/Debug/netcoreapp3.1/foo.Views.dll

 No version set for command node

 Consider adding one of the following versions in your config file at
 nodejs 16.4.0

/home/mbatsching/git/foo/foo.csproj(28,5): warning MSB3073: The command "node --version" exited with code 126.

/home/mbatsching/git/foo/foo.csproj(28,5): warning MSB4181: The "Exec" task returned false but did not log an error.

/home/mbatsching/git/foo/foo.csproj(31,5): error : Node.js is required to build and run this project. To continue, please install Node.js from https://nodejs.org/, and then restart your command prompt or IDE.
```

No version set for command `node`?  That error is produced by the shim that asdf creates for the node executable. It needs to know which version of Node.js should be used in the current project.

This can be done by creating a file named `.tool-versions` in the project root and adding the Node.js version that should be used. In my case, the content of this file looked like this:

```text
nodejs 16.4.0
```

After creating this file, the `dotnet build` command was executed without issues.

You can learn more about the `.tool-versions` configuration file here: [Configuration (asdf-vm.com)](https://asdf-vm.com/#/core-configuration?id=tool-versions)

> 🧐**And by the way**
> 
> [asdf](https://www.youtube.com/watch?v=kcNpBNpvyc4&t=258s&ab_channel=TomSkaTomSkaVerified) is also the name of a legendary series of animated short films by TomSka.
> ![asdf pointless](/static/asdf.gif)