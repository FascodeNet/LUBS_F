#!/usr/bin/env bash

set -e -u

password=fedora
root_passwd=fedora
username=fedora
usershell="/usr/bin/bash"
export PATH=$PATH:/usr/sbin
# Creating a root user.
# usermod -s /usr/bin/zsh root
function user_check () {
if [[ $(getent passwd $1 > /dev/null ; printf $?) = 0 ]]; then
    if [[ -z $1 ]]; then
        echo -n "false"
    fi
    echo -n "true"
else
    echo -n "false"
fi
}

#usermod -s "${usershell}" root
cp -aT /etc/skel/ /root/
# Allow sudo group to run sudo
sed -i 's/^#\s*\(%sudo\s\+ALL=(ALL)\s\+ALL\)/\1/' /etc/sudoers

function create_user () {
    local _password
    local _username

    _username=${1}
    _password=${2}

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

    if [[ $(user_check ${_username}) = false ]]; then
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

create_user "${username}" "${password}"


# Set up auto login
if [[ -f /etc/systemd/system/getty@tty1.service.d/override.conf ]]; then
    sed -i s/%USERNAME%/"${username}"/g /etc/systemd/system/getty@tty1.service.d/override.conf
fi

# Set to execute calamares without password as alter user.
cat >> /etc/sudoers << "EOF"
Defaults pwfeedback
EOF
echo "${username} ALL=NOPASSWD: ALL" >> /etc/sudoers.d/fedoralive
echo "root ALL=NOPASSWD: ALL" >> /etc/sudoers.d/fedoralive
echo "#!/usr/bin/env bash" > "/etc/profile.d/alias_systemctl_setup.sh"
echo "alias reboot=\"sudo reboot\"" >> "/etc/profile.d/alias_systemctl_setup.sh"
echo "alias shutdown=\"sudo shutdown\"" >> "/etc/profile.d/alias_systemctl_setup.sh"
echo "alias poweroff=\"sudo poweroff\"" >> "/etc/profile.d/alias_systemctl_setup.sh"
echo "alias halt=\"sudo halt\"" >> "/etc/profile.d/alias_systemctl_setup.sh"
chmod +x "/etc/profile.d/alias_systemctl_setup.sh"



# Chnage sudoers permission
chmod 750 -R /etc/sudoers.d/
chown root:root -R /etc/sudoers.d/
