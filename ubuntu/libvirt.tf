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

resource "libvirt_cloudinit_disk" "ubuntu-commoninit" {
  name      = "ubuntu-commoninit.iso"
  user_data = templatefile("${path.module}/cloud_init.tpl", {
    user_name       = var.user_name
    authorized_keys = indent(4, yamlencode(templatefile("${path.module}/templates/authorized_keys", {})))
    htoprc          = indent(4, templatefile("${path.module}/templates/htoprc", {}))
    vimrc           = indent(4, templatefile("${path.module}/templates/vimrc", {}))
    root_zshrc      = indent(4, templatefile("${path.module}/templates/root_zshrc", {}))
    user_zshrc      = indent(4, templatefile("${path.module}/templates/user_zshrc", {}))
  })
}

resource "libvirt_volume" "ubuntu-dev-root" {
  name = "ubuntu-dev.qcow2"
  pool = "default"
  format = "qcow2"
  #source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img"
  source = "/home/${var.user_name}/Downloads/focal-server-cloudimg-amd64-disk-kvm.img"
}

resource "libvirt_domain" "ubuntu-dev" {
  name = "ubuntu-dev"
  memory = "2048"
  vcpu = 2
  autostart = true

  cloudinit = libvirt_cloudinit_disk.ubuntu-commoninit.id

  disk {
    volume_id = libvirt_volume.ubuntu-dev-root.id
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
