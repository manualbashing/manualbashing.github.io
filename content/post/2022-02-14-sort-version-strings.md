---
title: "Use PowerShell to sort version strings"
date: 2022-02-14T12:50:28+01:00
draft: false
---

When sorting or comparing version numbers in PowerShell (to determine the latest version of a release, etc.), be careful not to work with plain version strings.

PowerShell sorts strings in a lexical way, which means that it compares strings character by character to determine the sort order. This works well for words: `fool` will come after `foo` but before `fox`.  This does not work well for version strings:

```powershell
❯ '1.0.0', '0.5.0-preview', '0.50.0', '0.5.339', '0.6.0' | sort

0.5.0-preview
0.5.339
0.50.0
0.6.0 👈 
1.0.0
```

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
❯ '1.0.0', '0.5.0-preview', '0.50.0', '0.5.339', '0.6.0' | sort { $_ -as [version]  }

0.5.0-preview
0.5.339
0.6.0 👈
0.50.0
1.0.0
```
