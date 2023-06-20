terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

#variable "do_token" {}
variable "do_keyname" {}
# 
#provider "digitalocean" {
#  token = var.do_token
#}

data "openstack_ssh_key" "terraform" {
  name = var.do_keyname
}
