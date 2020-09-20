FROM fedora:32
RUN echo 'nameserver 1.1.1.1' > /etc/resolv.conf
RUN dnf update -y
RUN dnf install -y squashfs-tools grub2 e2fsprogs
COPY . /lfbs
WORKDIR /lfbs
#RUN git checkout dev
CMD ["./lfbs", "releng"]
