#!/bin/bash
set -e -x
truncate --size 10g arch_openstack
LOOP_DEVICE="$(sudo losetup --show -f arch_openstack)"
#LOOP_DEVICE=/dev/loop0
sudo image-bootstrap --openstack arch "${LOOP_DEVICE}"
sudo mount "${LOOP_DEVICE}p1" tmp
sudo arch-chroot tmp pacman-key --init
sudo arch-chroot tmp pacman-key --populate archlinux
sudo arch-chroot tmp pacman -S --noconfirm gptfdisk
sync
sudo umount "${LOOP_DEVICE}p1"
qemu-img convert -p -f raw -O qcow2 "${LOOP_DEVICE}" arch-$(date -I).qcow2

sudo losetup -d "${LOOP_DEVICE}"
rm -i arch_openstack