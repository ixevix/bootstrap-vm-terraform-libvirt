#cloud-config
ssh_pwauth: false

users:
  - name: ${user_name}
    ssh_authorized_keys: ${authorized_keys}
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    shell: /bin/zsh
    groups: [wheel,users,docker]

packages:
 - man-db
 - zsh
 - zsh-autosuggestions
 - htop
 - vim-nox
 - tmux
 - qemu-guest-agent
 - wget
 - git
 - docker
 - build-essential
 - golang
package_update: true
package_upgrade: true

timezone: Europe/Helsinki

hostname: debian-dev

runcmd:
 - chsh -s /bin/zsh
 - chown ${user_name}:${user_name} /home/${user_name}/.config/htop/htoprc
 - chown ${user_name}:${user_name} /home/${user_name}/.config/htop
 - chown ${user_name}:${user_name} /home/${user_name}/.config
 - chown ${user_name}:${user_name} /home/${user_name}/.zshrc
 - chown ${user_name}:${user_name} /home/${user_name}
 - systemctl enable --now systemd-timesyncd
 - systemctl enable --now docker

write_files:
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
  path: /etc/vim/vimrc