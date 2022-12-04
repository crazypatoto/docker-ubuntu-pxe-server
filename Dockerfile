FROM ubuntu:20.04

MAINTAINER Darren Chi <crazypatoto@gmail.com>

# Install necessary packages
RUN \
    apt-get update && \
    apt-get install -y nano dnsmasq pxelinux syslinux-efi

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

COPY pxelinux.cfg/ /mnt/data/netboot/pxelinux.cfg

WORKDIR /mnt/data/netboot
RUN \
    ln -rs pxelinux.cfg bios && ln -rs pxelinux.cfg efi64

# Configure DNSMASQ
COPY etc/ /etc

ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=192.168.87.0,proxy"]


