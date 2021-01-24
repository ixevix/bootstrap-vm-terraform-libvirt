terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "mac" {
  description = "vm mac"
  type        = string
}

variable "user_name" {
  description = "user name"
  type        = string
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = templatefile("${path.module}/cloud_init.tpl", {
    user_name       = var.user_name
    authorized_keys = indent(4, yamlencode(templatefile("${path.module}/templates/authorized_keys", {})))
    htoprc          = indent(4, templatefile("${path.module}/templates/htoprc", {}))
    vimrc           = indent(4, templatefile("${path.module}/templates/vimrc", {}))
    root_zshrc      = indent(4, templatefile("${path.module}/templates/root_zshrc", {}))
    user_zshrc      = indent(4, templatefile("${path.module}/templates/user_zshrc", {}))
    mirrorlist      = indent(4, templatefile("${path.module}/templates/mirrorlist", {}))
  })
}

resource "libvirt_volume" "dev-persistent-storage" {
  name = "dev.img"
  pool = "default"
  format = "raw"
  size = 21474836480
}

resource "libvirt_volume" "dev-root" {
  name = "dev.qcow2"
  pool = "default"
  format = "qcow2"
  #source = "./arch-2021-01-17.qcow2"
  source = "https://linuximages.de/openstack/arch/arch-openstack-LATEST-image-bootstrap.qcow2"
  #source = "/home/${var.user_name}/Downloads/arch-openstack-LATEST-image-bootstrap.qcow2"
}

resource "libvirt_domain" "dev" {
  name = "dev"
  memory = "2048"
  vcpu = 2
  autostart = true

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = libvirt_volume.dev-root.id
  }

  disk {
    volume_id = libvirt_volume.dev-persistent-storage.id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }

  network_interface {
    bridge = "br0"
    mac = var.mac
  }
}
