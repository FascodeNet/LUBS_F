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
cp -f /etc/skel/Desktop/calamares.desktop /home/${username}/Desktop/calamares.desktop

# Create Calamares Entry
cp -f /etc/skel/Desktop/calamares.desktop /usr/share/applications/calamares.desktop

unlink /usr/share/backgrounds/images/default.png
ln -s /usr/share/backgrounds/serene-wallpaper-1.png /usr/share/backgrounds/images/default.png

echo -e "sed -i \"s/^autologin/#autologin/g\" /etc/lightdm/lightdm.conf" >> /usr/share/calamares/final-process
sed -i "s/- packages/- shellprocess\n  - removeuser\n  - packages/g" /usr/share/calamares/settings.conf
sed -i "s/sb-shim/grub/g" /usr/share/calamares/modules/bootloader.conf
sed -i "s/fedora/Serene Linux on Fedora/g" /usr/share/calamares/modules/bootloader.conf
sed -i "s/auto/serene/g" /usr/share/calamares/settings.conf
if [[ $boot_splash = true ]]; then
    /usr/sbin/plymouth-set-default-theme serene-logo
fi