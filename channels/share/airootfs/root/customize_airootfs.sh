#!/usr/bin/env bash

set -e -u

password=fedora
root_passwd=fedora
username=fedora
usershell="/usr/bin/zsh"
localegen="en_US.UTF-8"
timezone="UTC"
boot_splash=false
export PATH=$PATH:/usr/sbin
# Creating a root user.
# usermod -s /usr/bin/zsh root
function user_check () {
    if [[ -z "${1}" ]]; then
        return 1
    fi
    if getent passwd "${1}" > /dev/null 2> /dev/null; then
        return 1
    else
        return 0
    fi
}

# Parse arguments
#while getopts 'p:bt:k:rxu:o:i:s:da:g:z:l:' arg; do
while getopts 'a:bdg:i:l:o:p:s:t:u:xz:' arg; do
    case "${arg}" in
        a) arch="${OPTARG}" ;;
        b) boot_splash=true ;;
        d) debug=true ;;
        g) localegen="${OPTARG}" ;;
        i) install_dir="${OPTARG}" ;;
        l) language="${OPTARG}" ;;
        o) os_name="${OPTARG}" ;;
        p) password="${OPTARG}" ;;
        s) usershell="${OPTARG}" ;;
        t) theme_name="${OPTARG}" ;;
        u) username="${OPTARG}" ;;
        x) debug=true; set -xv ;;
        z) timezone="${OPTARG}" ;;
    esac
done


root_passwd="${password}"
#usermod -s "${usershell}" root
cp -aT /etc/skel/ /root/

# Allow sudo group to run sudo
sed -i 's/^#\s*\(%sudo\s\+ALL=(ALL)\s\+ALL\)/\1/' /etc/sudoers

function create_user () {
    local _username="${1}"
    local _password="${2}"

    set +u
    if [[ -z "${_username}" ]]; then
        echo "User name is not specified." >&2
        return 1
    fi
    if [[ -z "${_password}" ]]; then
        echo "No password has been specified." >&2
        return 1
    fi
    set -u

    if user_check "${_username}"; then
        useradd -m -s ${usershell} ${_username}
        echo ${_password} | passwd --stdin ${_username}
        passwd -u -f ${_username}
        groupadd sudo
        usermod -g ${_username} ${_username}
        usermod -aG sudo ${_username}
        #usermod -aG storage ${_username}
        cp -aT /etc/skel/ /home/${_username}/
    fi
    echo ${root_passwd} | passwd --stdin root
    passwd -u -f root
    chmod 700 -R /home/${_username}
    chown ${_username}:${_username} -R /home/${_username}
    set -u
}
rpmkeys --import /etc/pki/rpm-gpg/RPM-GPG-KEY-serene
create_user "${username}" "${password}"


# Enable and generate languages.
echo "LANG=${localegen}" > /etc/locale.conf

# Setting the time zone.
ln -sf "/usr/share/zoneinfo/${timezone}" "/etc/localtime"

# Set up auto login
if [[ -f "/etc/systemd/system/getty@tty1.service.d/override.conf" ]]; then
    sed -i s/%USERNAME%/"${username}"/g "/etc/systemd/system/getty@tty1.service.d/override.conf"
fi

# Set to execute calamares without password as alter user.
echo -e "\nDefaults pwfeedback" >> /etc/sudoers
echo -e "${username} ALL=NOPASSWD: ALL\nroot ALL=NOPASSWD: ALL" >> /etc/sudoers.d/fedoralive

cat > "/etc/profile.d/alias_systemctl_setup.sh" << "EOF"
#!/usr/bin/env bash
alias reboot="sudo reboot"
alias shutdown="sudo shutdown"
alias poweroff="sudo poweroff"
alias halt="sudo halt"
EOF
chmod 755 "/etc/profile.d/alias_systemctl_setup.sh"


# Chnage sudoers permission
chmod 750 -R /etc/sudoers.d/
chown root:root -R /etc/sudoers.d/

echo "LANG=${localegen}" > "/etc/locale.conf"
truncate -s 0 /etc/machine-id
passwd -u -f root


# Calamares configs

# Replace the configuration file.
# Remove configuration files for other kernels.
#remove /usr/share/calamares/modules/initcpio/
#remove /usr/share/calamares/modules/unpackfs/

# Set up calamares removeuser
sed -i "s/%USERNAME%/${username}/g" "/usr/share/calamares/modules/removeuser.conf"

# Set user shell
sed -i "s|%USERSHELL%|'${usershell}'|g" "/usr/share/calamares/modules/users.conf"

# Add disabling of sudo setting
echo -e "\nremove \"/etc/sudoers.d/fedoralive\"" >> "/usr/share/calamares/final-process"
if [[ "${boot_splash}" = true ]]; then
    cat > "/etc/grub.d/99_plymouth_config" <<EOF
#!/usr/bin/env bash
grubby --update-kernel=ALL --args="quiet splash"

EOF
    chmod +x "/etc/grub.d/99_plymouth_config"
    echo -e "\ngrubby --update-kernel=ALL --args=\"quiet splash\"" >> /usr/share/calamares/final-process
fi
echo "universal_hooks=true" >> "/etc/dnf/dnf.conf"
