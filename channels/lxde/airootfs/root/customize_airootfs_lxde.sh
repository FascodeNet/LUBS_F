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
        g) localegen="${OPTARG/./\\.}\\" ;;
        z) timezone="${OPTARG}" ;;
        l) language="${OPTARG}" ;;
    esac
done
# Set up auto login
if [[ -f /etc/systemd/system/getty@tty2.service.d/override.conf ]]; then
    sed -i s/%USERNAME%/"${username}"/g /etc/systemd/system/getty@tty2.service.d/override.conf
fi 
if [[ -f /etc/systemd/system/getty@tty3.service.d/override.conf ]]; then
    sed -i s/%USERNAME%/"${username}"/g /etc/systemd/system/getty@tty3.service.d/override.conf
fi 
if [[ -f /etc/systemd/system/getty@tty4.service.d/override.conf ]]; then
    sed -i s/%USERNAME%/"${username}"/g /etc/systemd/system/getty@tty4.service.d/override.conf
fi 
systemctl disable lxdm.service
systemctl enable getty@tty1.service