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
systemctl enable lightdm.service
sed -i s/%USERNAME%/${username}/g /etc/lightdm/lightdm.conf
dconf update
# Set os name
sed -i s/%OS_NAME%/"${os_name}"/g /etc/skel/Desktop/calamares.desktop
sed -i s/%OS_NAME%/"${os_name}"/g /home/${username}/Desktop/calamares.desktop

# Create Calamares Entry
cp -f /etc/skel/Desktop/calamares.desktop /usr/share/applications/calamares.desktop

unlink /usr/share/backgrounds/images/default.png
ln -s /usr/share/backgrounds/serene-wallpaper-1.png /usr/share/backgrounds/images/default.png

echo -e "sed -i \"s/^autologin/#autologin/g\" /etc/lightdm/lightdm.conf" >> /usr/share/calamares/final-process
sed -i "s/install_secureboot(efi_directory)/install_grub(efi_directory, fw_type)/g" /usr/lib64/calamares/modules/bootloader/main.py
sed -i "s/check_target_env_call(\\[libcalamares.job.configuration\\[\"grubInstall\"\\],/subprocess.call(\\[libcalamares.job.configuration\\[\"grubInstall\"\\],/g" /usr/lib64/calamares/modules/bootloader/main.py
sed -i "s/- grubcfg/# - grubcfg/g" /usr/share/calamares/settings.conf