FROM fedora:33
RUN echo 'nameserver 1.1.1.1' > /etc/resolv.conf
RUN echo 'keepcache = 1' >> /etc/dnf/dnf.conf
RUN dnf update -y
RUN dnf install -y squashfs-tools grub2 grub2-tools-extra e2fsprogs grub2-efi-ia32-modules grub2-efi-x64-modules dosfstools xorriso
RUN dnf makecache
COPY . /lfbs
WORKDIR /lfbs
#RUN git checkout dev
ENTRYPOINT ["./lfbs"]
CMD []
