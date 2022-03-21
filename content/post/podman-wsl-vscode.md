---
title: "Podman Wsl Vscode"
date: 2022-03-01T10:17:31+01:00
draft: true
---


[Using podman instead of docker on Windows Subsystem for Linux (WSL 2) - DEV Community](https://dev.to/bowmanjd/using-podman-on-windows-subsystem-for-linux-wsl-58ji)

[Use VS Code to develop in containers | Opensource.com](https://opensource.com/article/21/7/vs-code-remote-containers-podman)

[containers/podman-compose: a script to run docker-compose.yml using podman (github.com)](https://github.com/containers/podman-compose)

```bash
pip3 install podman-compose --user
```

![[Pasted image 20220301101836.png]]



[Using podman with the Docker extension for Visual Studio Code | by y0n1 | Medium](https://y0n1.medium.com/using-podman-with-the-docker-extension-for-visual-studio-code-a828be26d285)


> The missing part of the puzzle
> ==============================
> 
> So, great! I don’t need to install Docker however, the Docker extension for Visual Studio Code expects Docker to be installed on your OS. Fortunately enough we can trick the extension to use Podman instead of Docker. All you have to do is first, enable and activate the podman.socket
> 
> systemctl --user enable --now podman.socket
> 
> second, add the following configuration in the extension settings:
> 
> unix:///run/user/1000/podman/podman.sock
> 
> The number 1000 corresponds to your uid (user id) which can be obtained executing id -u from the terminal.

Source: [Using podman with the Docker extension for Visual Studio Code](https://y0n1.medium.com/using-podman-with-the-docker-extension-for-visual-studio-code-a828be26d285) by y0n1