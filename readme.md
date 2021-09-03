aicloud

At a high level, this project creates aicloud infrastructure using ansible (.. heavy usage on NVIDIA's deepops)

`libvirt-infrastructure/` is able to setup testing and staging environments
`infrastructure/` digital ocean testing environments

## Getting started

A staging environment in just a few minuttes:

```
cd libvirt-infrastructure; terraform apply
cd ansible; ansible-playbook -f 10 -i libvirt-inventory slurm.yml
```