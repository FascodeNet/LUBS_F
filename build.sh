#!/usr/bin/env bash

# SPDX-License-Identifier: GPL-3.0
#
# kokkiemouse
# Twitter: @kokkiemouse
# Email  : kokkiemouse@gmail.com
#
# lfbs
#

set -e
# set -u

#export LANG=C

script_path=$(readlink -f "${0%/*}")
work_dir="${script_path}/work"
channels_dir="${script_path}/channels"
nfb_dir="${script_path}/nfb"
codename="33"
os_name="SereneLinux"
iso_name="SereneLinux"
language="ja_JP.UTF-8"
channel_name="serene"
cache_dir="${script_path}/cache"
bootsplash=false
arch="x86_64"

out_dir="${script_path}/out"
iso_label="${os_name}_${codename}_${arch}"
iso_publisher='Fascode Network <https://fascode.net>'
iso_application="${os_name} Live/Rescue CD"
iso_version="${codename}-$(date +%Y.%m.%d)"
iso_filename="${iso_name}-${iso_version}-${arch}.iso"
liveuser_name="fedora"
liveuser_password="fedora"
liveuser_shell="/usr/bin/zsh"

#-- language config --#

# Sets the default locale for the live environment.
# You can also place a package list for that locale name and install packages specific to that locale.
locale_name="en"
locale_gen_name="en_US.UTF-8"
locale_version="gl"
locale_time="UTC"
locale_fullname="global"

debug=false
cache_only=false
grub2_standalone_cmd=grub2-mkstandalone
gitversion=false
start_time="$(date +%s)"

_msg_common() {
    if [[ "${debug}" = true ]]; then
        local _current_time
        local _time
        _current_time="$(date +%s)"
        _time="$(("${_current_time}"-"${start_time}"))"

        #if [[ "${_time}" -ge 3600 ]]; then
        if (( "${_time}" >= 3600 )); then
            echo -n "[$(date -d @${_time} +%H:%M.%S)] "
        #elif [[ "${_time}" -ge 60 ]]; then
        elif (( "${_time}" >= 60 )); then
            echo -n "[00:$(date -d @${_time} +%M.%S)] "
        else
            echo -n "[00:00.$(date -d @${_time} +%S)] "
        fi
    fi
}

# Show an INFO message
# _msg_info <message>
_msg_info() {
    _msg_common
    "${script_path}/tools/msg.sh" -a "LFBS Core" -l "Info:" -s "6" info "${@}"
}

# Show an debug message
# _msg_debug <message>
_msg_debug() {
    _msg_common
    if [[ "${debug}" = true ]]; then
        "${script_path}/tools/msg.sh" -a "LFBS Core" -l "Debug:" -s "6" debug "${@}"
    fi
}

# Show an ERROR message then exit with status
# _msg_error <message> <exit code>
_msg_error() {
    _msg_common
    "${script_path}/tools/msg.sh" -a "LFBS Core" -l "Error:" -s "6" error "${@}"
    if [[ -n "${2:-}" ]]; then
        exit ${2}
    fi
}

# Unmount chroot dir
umount_chroot () {
    local mount

    for mount in $(mount | awk '{print $3}' | grep "$(realpath "${work_dir}")" | sort -r); do
        if [[ ! "${mount}" == "${work_dir}/airootfs" ]]; then
            _msg_info "Unmounting ${mount}"
            umount -fl "${mount}"
        fi
    done
}

# Unmount chroot dir and airootfs
umount_chroot_airootfs () {
    local mount

    for mount in $(mount | awk '{print $3}' | grep "$(realpath "${work_dir}")" | sort -r); do
        _msg_info "Unmounting ${mount}"
        umount -fl "${mount}"
    done
}
# Helper function to run make_*() only one time.
run_once() {
    local name
    umount_chroot
    name="$1"

    if [[ ! -e "${work_dir}/build.${name}" ]]; then
        _msg_info "$(echo $name | sed "s@_@ @g") is starting."
        "${1}"
        _msg_info "$(echo $name | sed "s@_@ @g") was done!"
        touch "${work_dir}/build.${name}"
    fi
}

