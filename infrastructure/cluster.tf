resource "digitalocean_droplet" "exec" {
    count = 3
    image = "ubuntu-20-04-x64"
    name = "slurm-exec-${count.index}"
    region = "ams3"
    size = "s-2vcpu-2gb"
    private_networking = true
    ssh_keys = [
        data.digitalocean_ssh_key.terraform.id
    ]
}

resource "digitalocean_droplet" "controller" {
    count = 1
    image = "ubuntu-20-04-x64"
    name = "slurm-controller"
    region = "ams3"
    size = "s-2vcpu-2gb"
    private_networking = true
    ssh_keys = [
        data.digitalocean_ssh_key.terraform.id
    ]
}

# generate inventory file for Ansible
resource "local_file" "inventory" {
    content = templatefile("${path.module}/templates/inventory", {
        exec = digitalocean_droplet.exec.*.ipv4_address
        controller = digitalocean_droplet.controller.*.ipv4_address
        exec_hostname = digitalocean_droplet.exec.*.name
        controller_hostname = digitalocean_droplet.controller.*.name
        exec_privateaddresses = digitalocean_droplet.exec.*.ipv4_address_private
        controller_privateaddresses = digitalocean_droplet.controller.*.ipv4_address_private
    })
    filename = "../ansible/terraform-inventory"
}
