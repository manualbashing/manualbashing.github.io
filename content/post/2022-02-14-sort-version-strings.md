---
title: "Use PowerShell to sort version strings"
date: 2022-02-14T12:50:28+01:00
draft: false
---

When sorting or comparing version numbers in PowerShell (to determine the latest version of a release, etc.), be careful not to work with plain version strings.

PowerShell sorts strings in a lexical way, which means that it compares strings character by character to determine the sort order. This works well for words: `fool` will come after `foo` but before `fox`.  This does not work well for version strings:

```powershell
❯ '1.0.0', '0.50.0', '0.5.339', '0.6.0' | Sort-Object

0.5.339
0.50.0
0.6.0 👈 
1.0.0
```

## Use the [version] type

In PowerShell version, strings can be cast to the `version` type which does all the heavy lifting parsing version strings into objects:

```powershell
❯ '1.4.56' -as [version]

Major  Minor  Build  Revision
-----  -----  -----  --------
1      4      56     -1
```

The version type has its own comparsion logic already implemented:

```powershell
❯ '0.50.0' -gt '0.6.0' 
False

❯ [version]'0.50.0' -gt [version]'0.6.0' 
True
```

And we can use this for sorting:

```powershell
❯ '1.0.0', '0.50.0', '0.5.339', '0.6.0' | Sort-Object { $_ -as [version]  }

0.5.339
0.6.0 👈
0.50.0
1.0.0
```

## Sort version strings with postfix

This method will not work if the version string has a postfix like `-preview`: 

```powershell
❯ '1.0.0', '0.50.0', '0.5.339', '0.6.0-preview' | Sort-Object { $_ -as [version]  }

0.6.0-preview 👈
0.5.339
0.50.0
1.0.0
```

This happens because the string `0.6.0-preview` fails the cast to `[version]`, so `Sort-Object` has no idea what to do with it. (Depending on your PowerShell version the last command might cause an exception. In my version 7.2.1 it fails silently.)

One way to work around this issue is to use a regex to strip the postfix from the version string before casting it to `[version]`.

```powershell
❯ '1.0.0', '0.50.0', '0.5.339', '0.6.0-preview', '0.6.0', '0.6.0-lts' | 
  Sort-Object { ($_ -replace '-.+$') -as [version]  }

0.5.339
0.6.0-preview 👈
0.6.0
0.6.0-lts 👈
0.50.0
1.0.0
```

But here we see a new problem: there is no inner sort for the same version number with different postfixes. This happens in our example, because `Sort-Object` never gets to see the postfix.

Fortunately `Sort-Object` allows us to specify an inner sort using a second scriptblock:

```powershell
❯ '1.0.0', '0.50.0', '0.5.339', '0.6.0-preview', '0.6.0', '0.6.0-lts' | 
  Sort-Object { ($_ -replace '-.+$') -as [version]  }, { $_ }

0.5.339
0.6.0
0.6.0-lts
0.6.0-preview
0.50.0
1.0.0
```