run_cmd() {
    local mount

    for mount in "dev" "dev/pts" "proc" "sys" ; do
        mount --bind /${mount} "${work_dir}/airootfs/${mount}"
    done
    
    #mkdir -p "${work_dir}/airootfs/run/systemd/resolve/"
    #cp /etc/resolv.conf "${work_dir}/airootfs/run/systemd/resolve/stub-resolv.conf"
    cp /etc/resolv.conf "${work_dir}/airootfs/etc/resolv.conf"
    unshare --fork --pid chroot "${work_dir}/airootfs" "${@}"

    for mount in $(mount | awk '{print $3}' | grep "$(realpath "${work_dir}")" | sort -r); do
        if [[ ! "${mount}" == "${work_dir}/airootfs" ]]; then
            umount -fl "${mount}"
        fi
    done
}

_dnf_install() {    
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    run_cmd dnf -c /dnf_conf install -y ${@}
}

# rm helper
# Delete the file if it exists.
# For directories, rm -rf is used.
# If the file does not exist, skip it.
# remove <file> <file> ...
remove() {
    local _list=($(echo "$@"))
    local _file

    for _file in "${_list[@]}"; do
        _msg_debug "Removeing ${_file}"

        if [[ -f ${_file} ]]; then
            rm -f "${_file}"
        elif [[ -d ${_file} ]]; then
            rm -rf "${_file}"
        fi
    done
}

# Usage: echo_blank <number>
# 指定されたぶんの半角空白文字を出力します
echo_blank(){
    local _blank
    for _local in $(seq 1 "${1}"); do echo -ne " "; done
}

# Show help
_usage () {
    echo "usage ${0} [options] [channel]"
    echo
    echo " General options:"
    echo
    echo "    -a | --arch <str>      Set architecture"
    echo "                           Default: ${arch}"
    echo "    -b | --bootsplash      Enable Plymouth"
    echo "    -l | --lang <lang>     Specifies the default language for the live environment"
    echo "                           Default: ${locale_name}"
    echo "    -m | --mirror <url>    Set apt mirror server."
    echo "                           Default: ${mirror}"
    echo "    -o | --out <dir>       Set the output directory"
    echo "                           Default: ${out_dir}"
    echo "    -w | --work <dir>      Set the working directory"
    echo "                           Default: ${work_dir}"
    echo "    -c | --cache <dir>     Set the cache directory"
    echo "                           Default: ${cache_dir}"
    echo "         --gitversion      Add Git commit hash to image file version"
    echo
    echo "    -d | --debug           Enable debug messages"
    echo "    -x | --bash-debug      Enable bash debug mode(set -xv)"
    echo "    -h | --help            This help message and exit"
    echo
    echo "You can switch between installed packages, files included in images, etc. by channel."
    echo

    local blank="23" _arch  _list _dirname _channel

    echo " Language for each architecture:"
    for _list in ${script_path}/system/locale-* ; do
        _arch="${_list#${script_path}/system/locale-}"
        echo -n "    ${_arch}"
        echo_blank "$(( ${blank} - ${#_arch} ))"
        "${script_path}/tools/locale.sh" -a "${_arch}" show
    done

    echo  -e "\n Channel:"
    local _channel channel_list description
    for _channel in $(ls -l "${channels_dir}" | awk '$1 ~ /d/ {print $9 }'); do
        if [[ -n $(ls "${channels_dir}/${_channel}") ]] && [[ ! "${_channel}" = "share" ]]; then
            channel_list+=( "${_channel}" )
        fi
    done
    for _channel in ${channel_list[@]}; do
        if [[ -f "${channels_dir}/${_channel}/description.txt" ]]; then
            description=$(cat "${channels_dir}/${_channel}/description.txt")
        else
            description="This channel does not have a description.txt."
        fi
        echo -ne "    ${_channel}"
        echo_blank "$(( ${blank} - ${#_channel} ))"
        echo -ne "${description}\n"
    done
}

dnfstrap() {
    if [[ ! -d "${cache_dir}" ]]; then
        mkdir -p "${cache_dir}"
    fi
    cp -rf "${script_path}/system/dnfconf.conf" "${work_dir}/airootfs/dnf_conf"
    if [[ ! -d "${work_dir}/airootfs/dnf_cache" ]]; then
        mkdir -p "${work_dir}/airootfs/dnf_cache"
    fi
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    dnf -c "${work_dir}/airootfs/dnf_conf" --installroot="${work_dir}/airootfs" $(${script_path}/system/repository-json-parser.py ${script_path}/system/repository.json) install ${@} -y
    umount -fl "${work_dir}/airootfs/dnf_cache"
}

