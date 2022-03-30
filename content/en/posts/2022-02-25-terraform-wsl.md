---
title: "Issues with Terraform and WSL: Unable to list provider registration status"
date: 2022-02-24T11:03:43+01:00
---

## The problem

Today, something weird happened when I was using terraform in my WSL2 to deploy some infrastructure to Azure. I was initializing terraform, typed:

```bash
terraform plan
```

And... nothing happened.

![10 minutes later](/static/10minuteslater.png)

After waiting a small eternity the following error popped up on my console:

> **Error: Unable to list provider registration status; it is possible that this is due to invalid credentials or the service principal does not have permission to use the Resource Manager API**, Azure error: resources. ProvidersClient#List: Failure sending request: StatusCode=0 -- Original Error: Get "https://management.azure.com/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxx/providers?api-version=2016-02-01%22:" dial tcp: lookup management.azure.com on 172.23.224.1:53: **cannot unmarshal DNS message**

## The cause

What was going on? Apparently, `azurerm`   (Terraform's provider for Azure Resource Manager) tried to resolve the hostname `management.azure.com` and was not happy with the response.

After some excessive googling and GitHub-issue browsing, I finally hit gold: [net: 512 byte DNS response size limit causes an error when making requests to Azure on WSL2 · Issue #51127 · golang/go (github.com)](https://github.com/golang/go/issues/51127#issue-1129393515)

The azurerm provider was written in Golang, and apparently, Golang's net/dns resolver applies a strict 512-byte limit to the response buffer. If the response exceeds that limit, the resolver will not be able to "unmarshal the DNS message".

A quick `dig` affirmed all suspicions:

```bash
❯ dig management.azure.com

; <<>> DiG 9.16.1-Ubuntu <<>> management.azure.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 20748
;; flags: qr rd ad; QUERY: 1, ANSWER: 7, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;management.azure.com.          IN      A

;; ANSWER SECTION:
management.azure.com.   0       IN      CNAME   management.privatelink.azure.com.
management.privatelink.azure.com. 0 IN  CNAME   arm-frontdoor-prod.trafficmanager.net.
arm-frontdoor-prod.trafficmanager.net. 0 IN CNAME germanywestcentral.management.azure.com.
germanywestcentral.management.azure.com. 0 IN CNAME arm-frontdoor-germanywestcentral.trafficmanager.net.
arm-frontdoor-germanywestcentral.trafficmanager.net. 0 IN CNAME germanywestcentral.cs.management.azure.com.
germanywestcentral.cs.management.azure.com. 0 IN CNAME rpfd-germanywestcentral.cloudapp.net.
rpfd-germanywestcentral.cloudapp.net. 0 IN A    51.116.156.32

;; Query time: 40 msec
;; SERVER: 172.18.96.1#53(172.18.96.1)
;; WHEN: Thu Feb 24 21:09:39 CET 2022
;; MSG SIZE  rcvd: 632 👈
```

Indeed, the response size was 632 bytes. **But why did it work in the past?** According to AaronFriel (see link above), Microsoft only recently added additional cnames to their management.azure.com endpoint, pushing the response size over the 512-byte limit.

**Why is this happening only in WSL2?** Per default, WSL2 uses the DNS configuration of the Hyper-V Virtual Network Adapter. This DNS server adds additional data to the ANSWER section of the response: [DNS server mixes AUTHORITY/ADDITIONAL section into ANSWER section while responding to queries · Issue #5806 · microsoft/WSL (github.com)](https://github.com/microsoft/WSL/issues/5806)

## The workaround

What worked for me was forcing WSL2 to use an external DNS resolver like Google (`8.8.8.8`) or UltraDNS (`64.6.64.6`):

```bash
❯ dig management.azure.com @64.6.64.6

; <<>> DiG 9.16.1-Ubuntu <<>> management.azure.com @64.6.64.6
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2007
;; flags: qr rd ra; QUERY: 1, ANSWER: 7, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;management.azure.com.          IN      A

;; ANSWER SECTION:
management.azure.com.   424     IN      CNAME   management.privatelink.azure.com.
management.privatelink.azure.com. 3002 IN CNAME arm-frontdoor-prod.trafficmanager.net.
arm-frontdoor-prod.trafficmanager.net. 40 IN CNAME westeurope.management.azure.com.
westeurope.management.azure.com. 2516 IN CNAME  arm-frontdoor-westeurope.trafficmanager.net.
arm-frontdoor-westeurope.trafficmanager.net. 40 IN CNAME westeurope.cs.management.azure.com.
westeurope.cs.management.azure.com. 742 IN CNAME rpfd-prod-am-01.cloudapp.net.
rpfd-prod-am-01.cloudapp.net. 10 IN     A       13.69.114.0

;; Query time: 40 msec
;; SERVER: 64.6.64.6#53(64.6.64.6)
;; WHEN: Thu Feb 24 21:30:11 CET 2022
;; MSG SIZE  rcvd: 284 👈
```

That brought the response down to a size the resolver in Golang could digest.

The DNS server in WSL2 is configured in the `/etc/resolv.conf`, which WSL2 generates on every boot. Changing anything here will not persist.

You first need to tell WSL2 not to touch the file. Add the following to `/etc/wsl.conf` (if the file does not exist, feel free to create it):

```bash
[network]
generateResolvConf = false
```

Now restart your WSL2 by typing `wsl.exe --shutdown`  in the cmd command prompt. After WSL2 has started again, remove the sad remains of  `/etc/resolv.conf` (it is a symlink now, that does not point anywhere anymore):

```bash
sudo rm /etc/resolv.conf
```

Now add an external nameserver of your choice to the file:

```bash
 echo 'nameserver 64.6.64.6' | sudo tee -a /etc/resolv.conf
```

And that's it! After this change, terraform worked again in WSL2.