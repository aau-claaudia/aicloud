resource "openstack_compute_instance_v2" "my_instance" {
  name      = "my_instance"
#  region    = "DFW"
  image_id  = "0908dd36-522e-4ffa-8386-02b011297d0c"
  flavor_id = "cpu.small"
  key_pair  = "provisioning_key"

  network {
    uuid = "00000000-0000-0000-0000-000000000000"
    name = "public"
  }

  network {
    uuid = "11111111-1111-1111-1111-111111111111"
    name = "private"
  }
}

# generate inventory file for Ansible
resource "local_file" "inventory" {
    content = templatefile("${path.module}/templates/inventory", {
        exec = openstack_compute_instance_v2.my_instance.*.ipv4_address
        #controller = digitalocean_droplet.controller.*.ipv4_address
        exec_hostname = openstack_compute_instance_v2.my_instance.*.name
        #controller_hostname = digitalocean_droplet.controller.*.name
        exec_privateaddresses = openstack_compute_instance_v2.my_instance.*.ipv4_address_private
        #controller_privateaddresses = digitalocean_droplet.controller.*.ipv4_address_private
    })
    filename = "../ansible/terraform-inventory"
}
