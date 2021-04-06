#!/usr/bin/env bash

systemctl enable lightdm.service
sed -i s/%USERNAME%/${username}/g /etc/lightdm/lightdm.conf
if [[ -f /etc/dconf/db/local ]]; then
    rm -rf /etc/dconf/db/local
fi
dconf update
# Set os name
sed -i s/%OS_NAME%/"${os_name}"/g /etc/skel/Desktop/calamares.desktop
cp -f /etc/skel/Desktop/calamares.desktop /home/${username}/Desktop/calamares.desktop
# delete xscreen
dnf remove -y xscreensaver-base
# delete dnfdragora
dnf remove -y dnfdragora
# Create Calamares Entry
cp -f /etc/skel/Desktop/calamares.desktop /usr/share/applications/calamares.desktop
mv /root/.VolumeIcon.png /.VolumeIcon.png
unlink /usr/share/backgrounds/images/default.png
ln -s /usr/share/backgrounds/serene-wallpaper-1.png /usr/share/backgrounds/images/default.png

echo -e "cp -f /lightdm.conf /etc/lightdm/lightdm.conf" >> /usr/share/calamares/final-process
echo -e "rm -rf /lightdm.conf" >> /usr/share/calamares/final-process
sed -i "s/- packages/- shellprocess\n  - removeuser\n  - packages/g" /usr/share/calamares/settings.conf
sed -i "s/- grubcfg//g" /usr/share/calamares/settings.conf
sed -i "s/sb-shim/refind/g" /usr/share/calamares/modules/bootloader.conf
sed -i "s/fedora/Serene Linux F/g" /usr/share/calamares/modules/bootloader.conf
sed -i "s/auto/serene/g" /usr/share/calamares/settings.conf
sed -i "s/light-locker-command/echo/g" /home/${username}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
rm -rf /home/${username}/.config/autostart/light-locker.desktop
if [[ $boot_splash = true ]]; then
    /usr/sbin/plymouth-set-default-theme serene-logo
fi
if [[ ${localegen} == "en_US.UTF-8" ]]; then
    rm -rf /opt/flast-gecko-nightly/locale.ini
fi
chmod 755 /usr/bin/serenelinux-gtk-bookmarks
if [[ ${localegen} == "ja_JP.UTF-8" ]]; then
    echo -e "QT_IM_MODULE=ibus" >> /etc/environment
fi
dnf mark install grub2-pc
dnf mark install grub2-efi-x64
dnf mark install grub2-efi-ia32