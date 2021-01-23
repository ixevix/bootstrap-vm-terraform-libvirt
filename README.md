# Requirements

```
qemu
libvirt
sudo
arch-chroot
terraform
terraform-provider-libvirt
image-bootstrap-git
```

# Environment variables

```
export TF_VAR_mac
export TF_VAR_user_name
```

Mac address can be left blank initially to generate one and then set it if you need to regen the vm.

# build_image.sh

Can be used to bootstrap an openstack image. In the case of archlinux and cloud-init you need to install gptfdisk so that you can use disk_setup in cloud_init.tpl.

## Building

Some DEs like GNOME might try to mount the created loop device while running the script so you might need to use a console session for building.