make_basefs() {
    _msg_info "Installing Fedora to '${work_dir}/airootfs'..."
    dnfstrap @Core yamad-repo 
    _msg_info "${codename} installed successfully!"
    
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' > "${work_dir}/airootfs/etc/bash.bashrc"
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    run_cmd dnf -c /dnf_conf update --refresh -y
    run_cmd dnf -c /dnf_conf -y remove $(run_cmd dnf -c /dnf_conf repoquery --installonly --latest-limit=-1 -q)
    # run_cmd apt-get upgrade
}


# Parse files
parse_files() {
    eval $(bash "${script_path}/tools/locale.sh" -s -a "${arch}" get "${locale_name}")
}

prepare_build() {
    if [[ ${EUID} -ne 0 ]]; then
        _msg_error "This script must be run as root." 1
    fi
    umount_chroot_airootfs
    # Check codename
    if [[ -z "$(grep -h -v ^'#' ${channels_dir}/${channel_name}/codename.${arch} | grep -x ${codename})" ]]; then
        _msg_error "This codename (${channel_name}) is not supported on this channel (${codename})."
    fi
    if [[ ! -d "${work_dir}/squashfsroot/LiveOS/" ]]; then
        mkdir -p "${work_dir}/squashfsroot/LiveOS/"
        mkdir -p "${work_dir}/airootfs/"
        _msg_info "Creating ext4 image of 32 GiB..."
        # truncate -s 32G "${work_dir}/squashfsroot/LiveOS/rootfs.img"
        # _msg_info "Format rootfs image..."
        #mkfs.ext4 -F "${work_dir}/squashfsroot/LiveOS/rootfs.img"
        mkfs.ext4 -O '^has_journal,^resize_inode' -E 'lazy_itable_init=0' -m 0 -F -- "${work_dir}/squashfsroot/LiveOS/rootfs.img" 32G
        tune2fs -c 0 -i 0 -- "${work_dir}/squashfsroot/LiveOS/rootfs.img" > /dev/null
        _msg_info "Done!"
    fi    
    mkdir -p "${out_dir}"
    _msg_info "Mount rootfs image..."
    mount -o loop,rw,sync "${work_dir}/squashfsroot/LiveOS/rootfs.img" "${work_dir}/airootfs"

}

make_systemd() {
    _dnf_install dbus-tools
    run_cmd dbus-uuidgen --ensure=/etc/machine-id
    if [[ ! -d "${work_dir}/airootfs/var/lib/dbus" ]]; then
        run_cmd mkdir /var/lib/dbus
    fi
    run_cmd ln -sf /etc/machine-id /var/lib/dbus/machine-id
}
make_repo_packages() {    
    local  _pkg  _pkglist=($("${script_path}/tools/pkglist-repo.sh" -a "x86_64" -c "${channels_dir}/${channel_name}" -k "${codename}" -l "${locale_name}" $(if [[ "${bootsplash}" = true ]]; then echo -n "-b"; fi) ))
    if [ -n "${_pkglist[*]}" ]; then
        # Create a list of packages to be finally installed as packages.list directly under the working directory.
        echo -e "# The list of packages that is installed in live cd.\n#\n\n" > "${work_dir}/packages.list"
        # Install packages on airootfs
        mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
        run_cmd dnf -y --nogpgcheck -c /dnf_conf install ${_pkglist[*]}
    fi
}
make_dnf_packages() {
    
    #local  _pkg  _pkglist=($("${script_path}/tools/pkglist.sh" -a "x86_64" -k "${kernel}" -c "${channel_dir}" -l "${locale_name}" $(if [[ "${boot_splash}" = true ]]; then echo -n "-b"; fi) ))
    local  _pkg  _pkglist=($("${script_path}/tools/pkglist.sh" -a "x86_64" -c "${channels_dir}/${channel_name}" -l "${locale_name}" $(if [[ "${bootsplash}" = true ]]; then echo -n "-b"; fi) ))
    # Create a list of packages to be finally installed as packages.list directly under the working directory.
    echo -e "# The list of packages that is installed in live cd.\n#\n\n" > "${work_dir}/packages.list"
    for _pkg in ${_pkglist[@]}; do
        echo ${_pkg} >> "${work_dir}/packages.list"
    done

    # Install packages on airootfs
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    run_cmd dnf -y --nogpgcheck -c /dnf_conf install ${_pkglist[*]}
}

