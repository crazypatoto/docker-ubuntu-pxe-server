FROM ubuntu:20.04

MAINTAINER Darren Chi <crazypatoto@gmail.com>

# Install necessary packages
RUN \
    apt-get update && \
    apt-get install -y nano wget unzip dnsmasq pxelinux syslinux-efi

RUN \
    mkdir -p /mnt/data/netboot

RUN \
    bash -c 'mkdir /mnt/data/netboot/{bios,efi64}'

RUN \
    bash -c 'cp \
    /usr/lib/syslinux/modules/bios/{ldlinux,vesamenu,libcom32,libutil}.c32 \
    /usr/lib/PXELINUX/pxelinux.0 \
    /mnt/data/netboot/bios'

RUN \
    bash -c 'cp \
    /usr/lib/syslinux/modules/efi64/ldlinux.e64 \
    /usr/lib/syslinux/modules/efi64/{vesamenu,libcom32,libutil}.c32 \
    /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi \
    /mnt/data/netboot/efi64'

RUN \
    mkdir /mnt/data/netboot/pxelinux.cfg

# Configure PXE and TFTP
COPY pxelinux.cfg/ /mnt/data/netboot/pxelinux.cfg

WORKDIR /mnt/data/netboot
RUN \
    ln -rs pxelinux.cfg bios && ln -rs pxelinux.cfg efi64

# Configure DNSMASQ
COPY etc/ /etc

# Download & Install Memtest86
# WORKDIR /tmp
# RUN \
#     wget -q http://www.memtest.org/download/archives/5.31b/memtest86+-5.31b.bin.gz && \
#     gzip -d memtest86+-5.31b.bin.gz && \
#     mkdir -p /mnt/data/netboot/memtest && \
#     mv memtest86+-5.31b.bin /mnt/data/netboot/memtest/memtest86+

# Download & Install Clonezilla and Memtest
WORKDIR /tmp
RUN \
    wget 'https://sourceforge.net/projects/clonezilla/files/clonezilla_live_stable/3.0.2-21/clonezilla-live-3.0.2-21-amd64.zip' && \
    unzip -d clonezilla-live-3.0.2-21-amd64 'clonezilla-live-3.0.2-21-amd64.zip' && \
    bash -c 'mkdir /mnt/data/netboot/{clonezilla,memtest}' && \
    bash -c 'mv clonezilla-live-3.0.2-21-amd64/live/{filesystem.squashfs,initrd.img,vmlinuz} /mnt/data/netboot/clonezilla/' && \
    mv clonezilla-live-3.0.2-21-amd64/live/memtest /mnt/data/netboot/memtest/memtest

# Clean up
WORKDIR /mnt/data/netboot
RUN \
    rm -rf /tmp


ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=192.168.87.0,proxy"]


