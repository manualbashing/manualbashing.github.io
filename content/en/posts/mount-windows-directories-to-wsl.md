---
title: "Share Directories between Windows and WSL2"
date: 2022-02-11T15:22:47+01:00
draft: true
---

## The Scenario

- Symlinks only work from Windows to WSL2 not the other way round
- Symlinks will not be followed by git #act/🕵🏻 
- Hardlinking a directory between WSL2 and Windows is not possible.

## The solution

Bind mounts are possible:

```bash
mkdir /home/me/destination
sudo mount --bind /mnt/c/Users/me/source /home/me/destination
```

The problem is that this command requires elevated permissions and needs to be executed everytime the WSL starts.

### Option 1

Put an entry into `/etc/fstab`

WSL (not in my version) will read it on startup


### Option 2

Put an entry into `/etc/wsl.conf`

```text
[boot]
command="mount --bind /mnt/c/Users/me/source /home/me/destination"
```

- If it does not exist, create it.
- Make sure it can be executed (`sudo chmod +x /etc/wsl.conf`)

For `/etc/wsl.conf` to execute commands, you need to be at least on Windows 10 Build 21286.

> Insiders in the Dev channel who want to upgrade to Windows 10 Build 21286  to gain access to this new feature can do so by going into Windows Update and checking for new updates.

Source: [Windows 10 WSL now can run Linux commands on startup](https://www.bleepingcomputer.com/news/microsoft/windows-10-wsl-now-can-run-linux-commands-on-startup/) by @BleepinComputer

