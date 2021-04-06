## Build Serene Linux
There are two ways to build: using Fedora Linux on the actual machine, or building on Docker.
For how to build on Docker, please refer to [This procedure](DOCKER.md).

When building on a real machine, the OS must be Serene Linux (Beta8F or later) or Fedora Linux.
The following explains how to build on a real machine.



### Preparation

Get the source code.

```bash
git clone https://github.com/FascodeNet/LFBS.git
cd LFBS
```

Install the packages required for build.

```bash
dnf install -y squashfs-tools grub2 grub2-tools-extra e2fsprogs grub2-efi-ia32-modules grub2-efi-x64-modules dosfstools xorriso perl perl-core
```

### Build with options manually

```bash
./build.sh <options> <channel>
```

#### option

Run `./build.sh -h` for full options and usage.

 Purpose | Usage
--- | ---
Enable boot splash | -b
Japanese | -l ja
Specify output destination directory | -o [dir]
Specify working directory | -w [dir]
Enable debug messages | -d

#### An example
Do this to build under the following conditions.

 - Enable Plymouth
 - Specify working directory `/tmp/lfbs`
- Specify output directory `~/lfbs-out`

```bash
./build.sh -b -w /tmp/lfbs -o ~/lfbs-out
```

### Notes

#### About channel

Channels switch between packages to install and files to include.
This mechanism makes it possible to build various versions of Alter Linux.
The following channels are supported as of February 4, 2021.
See `./build.sh -h` for a complete list of channels.

Name | Purpose
--- | ---
serene | A port of the ubuntu-based Serene linux to Fedora.
lxde | Composed of Lxde and a little software
i3 |using i3, a dynamic tiling window manager inspired by wmii.
releng | A channel that can build a pure Fedora Linux live boot disk

