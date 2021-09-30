terraform {
    required_version = ">= 0.13"
        required_providers {
        libvirt = {
            source  = "dmacvicar/libvirt"
            version = "0.6.10"
        }
    }
}

locals {
  libvirtd-sock = pathexpand("~/.ssh/libvirtd-sock")
}

# instance the provider
# Notice that, this plugin uses its own ssh implementation which does not at all
# support .ssh/config and whatever might be configured in there
# .... instead, we will just be forwarding it to our self:
# ssh AICLOUD-STAGING -L/home/fas/.ssh/libvirtd-sock:/run/libvirt/libvirt-sock
provider "libvirt" {
    uri = "qemu+unix:///system?socket=${local.libvirtd-sock}"
}

data "template_file" "user_data" {
    template = file("${path.module}/cloud_init.cfg")
}

# cloudinit iso
resource "libvirt_cloudinit_disk" "commoninit" {
    name           = "commoninit.iso"
    user_data      = data.template_file.user_data.rendered
    pool           = "default"
}

# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "ubuntu-focal" {
    name   = "ubuntu-focal"
    # source = "https://cloud-images.ubuntu.com/minimal/daily/focal/current/focal-minimal-cloudimg-amd64.img"
    source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
    pool   = "default"
    format = "qcow2"
}

# login node disk
resource "libvirt_volume" "login-disk" {
    name = "login"
    base_volume_id = libvirt_volume.ubuntu-focal.id
    size = 17000000512
}

# login node
resource "libvirt_domain" "login-domain" {
    count = 1
    name = "login"
    memory = "10240"
    vcpu = 6

    cloudinit = libvirt_cloudinit_disk.commoninit.id

    network_interface {
        network_name = "default"
        wait_for_lease = true
    }

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_type = "virtio"
        target_port = "1"
    }

    disk {
        volume_id = libvirt_volume.login-disk.id
    }
}

# controller node disk
resource "libvirt_volume" "controller-disk" {
    name = "controller"
    base_volume_id = libvirt_volume.ubuntu-focal.id
    size = 17000000512
}

# controller node
resource "libvirt_domain" "controller-domain" {
    count = 1
    name = "controller"
    memory = "10240"
    vcpu = 6

    cloudinit = libvirt_cloudinit_disk.commoninit.id

    network_interface {
        network_name = "default"
        wait_for_lease = true
    }

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_type = "virtio"
        target_port = "1"
    }

    disk {
        volume_id = libvirt_volume.controller-disk.id
    }
}

# execute disks based on ubuntu-focal
resource "libvirt_volume" "exec-disks" {
    count = 2
    name = "exec-${count.index}"
    base_volume_id = libvirt_volume.ubuntu-focal.id
    size = 51000000512
}

# PCI Bus id's of T4 graphics cards
locals {
    t4pcibus= [["01","21","41"], ["a1","c1","e2"]]
    pcislots = ["08", "09", "10"]
}

# Create the machine
resource "libvirt_domain" "exec-domains" {
    count = 2
    name   = "exec-${count.index}"
    memory = "10240"
    vcpu   = 6

    cloudinit = libvirt_cloudinit_disk.commoninit.id

    network_interface {
        network_name = "default"
        wait_for_lease = true
    }

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_type = "virtio"
        target_port = "1"
    }

    disk {
        volume_id = libvirt_volume.exec-disks[count.index].id
    }

    xml {
      xslt = templatefile("${path.module}/templates/pcipassthrough", {
          buses = local.t4pcibus[count.index]
          slot = local.pcislots
      })
    }
}

# generate inventory file for Ansible
resource "local_file" "inventory" {
    content = templatefile("${path.module}/templates/inventory", {
        exec = libvirt_domain.exec-domains.*.network_interface.0.addresses
        controller = libvirt_domain.controller-domain.*.network_interface.0.addresses
        exec_hostname = libvirt_domain.exec-domains.*.name
        controller_hostname = libvirt_domain.controller-domain.*.name
    })

    filename = "../ansible/libvirt-inventory"
}


# IPs: use wait_for_lease true or after creation use terraform refresh and terraform show for the ips of domain