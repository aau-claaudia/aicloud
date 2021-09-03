# libvirt-infrastructure

This project will take one of Claaudia's T4 machines and slice it up into multiple VM's for testing and development

How to connect to these T4 machines is left as an exercise for the reader, but the included code expects a socket to the remote libvirtd locally
at `~/.ssh/libvirtd-sock`

Other then that, running `terraform apply` should end up with 8 new machines ready for ansible deployment. Once finished, the
cluster is described in `../ansible/libvirt-inventory` and should be ready to go.