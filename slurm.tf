terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}
variable "nr_machines" {
  default = "2"
}

variable "image" {
  default= "/var/tmp/tw-current/tumbleweed.x86_64-1.99.1.qcow2"
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "random_id" "server" {
  count       = var.nr_machines
  byte_length = 4
}

resource "random_id" "net" {
  byte_length = 2
}

resource "random_integer" "ip_prefix" {
  min = 0
  max = 254
}

resource "random_id" "mac" {
  count = var.nr_machines
  byte_length = 2
}

resource "libvirt_volume" "myvdisk" {
  name   = "terraform-vdisk-${element(random_id.server.*.hex, count.index)}.qcow2"
  count  = var.nr_machines
  pool   = "tmp"
  source = var.image
  format = "qcow2"
}

resource "libvirt_network" "my_net" {
  name      = "slurm-net-${random_id.net.hex}"
  #addresses = ["10.10.${random_integer.ip_prefix.result}.1/24","fdaa:1010:${random_integer.ip_prefix.result}::/64"]
  addresses = ["10.10.${random_integer.ip_prefix.result}.1/24"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}

resource "libvirt_domain" "domain-slurm" {
  name   = "slurm-node${count.index+1}-${random_id.net.hex}"
  memory = "12288"
  vcpu   = 12
  count  = var.nr_machines

  network_interface {
    network_id     = libvirt_network.my_net.id
    wait_for_lease = true
    hostname       = "node${count.index+1}"
    addresses      = ["10.10.${random_integer.ip_prefix.result}.${count.index+11}"]
  }

  disk {
    volume_id = libvirt_volume.myvdisk[count.index].id
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

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = "true"
  }
}

output "vm_ips" {
  value = libvirt_domain.domain-slurm.*.network_interface.0.addresses
}

output "vm_names" {
  value = libvirt_domain.domain-slurm.*.name
}

