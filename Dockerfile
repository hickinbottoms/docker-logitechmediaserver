# baseimage-docker (Ubuntu 16.04 release)
FROM phusion/baseimage:0.9.19
MAINTAINER Justifiably <justifiably@ymail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget

# Dependencies first
RUN echo "deb http://www.deb-multimedia.org jessie main non-free" | tee -a /etc/apt/sources.list && \
    apt-get update && apt-get install -y --force-yes deb-multimedia-keyring

# unfortunately this ends up pulling in X server and extra crud.
# Need --force-yes because not all are signed even with above keyring (libaac etc)
# - ffmpeg: needed for ALAC
RUN apt-get install -y --force-yes \
    perl \
    locales \
    faad \
    faac \
    flac \
    lame \
    sox \
    wavpack
# ffmpeg inconsistent

# Dependencies for shairport (https://github.com/disaster123/shairport2_plugin/)
RUN apt-get install -y --force-yes \
    libcrypt-openssl-rsa-perl \
    libio-socket-inet6-perl \
    libwww-perl \
    dbus avahi-daemon avahi-utils \
    libio-socket-ssl-perl && \
    wget -O /tmp/netsdp.deb http://www.inf.udec.cl/~diegocaro/rpi/libnet-sdp-perl_0.07-1_all.deb && \
    dpkg -i /tmp/netsdp.deb && \
    rm -f /tmp/netsdp.deb

# Pre-compile helper app for shairport
RUN apt-get install -y unzip build-essential libssl-dev libao-dev pkg-config

RUN \
    mkdir /tmp/st && \
    wget -O /tmp/st/ShairTunes.zip https://raw.github.com/StuartUSA/shairport_plugin/master/ShairTunes.zip && \
    (cd /tmp/st; unzip ShairTunes.zip; cd shairport_helper/src; make; cp -p shairport_helper /usr/local/bin)

ARG LMSDEB=http://downloads.slimdevices.com/nightly/7.9/sc/afcfc6d/logitechmediaserver_7.9.0~1480066117_all.deb
RUN wget -O /tmp/lms.deb $LMSDEB && \
    dpkg -i /tmp/lms.deb && \
    rm -f  /tmp/lms.deb


RUN echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Cleanup
RUN apt-get -y remove wget unzip build-essential libssl-dev libssl-dev libao-dev pkg-config && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
        
# Move config dir to allow editing convert.conf
RUN useradd --system --uid 819 -M -s /bin/false -d /usr/share/squeezeboxserver -c "Logitech Media Server user" lms && \
    mkdir -p /mnt/state/etc && \
    mv /etc/squeezeboxserver /etc/squeezeboxserver.orig && \
    cp -pr /etc/squeezeboxserver.orig/* /mnt/state/etc && \
    ln -s /mnt/state/etc /etc/squeezeboxserver && \
    chown -R squeezeboxserver.lms /mnt/state

RUN mkdir /etc/service/lms /etc/service/avahi /etc/service/dbus
COPY lms-run.sh /etc/service/lms/run
COPY avahi-run.sh /etc/service/avahi/run
COPY dbus-run.sh /etc/service/dbus/run
COPY lms-setup.sh dbus-setup.sh avahi-setup.sh startup.sh /
COPY avahi-daemon.conf /etc/avahi/avahi-daemon.conf


VOLUME ["/mnt/state","/mnt/music","/mnt/playlists"]
EXPOSE 3483 3483/udp 9000 9005 9010 9090 5353

CMD ["/startup.sh"]

