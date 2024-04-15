---
title: Decode any PowerShell Secure String on Linux
date: 2024-04-09
draft: false
tags:
  - PowerShell
---

This is not a big deal, as *secure strings* are not encrypted under Unix systems. The password will instead be obfuscated as hexadecimal representation of the string's bytes.

According to [a user on reddit](https://www.reddit.com/r/PowerShell/comments/dtggfn/comment/f6wmpfu/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button), converting a string to a *secure string* it is basically doing this:

```powershell
[BitConverter]::ToString([Text.Encoding]::Unicode.GetBytes('foo')).Replace('-','')
```

This can be demonstrated in the following way:

```powershell
$password = "foo"
$secureString = $password | ConvertTo-SecureString -AsPlainText -Force
$serializedSecureString = $secureString | ConvertFrom-SecureString
$byteArray = [byte[]] -split ($serializedSecureString -replace '..', '0x$& ')
$utf8 = [Text.Encoding]::UTF8
$decodedPassword = $utf8.GetString($byteArray)

Write-Host "Password: $password | Decoded Password: $decodedPassword"
```

On Windows this will not lead to a useful value for `$decodedPassword`, as Windows systems encrypt the *secure string* based on the profile of the current User and Host. On Linux the value for `$password` and `$decodedPassword` will be identical.

So better find another way to store your automation secrets on Linux or even better: avoid them alltogether by using certificates or managed identities if possible.