make_cp_airootfs() {
    local _copy_airootfs

    _copy_airootfs() {
        local _dir="${1%/}"
        if [[ -d "${_dir}" ]]; then
            cp -af "${_dir}"/* "${work_dir}/airootfs"
        fi
    }
    _copy_airootfs "${channels_dir}/share/airootfs"
    _copy_airootfs "${channels_dir}/share/airootfs.${locale_name}"
    _copy_airootfs "${channels_dir}/${channel_name}/airootfs"
    _copy_airootfs "${channels_dir}/${channel_name}/airootfs.${locale_name}"
}

make_config() {
    # customize_airootfs options
    # -b                        : Enable boot splash.
    # -d                        : Enable debug mode.
    # -g <locale_gen_name>      : Set locale-gen.
    # -i <inst_dir>             : Set install dir
    # -k <kernel config line>   : Set kernel name.
    # -o <os name>              : Set os name.
    # -p <password>             : Set password.
    # -s <shell>                : Set user shell.
    # -t                        : Set plymouth theme.
    # -u <username>             : Set live user name.
    # -x                        : Enable bash debug mode.
    # -z <locale_time>          : Set the time zone.
    # -l <locale_name>          : Set language.
    #
    # -j is obsolete in AlterISO3 and cannot be used.
    # -k changed in AlterISO3 from passing kernel name to passing kernel configuration.
    local _airootfs_script_options _run_script
    _airootfs_script_options="-p ${liveuser_password} -u ${liveuser_name} -o ${os_name} -s ${liveuser_shell} -a ${arch} -g ${locale_gen_name} -l ${locale_name} -z ${locale_time} "
    if [[ ${bootsplash} == true ]]; then
        _airootfs_script_options="${_airootfs_script_options} -b"
    fi
    _run_script() {
        local _file
        for _file in ${@}; do
            if [[ -f "${work_dir}/airootfs${_file}" ]]; then run_cmd "${_file}" ${_airootfs_script_options}; fi
            if [[ -f "${work_dir}/airootfs${_file}" ]]; then chmod 755 "${work_dir}/airootfs${_file}"; fi
        done
    }

    _run_script "/root/customize_airootfs.sh" "/root/customize_airootfs_${channel_name}.sh"
}

make_clean() {
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    run_cmd dnf -c /dnf_conf -y remove $(run_cmd dnf -c /dnf_conf repoquery --installonly --latest-limit=-1 -q)
}

make_squashfs() {
    # prepare
    remove "${bootfiles_dir}"
    if [[ -d "${work_dir}/airootfs/dnf_cache" ]]; then
        rm -rf "${work_dir}/airootfs/dnf_cache"
    fi
    mkdir -p "${bootfiles_dir}"/{grub,LiveOS,boot,isolinux}
    #generate initrd
    _msg_info "make initrd..."
    run_cmd dracut --xz --add "dmsquash-live convertfs pollcdrom" --no-hostonly --no-early-microcode /boot/initrd0 `run_cmd ls /lib/modules`
    cp ${work_dir}/airootfs/boot/vmlinuz-$(run_cmd ls /lib/modules) ${bootfiles_dir}/boot/vmlinuz
    mv ${work_dir}/airootfs/boot/initrd0 ${bootfiles_dir}/boot/initrd
    #cp isolinux
    cp "${nfb_dir}"/isolinux/* "${bootfiles_dir}/isolinux/"
    # make squashfs
    remove "${work_dir}/airootfs/boot"
    mkdir "${work_dir}/airootfs/boot"
    cp ${bootfiles_dir}/boot/vmlinuz ${work_dir}/airootfs/boot/vmlinuz-$(run_cmd ls /lib/modules)
    kernelkun=$(run_cmd ls /lib/modules)
    echo -e "\nkernel-install add ${kernelkun} /boot/vmlinuz-${kernelkun}\ngrub2-mkconfig" >> ${work_dir}/airootfs/usr/share/calamares/final-process
    umount "${work_dir}/airootfs"
    # _msg_info "e2fsck..."
    # e2fsck -f "${work_dir}/squashfsroot/LiveOS/rootfs.img"
    # _msg_info "Minimize rootfs..."
    # resize2fs -M "${work_dir}/squashfsroot/LiveOS/rootfs.img"
    _msg_info "Compress rootfs.."
    mksquashfs "${work_dir}/squashfsroot/" "${bootfiles_dir}/LiveOS/squashfs.img" -noappend -no-recovery -comp zstd -Xcompression-level 21 -b 1048576
    _msg_info "Deleting block image..."
    rm -rf "${work_dir}/squashfsroot/LiveOS/rootfs.img"
}

make_nfb() {
    touch "${bootfiles_dir}/fedora_lfbs"
    # isolinux setup
    if [[ ${bootsplash} = true ]]; then
        sed "s|%OS_NAME%|${os_name}|g" "${nfb_dir}/isolinux.cfg" | sed "s|%CD_LABEL%|${iso_label}|g" | sed "s|selinux=0|selinux=0 quiet splash|g"  > "${bootfiles_dir}/isolinux/isolinux.cfg"
    else
        sed "s|%OS_NAME%|${os_name}|g" "${nfb_dir}/isolinux.cfg" | sed "s|%CD_LABEL%|${iso_label}|g"  > "${bootfiles_dir}/isolinux/isolinux.cfg"
    fi
    #grub
    if [[ ${bootsplash} = true ]]; then
        sed "s|%OS_NAME%|${os_name}|g" "${nfb_dir}/grub.cfg" | sed "s|%CD_LABEL%|${iso_label}|g" | sed "s|selinux=0|selinux=0 quiet splash|g" > "${bootfiles_dir}/grub/grub.cfg"
    else
        sed "s|%OS_NAME%|${os_name}|g" "${nfb_dir}/grub.cfg" | sed "s|%CD_LABEL%|${iso_label}|g" > "${bootfiles_dir}/grub/grub.cfg"
    fi
    sed "s|%OS_NAME%|${os_name}|g" "${nfb_dir}/grub.cfg" | sed "s|%CD_LABEL%|${iso_label}|g" | sed "s|selinux=0|selinux=0 quiet splash|g" > "${bootfiles_dir}/grub/grub.cfg"
    cp "${nfb_dir}/Shell_Full.efi" "${bootfiles_dir}/Shell_Full.efi"
}
make_efi() {
    # UEFI 32bit (ia32)
    ${grub2_standalone_cmd} \
        --format=i386-efi \
        --output="${bootfiles_dir}/grub/bootia32.efi" \
        --locales="" \
        --fonts="" \
        "boot/grub/grub.cfg=${bootfiles_dir}/grub/grub.cfg"
    
    # UEFI 64bit (x64)
    ${grub2_standalone_cmd} \
        --format=x86_64-efi \
        --output="${bootfiles_dir}/grub/bootx64.efi" \
        --locales="" \
        --fonts="" \
        "boot/grub/grub.cfg=${bootfiles_dir}/grub/grub.cfg"

    # create efiboot.img
    truncate -s 200M "${bootfiles_dir}/grub/efiboot.img"
    mkfs.fat -F 16 -f 1 -r 112 "${bootfiles_dir}/grub/efiboot.img"
    mkdir "${bootfiles_dir}/mnt"
    mount "${bootfiles_dir}/grub/efiboot.img" "${bootfiles_dir}/mnt"
    mkdir -p "${bootfiles_dir}/mnt/efi/boot"
    cp "${bootfiles_dir}/grub/bootia32.efi" "${bootfiles_dir}/mnt/efi/boot"
    cp "${bootfiles_dir}/grub/bootx64.efi" "${bootfiles_dir}/mnt/efi/boot"
    mkdir -p "${bootfiles_dir}/mnt/EFI/BOOT/"
    mkdir -p "${bootfiles_dir}/EFI/Boot/"
    cp "${bootfiles_dir}/grub/bootx64.efi" "${bootfiles_dir}/mnt/EFI/BOOT/"    
    cp "${bootfiles_dir}/grub/bootx64.efi" "${bootfiles_dir}/EFI/Boot/"    
    cp "${bootfiles_dir}/Shell_Full.efi" "${bootfiles_dir}/mnt/"
    umount -d "${bootfiles_dir}/mnt"
    remove "${bootfiles_dir}/mnt"
}
make_iso() {
    cd "${bootfiles_dir}"

    # create checksum (using at booting)
    bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt)"

    # create iso
    xorriso \
        -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "${iso_label}" \
        -appid "${iso_application}" \
        -publisher "${iso_publisher}" \
        -preparer "prepared by LFBS" \
        -b isolinux/isolinux.bin \
            -no-emul-boot \
            -boot-load-size 4 \
            -boot-info-table \
        -eltorito-alt-boot \
            -eltorito-platform efi \
            -eltorito-boot EFI/efiboot.img \
            -no-emul-boot \
        -isohybrid-mbr "${bootfiles_dir}/isolinux/isohdpfx.bin" \
        -isohybrid-gpt-basdat \
        -eltorito-catalog isolinux/boot.cat \
        -output "${out_dir}/${iso_filename}" \
        -graft-points \
            "." \
            "/isolinux/isolinux.bin=isolinux/isolinux.bin" \
            "/EFI/efiboot.img=grub/efiboot.img"
    
    cd - > /dev/null
}

make_checksum() {
    cd "${out_dir}"
    _msg_info "Creating md5 checksum ..."
    md5sum "${iso_filename}" > "${iso_filename}.md5"

    _msg_info "Creating sha256 checksum ..."
    sha256sum "${iso_filename}" > "${iso_filename}.sha256"
    cd - > /dev/null 2>&1
    umount_chroot_airootfs
}

# 引数解析 参考記事：https://0e0.pw/ci83 https://0e0.pw/VJlg
_opt_short="w:l:o:hba:-:m:c:dx"
_opt_long="help,arch:,codename:,debug,help,lang,mirror:,out:,work,cache-only,bootsplash,bash-debug,gitversion"
OPT=$(getopt -o ${_opt_short} -l ${_opt_long} -- "${@}")

if [[ ${?} != 0 ]]; then
    exit 1
fi

eval set -- "${OPT}"

while :; do
    case ${1} in
        -a | --arch)
            arch="${2}"
            shift 2
            ;;
        -b | --bootsplash)
            bootsplash=true
            shift 1
            ;;
        -c | --cache)
            cache_dir="${2}"
            shift 2
            ;;
        -d | --debug)
            debug=true
            shift 1
            ;;
        -h | --help)
            _usage
            exit 0
            ;;
        -m | --mirror)
            mirror="${2}"
            shift 2
            ;;
        -l | --lang)
            locale_name="${2}"
            shift 2
            ;;
        -o | --out)
            out_dir="${2}"
            shift 2
            ;;
        -w | --work)
            work_dir="${2}"
            shift 2
            ;;
        --cache-only)
            cache_only=true
            shift 1
            ;;
        -x | --bash-debug)
            set -xv
            shift 1
            ;;
        --gitversion)
            gitversion=true
            shift 1
            ;;
        --)
            shift
            break
            ;;
        *)
            _msg_error "Invalid argument '${1}'"
            _usage 1
            ;;
    esac
done
if [[ -f "/etc/arch-release" ]]; then
    grub2_standalone_cmd=grub-mkstandalone
fi
bootfiles_dir="${work_dir}/bootfiles"
trap 'umount_chroot_airootfs' 0 2 15

if [[ -n "${1}" ]]; then
    channel_name="${1}"
    if [[ "${channel_name}" = "umount" ]]; then
        umount_chroot_airootfs
        exit 0
    fi
    if [[ "${channel_name}" = "clean" ]]; then
        umount_chroot_airootfs
        _msg_info "deleting work dir..."
        remove "${work_dir}"
        exit 0
    fi
    check_channel() {
        local channel_list
        local i
        channel_list=()
        
        for _channel in $(ls -l "${channels_dir}" | awk '$1 ~ /d/ {print $9 }'); do
            if [[ -n "$(ls "${channels_dir}/${_channel}")" ]] && [[ ! "${_channel}" = "share" ]]; then
                channel_list+=( "${_channel}" )
            fi
        done

        for i in ${channel_list[@]}; do
            if [[ "${i}" = "${channel_name}" ]]; then
                echo -n "true"
                return 0
            fi
        done

        echo -n "false"
        return 1
    }

    if [[ "$(check_channel ${channel_name})" = false ]]; then
        _msg_error "Invalid channel ${channel_name}"
        exit 1
    fi
fi
if [[ "${gitversion}" == "true" ]]; then
    cd ${script_path}
    iso_filename="${iso_name}-${codename}-${channel_name}-${locale_name}-$(date +%Y.%m.%d)-$(git rev-parse --short HEAD)-${arch}.iso"
else
    iso_filename="${iso_name}-${codename}-${channel_name}-${locale_name}-$(date +%Y.%m.%d)-${arch}.iso"
fi
umount_chroot_airootfs
if [[ -d "${work_dir}" ]]; then
    _msg_info "deleting work dir..."
    remove "${work_dir}"
fi

prepare_build
parse_files
run_once make_basefs
run_once make_systemd
run_once make_repo_packages
run_once make_dnf_packages
run_once make_cp_airootfs
run_once make_config
run_once make_clean
run_once make_squashfs
run_once make_nfb
run_once make_efi
run_once make_iso
run_once make_checksum
