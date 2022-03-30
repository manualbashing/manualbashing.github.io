---
title: "Watch out for EOL characters when using the base64 tool with stdin"
date: 2022-03-30T15:11:53+01:00
draft: true
---

In a linux environment the [base64 tool](http://manpages.ubuntu.com/manpages/bionic/man1/base64.1.html)  can be used to base64 encode or decode data. If called directly the tool expects a file path but it is also possible to use stdin. This means we can use `echo` or `printf` together with a pipe to encode (or decode) a string without writing it to a file first.

But be careful which command you use! The same string `'foobar'` will result in a different base64 encoded string, depending on whether `echo` or `printf` was used:

```bash
❯ echo 'foobar' | base64
Zm9vYmFyCg==

❯ printf 'foobar' | base64
Zm9vYmFy
```

But why is that so? The short answer: [echo always adds an end-of-line character to the string](https://linuxhint.com/printf-vs-echo-bash), and this character gets encoded too in the base64 string. 

```bash
❯ echo 'foobar' | od -c
0000000   f   o   o   b   a   r  \n
0000007

❯ printf 'foobar' | od -c
0000000   f   o   o   b   a   r
0000006
```

The end-of-line character is not only added by `echo`. Using the  `<<<` redirection also has this effect.

```bash
❯ encodedString=$( base64 <<< 'foobar' )
❯ base64 --decode <<< $encodedString | od -c
0000000   f   o   o   b   a   r  \n
0000007
```