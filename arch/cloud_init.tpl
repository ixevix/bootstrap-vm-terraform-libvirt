#cloud-config
disk_setup:
  /dev/vdb:
    table_type: gpt
    layout: true
    overwrite: false

fs_setup:
  - label: home
    filesystem: ext4
    device: '/dev/vdb1'
    overwrite: false

mounts:
  - [ /dev/vdb1, /mnt/persist, ext4, "defaults", "0", "2"]

ssh_pwauth: false

users:
  - name: ${user_name}
    ssh_authorized_keys: ${authorized_keys}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/zsh
    groups: [wheel,users,docker,sys]

packages:
 - man-db
 - man-pages
 - zsh
 - zsh-autosuggestions
 - htop
 - vim
 - tmux
 - rtorrent
 - qemu-guest-agent
 - wget
 - git
 - docker
 - kubectl
 - base-devel
 - go
package_update: true
package_upgrade: true

locale: en_US.UTF-8
locale_configfile: /etc/locale.conf

timezone: Europe/Helsinki

hostname: dev

runcmd:
 - locale-gen
 - localectl set-locale LANG=en_US.UTF-8
 - pacman-key --init
 - pacman-key --populate archlinux
 - pacman -Syy
 - chsh -s /bin/zsh
 - [ chown,
    ${user_name}:${user_name},
    /home/${user_name}/.config/htop/htoprc,
    /home/${user_name}/.config/htop,
    /home/${user_name}/.config,
    /home/${user_name}/.zshrc,
    /home/${user_name}/.bin/install_yay.sh,
    /home/${user_name} ]
 - chmod u+x /home/${user_name}/.bin/install_yay.sh
 - systemctl enable --now systemd-timesyncd
 - sed -i "s/\[options\]/\[options\]\nColor\nVerbosePkgLists/" /etc/pacman.conf
 - su -c "/home/${user_name}/.bin/install_yay.sh" - ${user_name}
 - systemctl enable --now docker
 - systemctl enable --now qemu-guest-agent

write_files:
- content: |
    en_US.UTF-8 UTF-8
  path: /etc/locale.gen
- content: |
    ${htoprc}
  path: /home/${user_name}/.config/htop/htoprc
- content: |
    ${htoprc}
  path: /root/.config/htop/htoprc
- content: |
    ${user_zshrc}
  path: /home/${user_name}/.zshrc
- content: |
    ${root_zshrc}
  path: /root/.zshrc
- content: |
    ${vimrc}
  path: /etc/vimrc
- content: |
    #!/bin/bash
    mkdir ~/Downloads
    cd Downloads
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
  path: /home/${user_name}/.bin/install_yay.sh
- content: |
    ${mirrorlist}
  path: /etc/pacman.d/mirrorlist