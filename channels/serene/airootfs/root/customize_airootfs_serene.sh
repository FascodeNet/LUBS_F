#!/usr/bin/env bash

while getopts 'p:bt:k:rxu:o:i:s:da:g:z:l:' arg; do
    case "${arg}" in
        p) password="${OPTARG}" ;;
        b) boot_splash=true ;;
        t) theme_name="${OPTARG}" ;;
        k) kernel_config_line=(${OPTARG}) ;;
        r) rebuild=true ;;
        u) username="${OPTARG}" ;;
        o) os_name="${OPTARG}" ;;
        i) install_dir="${OPTARG}" ;;
        s) usershell="${OPTARG}" ;;
        d) debug=true ;;
        x) debug=true; set -xv ;;
        a) arch="${OPTARG}" ;;
        g) localegen="${OPTARG}" ;;
        z) timezone="${OPTARG}" ;;
        l) language="${OPTARG}" ;;
    esac
done
dnf install -y lightdm lightdm-gtk
systemctl enable lightdm.service
sed -i s/%USERNAME%/${username}/g /etc/lightdm/lightdm.conf
dconf update
unlink /usr/share/backgrounds/images/default.png
ln -s /usr/share/backgrounds/serene-wallpaper-1.png /usr/share/backgrounds/images/default.png

