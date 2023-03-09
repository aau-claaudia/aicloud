aicloud

At a high level, this project creates aicloud infrastructure using ansible

## Whats in here

`ansible/`

This directory holds the ansible playbook and logic for setting up the cluster. By far, the largest part of this logic is contributed by [nvidia's deepops](https://github.com/NVIDIA/deepops) which does pretty much all the slurm configuration with a few minor tweeks.

`libvirt-infrastructure/` 

This directory holds terraform code for creating a libvirt cluster. This is able to setup testing and staging environments.

`infrastructure/` 

This directory holds terraform code for creating a staging environment on digital ocean - it is not maintained. 

## General design
This project tries its best not to create any valuable state on the environments it creates. For example - we dont use the slurm user management for anything. Instead users are managed by a few idap groups which allows them to login and some are privileged and prioritezed over other users.

In theory this should allow us to do disaster recovery without having to resort to backups - in that case, the only thing missing is historical usage statistics.

## User data
Home directories are mounted on `/home` using cephfs on all nodes.

## Working on aicloud
The usual development pattern for working on aicloud goes something like this:

* Using libvirt-infrastructure and ansible - create an environment identical to the actural aicloud
* Do whatever task desired - check the ansible against newly created environment
* Once sufficiently confident in the changes, apply the changes to the actual aicloud


## Getting started

A staging environment in just a few minuttes:

```
cd libvirt-infrastructure; terraform apply
cd ansible; ansible-playbook -f 10 -i libvirt-inventory slurm.yml
```