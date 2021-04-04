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



script_path=$(readlink -f "${0%/*}")
work_dir="${script_path}/work"
channels_dir="${script_path}/channels"
nfb_dir="${script_path}/nfb"
cache_dir="${script_path}/cache"
out_dir="${script_path}/out"

codename="34"
os_name="SereneLinux"
iso_name="SereneLinux"
channel_name="serene"
bootsplash=false
arch="x86_64"

out_dir="${script_path}/out"
iso_label="${os_name}_${codename}_${arch}"
iso_publisher='Fascode Network <https://fascode.net>'
iso_application="${os_name} Live/Rescue CD"
iso_version="${codename}-$(date +%Y.%m.%d)"

liveuser_name="serene"
liveuser_password="serene"
liveuser_shell="/usr/bin/zsh"

locale_name="en"
locale_gen_name="en_US.UTF-8"
locale_version="gl"
locale_time="UTC"
locale_fullname="global"

debug=false
cache_only=false
grub2_standalone_cmd="grub2-mkstandalone"
gitversion=false
logging=false
customized_logpath=false
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

# Show an warning message
# _msg_warn <message>
_msg_warn() {
    _msg_common
    "${script_path}/tools/msg.sh" -a "LFBS Core" -l "Warn:" -s "6" warn "${@}"
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

_umount(){
    _msg_info "Unmounting ${1}"
    umount -fl "${1}"
}

# Unmount chroot dir
umount_chroot () {
    local mount
    for mount in $(cat "/proc/mounts" | cut -d " " -f 2 | grep "$(realpath "${work_dir}")" | tac | grep -xv "${work_dir}/airootfs"); do
        _umount "${mount}"
    done
}

# Unmount chroot dir and airootfs
umount_chroot_airootfs () {
    local mount
    for mount in $(cat "/proc/mounts" | cut -d " " -f 2 | grep "$(realpath "${work_dir}")" | tac); do
        _umount "${mount}"
    done
}

# Helper function to run make_*() only one time.
run_once() {
    umount_chroot
    if [[ ! -e "${work_dir}/build.${1}" ]]; then
        _msg_info "$(echo -n "${1}" | sed "s@_@ @g") is starting."
        eval "${@}"
        _msg_info "$(echo -n "${1}" | sed "s@_@ @g") was done!"
        touch "${work_dir}/build.${1}"
    fi
}

run_cmd() {
    local mount
    for mount in "dev" "dev/pts" "proc" "sys" ; do
        mount --bind "/${mount}" "${work_dir}/airootfs/${mount}"
    done
    
    cp "/etc/resolv.conf" "${work_dir}/airootfs/etc/resolv.conf"
    unshare --fork --pid chroot "${work_dir}/airootfs" "${@}"

    umount_chroot
}

_dnf_install() {    
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    run_cmd dnf -c /dnf_conf install -y ${@}
}

# Show message when file is removed
# remove <file> <file> ...
remove() {
    local _file
    for _file in "${@}"; do _msg_debug "Removing ${_file}"; rm -rf "${_file}"; done
}

# Usage: echo_blank <number>
# 指定されたぶんの半角空白文字を出力します
echo_blank(){ yes " " | head -n "${1}" | tr -d "\n"; }

# Show help
_usage () {
    echo "usage ${0} [options] [channel]"
    echo
    echo " General options:"
    echo
    #echo "    -a | --arch <str>      Set architecture"
    #echo "                           Default: ${arch}"
    echo "    -b | --bootsplash      Enable Plymouth"
    echo "    -l | --lang <lang>     Specifies the default language for the live environment"
    echo "                           Default: ${locale_name}"
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

    local blank="23" _arch _list _channel

    echo " Language for each architecture:"
    for _list in ${script_path}/system/locale-* ; do
        _arch="${_list#${script_path}/system/locale-}"
        echo -n "    ${_arch}$(echo_blank "$(( ${blank} - ${#_arch} ))")"
        "${script_path}/tools/locale.sh" -a "${_arch}" show
    done

    echo -e "\n Channel:"
    local _channel description
    for _channel in $(ls -l "${channels_dir}" | awk '$1 ~ /d/ {print $9 }'); do
        if [[ -n $(ls "${channels_dir}/${_channel}") ]] && [[ ! "${_channel}" = "share" ]]; then
            if [[ -f "${channels_dir}/${_channel}/description.txt" ]]; then
                description=$(cat "${channels_dir}/${_channel}/description.txt")
            else
                description="This channel does not have a description.txt."
            fi
            echo -e "    ${_channel}$(echo_blank "$(( ${blank} - ${#_channel} ))")${description}"
        fi
    done
}

dnfstrap() {
    if [[ ! -d "${cache_dir}" ]]; then
        mkdir -p "${cache_dir}"
    fi
    cp -rf "${script_path}/system/dnfconf.conf" "${work_dir}/airootfs/dnf_conf"
    mkdir -p "${work_dir}/airootfs/dnf_cache"
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    dnf -c "${work_dir}/airootfs/dnf_conf" --installroot="${work_dir}/airootfs" $(${script_path}/system/repository-json-parser.py ${script_path}/system/repository.json) install ${@} -y
    umount -fl "${work_dir}/airootfs/dnf_cache"
}

make_basefs() {
    mkdir -p "${work_dir}/squashfsroot/LiveOS/" "${work_dir}/airootfs/"
    _msg_info "Creating ext4 image of 32 GiB..."
    # truncate -s 32G "${work_dir}/squashfsroot/LiveOS/rootfs.img"
    # _msg_info "Format rootfs image..."
    #mkfs.ext4 -F "${work_dir}/squashfsroot/LiveOS/rootfs.img"
    mkfs.ext4 -O '^has_journal,^resize_inode' -E 'lazy_itable_init=0' -m 0 -F -- "${work_dir}/squashfsroot/LiveOS/rootfs.img" 32G
    tune2fs -c 0 -i 0 -- "${work_dir}/squashfsroot/LiveOS/rootfs.img" > /dev/null
    _msg_info "Done!"

    _msg_info "Mount rootfs image..."
    mount -o loop,rw,sync "${work_dir}/squashfsroot/LiveOS/rootfs.img" "${work_dir}/airootfs"

    _msg_info "Installing Base System to '${work_dir}/airootfs'..."
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
    umount_chroot_airootfs

    # Check codename
    if ! grep -h -v ^'#' "${channels_dir}/${channel_name}/codename.${arch}" | grep -x "${codename}" 1> /dev/null 2>&1 ; then
        _msg_error "This codename (${codename}) is not supported on this channel (${codename})."
        exit 1
    fi

    # Gitversion
    if [[ "${gitversion}" = true ]]; then
        cd "${script_path}"
        iso_version="${iso_version}-$(git rev-parse --short HEAD)"
        cd "${OLDPWD}"
    fi

    # Generate iso filename
    local _channel_name="${channel_name%.add}-${locale_name}"
    iso_filename="${iso_name}-${codename}-${_channel_name}-${iso_version}-${arch}.iso"

    # Re-run with tee
    if [[ ! "${logging}" = false ]]; then
        if [[ "${customized_logpath}" = false ]]; then
            logging="${out_dir}/${iso_filename%.iso}.log"
        fi
        mkdir -p "$(dirname "${logging}")"; touch "${logging}"
        _msg_debug "Re-run 'sudo ${0} ${*} --nolog 2>&1 | tee ${logging}'"
        sudo ${0} "${@}" --nolog 2>&1 | tee ${logging}
        exit "${?}"
    fi

    mkdir -p "${out_dir}"
}

make_systemd() {
    _dnf_install dbus-tools
    run_cmd dbus-uuidgen --ensure=/etc/machine-id
    mkdir -p "${work_dir}/airootfs/var/lib/dbus"
    run_cmd ln -sf /etc/machine-id /var/lib/dbus/machine-id
}

make_repo_packages() {    
    local _pkglist=($("${script_path}/tools/pkglist-repo.sh" -a "x86_64" -c "${channels_dir}/${channel_name}" -k "${codename}" -l "${locale_name}" $(if [[ "${bootsplash}" = true ]]; then echo -n "-b"; fi) ))
    if (( "${#_pkglist[@]}" != 0 )); then
        # Create a list of packages to be finally installed as packages.list directly under the working directory.
        echo -e "# The list of packages that is installed in live cd.\n#\n\n" > "${work_dir}/packages.list"
        # Install packages on airootfs
        mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
        run_cmd dnf -y --nogpgcheck -c /dnf_conf install ${_pkglist[*]}
    fi
}

make_dnf_packages() {
    local  _pkglist=($("${script_path}/tools/pkglist.sh" -a "x86_64" -c "${channels_dir}/${channel_name}" -l "${locale_name}" $(if [[ "${bootsplash}" = true ]]; then echo -n "-b"; fi) ))

    # Create a list of packages to be finally installed as packages.list directly under the working directory.
    echo -e "\n# The list of packages that is installed from dnf file in live cd.\n#\n\n" >> "${work_dir}/packages.list"
    printf "%s\n" "${_pkglist[@]}" >> "${work_dir}/packages.list"

    # Install packages on airootfs
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    run_cmd dnf -y --nogpgcheck -c /dnf_conf install ${_pkglist[*]}
}

make_cp_airootfs() {
    local _airootfs_list=(
        "${channels_dir}/share/airootfs" "${channels_dir}/share/airootfs.${locale_name}"
        "${channels_dir}/${channel_name}/airootfs" "${channels_dir}/${channel_name}/airootfs.${locale_name}"
    )

    for _dir in ${_airootfs_list[@]}; do
        if [[ -d "${_dir}" ]]; then
            cp -af "${_dir}"/* "${work_dir}/airootfs"
        fi
    done
}

make_config() {
    # customize_airootfs options
    # -b                        : Enable boot splash.
    # -d                        : Enable debug mode.
    # -g <locale_gen_name>      : Set locale-gen.
    # -i <inst_dir>             : Set install dir
    # -l <locale_name>          : Set language.
    # -o <os name>              : Set os name.
    # -p <password>             : Set password.
    # -s <shell>                : Set user shell.
    # -t                        : Set plymouth theme.
    # -u <username>             : Set live user name.
    # -x                        : Enable bash debug mode.
    # -z <locale_time>          : Set the time zone.

    local _main_script="root/customize_airootfs.sh" _script_list=("${work_dir}/airootfs/root/customize_airootfs_${channel_name}.sh")
    local _file_fullpath="${work_dir}/airootfs/${_main_script}"
    local _airootfs_script_options="-p ${liveuser_password} -u ${liveuser_name} -o ${os_name} -s ${liveuser_shell} -a ${arch} -g ${locale_gen_name} -l ${locale_name} -z ${locale_time}"
    if [[ "${bootsplash}" == true ]]; then
        _airootfs_script_options+=" -b"
    fi

    # Create script
    for _script in ${_script_list[@]}; do
        if [[ -f "${_script}" ]]; then
            echo -e "\n" >> "${_file_fullpath}"
            cat "${_script}" >> "${_file_fullpath}"
            remove "${_script}"
        fi
    done

    if [[ -f "${_file_fullpath}" ]]; then 
        chmod 755 "${_file_fullpath}"
        run_cmd "/${_main_script}" ${_airootfs_script_options}
        remove "${_file_fullpath}"
    fi
}

make_clean() {
    mount --bind "${cache_dir}" "${work_dir}/airootfs/dnf_cache"
    run_cmd dnf -c /dnf_conf -y remove $(run_cmd dnf -c /dnf_conf repoquery --installonly --latest-limit=-1 -q)
}
make_initramfs() { 
    remove "${bootfiles_dir}"
    mkdir -p "${bootfiles_dir}"/{loader,LiveOS,boot,isolinux}
    #generate initrd
    _msg_info "make initrd..."
    run_cmd dracut --xz --add "dmsquash-live convertfs pollcdrom" --no-hostonly --no-early-microcode /boot/initrd0 `run_cmd ls /lib/modules`
    cp "${work_dir}/airootfs/boot/vmlinuz-$(run_cmd ls /lib/modules)" "${bootfiles_dir}/boot/vmlinuz"
    mv "${work_dir}/airootfs/boot/initrd0" "${bootfiles_dir}/boot/initrd"
}

make_boot(){
    cp "${work_dir}/airootfs/usr/lib/systemd/boot/efi/systemd-bootx64.efi" "${bootfiles_dir}/systemd-bootx64.efi"
    #cp isolinux
    cp "${nfb_dir}/isolinux/"* "${bootfiles_dir}/isolinux/"
}

make_squashfs() {
    # prepare
    remove "${work_dir}/airootfs/dnf_cache"
    # make squashfs
    remove "${work_dir}/airootfs/boot"
    mkdir "${work_dir}/airootfs/boot"
    cp ${bootfiles_dir}/boot/vmlinuz ${work_dir}/airootfs/boot/vmlinuz-$(run_cmd ls /lib/modules)
    kernelkun=$(run_cmd ls /lib/modules)
    echo -e "\nkernel-install add ${kernelkun} /boot/vmlinuz-${kernelkun}\ngrub2-mkconfig" >> "${work_dir}/airootfs/usr/share/calamares/final-process"
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
    sed "s|%OS_NAME%|${os_name}|g; s|%CD_LABEL%|${iso_label}|g" "${nfb_dir}/isolinux.cfg" > "${bootfiles_dir}/isolinux/isolinux.cfg"
    if [[ ${bootsplash} = true ]]; then
        sed -i "s|selinux=0|selinux=0 quiet splash|g" "${bootfiles_dir}/isolinux/isolinux.cfg"
    fi

    # Systemd Boot
    mkdir -p "${bootfiles_dir}/loader/entries"
    for confkun in ${nfb_dir}/systemd-boot/entries/*; do
        local basenamekun=$(basename "${confkun}")
        sed "s|%OS_NAME%|${os_name}|g" ${confkun} | sed "s|%CD_LABEL%|${iso_label}|g" | sed "s|%KERNEL%|/boot/vmlinuz|g" | sed "s|%INITRAMFS%|/boot/initrd|g" > "${bootfiles_dir}/loader/entries/${basenamekun}"
    done
    cp "${nfb_dir}/Shell_Full.efi" "${bootfiles_dir}/Shell_Full.efi"
}

make_efi() {
    # create efiboot.img
    truncate -s 200M "${work_dir}/efiboot.img"
    mkfs.fat -F 16 -f 1 -r 112 "${work_dir}/efiboot.img"
    mkdir -p "${bootfiles_dir}/mnt" "${bootfiles_dir}/mnt/EFI/BOOT/" "${bootfiles_dir}/EFI/Boot/"
    mount "${work_dir}/efiboot.img" "${bootfiles_dir}/mnt"

    # Copy files
    cp "${bootfiles_dir}/systemd-bootx64.efi" "${bootfiles_dir}/mnt/EFI/BOOT/bootx64.efi"
    cp "${bootfiles_dir}/systemd-bootx64.efi" "${bootfiles_dir}/EFI/Boot/bootx64.efi"
    remove "${bootfiles_dir}/systemd-bootx64.efi"
    cp "${bootfiles_dir}/Shell_Full.efi" "${bootfiles_dir}/mnt/"
    cp "${bootfiles_dir}/boot/vmlinuz" "${bootfiles_dir}/mnt/"
    cp "${bootfiles_dir}/boot/initrd" "${bootfiles_dir}/mnt/"

    mkdir -p "${bootfiles_dir}/mnt/loader/entries/"
    for confkun in "${nfb_dir}/systemd-boot/entries/"*; do
        local basenamekun="$(basename "${confkun}")"
        sed "s|%OS_NAME%|${os_name}|g" ${confkun} | sed "s|%CD_LABEL%|${iso_label}|g" | sed "s|%KERNEL%|/vmlinuz|g" | sed "s|%INITRAMFS%|/initrd|g" > "${bootfiles_dir}/mnt/loader/entries/${basenamekun}"
    done
    if [[ ${bootsplash} = true ]]; then
        sed "s|%NOSPLASH%||g" "${nfb_dir}/systemd-boot/loader.conf" > "${bootfiles_dir}/mnt/loader/loader.conf"
    else
        sed "s|%NOSPLASH%|_nosplash|g" "${nfb_dir}/systemd-boot/loader.conf" > "${bootfiles_dir}/mnt/loader/loader.conf"
    fi
    
    umount -d "${bootfiles_dir}/mnt"
    remove "${bootfiles_dir}/mnt"
}
make_iso() {
    cd "${bootfiles_dir}"

    # create checksum (using at booting)
    bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -xv "\./md5sum.txt" > md5sum.txt)"

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
        -append_partition 2 C12A7328-F81F-11D2-BA4B-00A0C93EC93B \
            ${work_dir}/efiboot.img -appended_part_as_gpt \
        -eltorito-alt-boot \
            -e \
            --interval:appended_partition_2:all:: \
            -no-emul-boot \
        -isohybrid-mbr "${bootfiles_dir}/isolinux/isohdpfx.bin" \
        -isohybrid-gpt-basdat \
        -eltorito-catalog isolinux/boot.cat \
        -output "${out_dir}/${iso_filename}" \
        -graft-points \
            "." \
            "/isolinux/isolinux.bin=isolinux/isolinux.bin"
    
    cd "${OLDPWD}"
}

make_checksum() {
    cd "${out_dir}"
    _msg_info "Creating md5 checksum ..."
    md5sum "${iso_filename}" > "${iso_filename}.md5"

    _msg_info "Creating sha256 checksum ..."
    sha256sum "${iso_filename}" > "${iso_filename}.sha256"
    cd "${OLDPWD}"
    umount_chroot_airootfs
}

# 引数解析 参考記事：https://0e0.pw/ci83 https://0e0.pw/VJlg
OPTS="a:bc:dhl:o:w:x"
OPTL="arch:,bootsplash,cache:,debug,help,lang:,out:,work:,cache-only,bash-debug,gitversion,log,logpath:,nolog"
if ! OPT="$(getopt -o ${OPTS} -l ${OPTL} -- "${@}")"; then
    exit 1
fi
eval set -- "${OPT}"

while true; do
    case "${1}" in
        -a | --arch)
            #arch="${2}"
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
        --log)
            logging=true
            shift 1
            ;;
        --logpath)
            logging="${2}"
            customized_logpath=true
            shift 2
            ;;
        --nolog)
            logging=false
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

# Check root.
if (( ! "${EUID}" == 0 )); then
    _msg_warn "This script must be run as root." >&2
    _msg_warn "Re-run 'sudo ${0} ${*}'"
    sudo ${0} "${@}"
    exit "${?}"
fi

# Arch Linuxかどうかチェック
# /etc/os-releaseのIDがarchかどうかで判定
if ( source "/etc/os-release"; if [[ "${ID}" = "arch" ]]; then true; else false; fi); then
    grub2_standalone_cmd="grub-mkstandalone"
fi

bootfiles_dir="${work_dir}/bootfiles"
trap 'umount_chroot_airootfs' 0 2 15

if [[ -n "${1}" ]]; then
    channel_name="${1}"
    check_channel() {
        while read -r _channel; do
            if [[ -n "$(ls "${channels_dir}/${_channel}")" ]] && [[ ! "${_channel}" = "share" ]] && [[ "${_channel}" = "${channel_name}" ]]; then
                return 0
            fi
        done < <(ls -l "${channels_dir}" | awk '$1 ~ /d/ {print $9 }')
        return 1
    }

    case "${channel_name}" in
        "umount")
            umount_chroot_airootfs
            exit 0
            ;;
        "clean")
            umount_chroot_airootfs
            _msg_info "deleting work dir..."
            remove "${work_dir}"
            exit 0
            ;;
        *)
            if ! check_channel "${channel_name}"; then
                _msg_error "Invalid channel ${channel_name}"
                exit 1
            fi
            ;;
    esac
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
run_once make_initramfs
run_once make_boot
run_once make_squashfs
run_once make_nfb
run_once make_efi
run_once make_iso
run_once make_checksum
