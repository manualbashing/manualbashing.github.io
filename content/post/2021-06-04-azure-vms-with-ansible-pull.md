---
layout: post
title:  "Managing Azure VMs with Ansible Pull"
date:   2021-06-04 11:30:00 -0500
draft: true
---

## What is Ansible-Pull?

## Execute a specific playbook

```bash
 ansible-pull -U "{ repository URL }" "{ path to the playbook }"
```

Provide Token if needed.

Github:
Azure Repos: ``

The path to the playbook needs to be given relative to the root of the repository that you are checking out. E.g. `/cd/infra/ansible/redis.yml`

If the path is not provided, ansible will check for the the following files in the root of the repository:

- `$(hostname).yml` The hostname of the vm (like `vm123`)
- `$(hostname -A).yml` The fqdn of the vm (like `vm123.cloudapp.com`)
- `local.yml`

c   