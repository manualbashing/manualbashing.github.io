---
title: "dotnet SDK not found in VSCode Dev Container Ubuntu Jammy (22.04)"
date: 2022-08-24T14:37:45+02:00
draft: false
---

A couple of days ago, some of my [vscode dev containers](https://code.visualstudio.com/docs/remote/containers) suddenly failed to build. Here is a minimal example:

```Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:0-jammy

SHELL ["/bin/bash", "-lc"]

RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb -q \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb

RUN apt update \
  && apt install -y --no-install-recommends dotnet-sdk-6.0

RUN dotnet tool install -g Microsoft.dotnet-interactive
```

This was working fine before, but now I got the following error message:

```text
Step 5/5 : RUN dotnet tool install -g Microsoft.dotnet-interactive
 ---> Running in 52e362723554
The command could not be loaded, possibly because:
  * You intended to execute a .NET application:
      The application 'tool' does not exist.
  * You intended to execute a .NET SDK command:
      No .NET SDKs were found.
```

As far as I understood the problem here is, that the `dotnet-sdk-6.0` package and its dependencies are now available in both, the Ubuntu and the Microsoft repository, but their install locations are different. This will mess up the installation, if packages are picked from both feeds.

See here for more information: 
- [[Ubuntu 22.04] dotnet doesn't find installed SDKs · Issue #27082 · dotnet/sdk · GitHub](https://github.com/dotnet/sdk/issues/27082)
- [Installing .NET 6 on Ubuntu 22.04 (Jammy) · Issue #7699 · dotnet/core · GitHub](https://github.com/dotnet/core/issues/7699)

A workaround to this issue is to use apt's [pinning mechanism](https://help.ubuntu.com/community/PinningHowto) to set the Microsoft feed as the preferred repository. This means apt will try to install a package from the Microsoft feed first and then fall back to the distribution repository, if the package is not available.

To configure a preference, create a file called `apt-preference` in your `.devcontainer` folder and add the following content:

```text
Package: *
Pin: origin "packages.microsoft.com"
Pin-Priority: 1001
```

Then add a copy statement to your Dockerfile to use this file as your configuration for apt pins.

```Dockerfile
FROM mcr.microsoft.com/vscode/devcontainers/base:0-jammy

SHELL ["/bin/bash", "-lc"]

RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb -q \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb

COPY ./apt-preferences /etc/apt/preferences

RUN apt update \
  && apt install -y --no-install-recommends dotnet-sdk-6.0

RUN dotnet tool install -g Microsoft.dotnet-interactive
```