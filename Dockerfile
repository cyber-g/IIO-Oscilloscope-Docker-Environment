# Environnement de développement Docker pour osc de analog devices
FROM ubuntu:latest

# https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ENV DEBIAN_FRONTEND noninteractive

RUN (apt-get update && apt-get upgrade -y -q \
&& apt-get dist-upgrade -y -q \
&& apt-get -y -q autoclean \
&& apt-get -y -q autoremove)

# Install convenient tools for working on the host
RUN apt-get install -y bash-completion vim git wget tree unzip cmake

WORKDIR /root
RUN cp /etc/skel/.bashrc .

# Instructions from : 
# https://wiki.analog.com/resources/tools-software/linux-software/iio_oscilloscope#linux

# 1/ Install libraries
RUN apt-get -y install libglib2.0-dev libgtk2.0-dev libgtkdatabox-dev \
libmatio-dev libfftw3-dev libxml2 libxml2-dev bison flex libavahi-common-dev \
libavahi-client-dev libcurl4-openssl-dev libjansson-dev cmake libaio-dev libserialport-dev

# 2/ build and install the libiio library
RUN apt-get install -y libxml2 libxml2-dev bison flex libcdk5-dev cmake
RUN apt-get install -y libaio-dev libusb-1.0-0-dev libserialport-dev libxml2-dev libavahi-client-dev

RUN git clone https://github.com/analogdevicesinc/libiio.git
WORKDIR /root/libiio
RUN cmake . 
RUN make -j4 all
RUN make -j4 install 
# This will build and install libiio to /usr.

# 3/ install the libad9361-iio library
RUN apt-get install -y libad9361-dev

# 4/ build and install Application
WORKDIR /root
RUN git clone https://github.com/analogdevicesinc/iio-oscilloscope.git
WORKDIR /root/iio-oscilloscope
RUN mkdir build 
WORKDIR /root/iio-oscilloscope/build
RUN cmake .. 
RUN make -j4
RUN make -j4 install

# Pour éxecuter osc, il faut configurer ldconfig (voir google doc pour plus d'explications)
RUN ldconfig /usr/lib

# Il faut aussi installer Avahi (voir google doc pour plus d'explications)
WORKDIR /root
RUN apt-get install -y avahi-daemon avahi-discover avahi-utils

# Il faut configurer avahi
RUN sed -i -e 's/#enable-dbus=yes/enable-dbus=no/' /etc/avahi/avahi-daemon.conf

# Il faut aussi configurer D-Bus (voir google doc pour plus d'explications)
RUN mkdir -p /var/run/dbus
RUN dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address
RUN service avahi-daemon restart

# Entry point for the docker in interactive mode
# ENTRYPOINT /bin/bash
CMD ["osc"]
