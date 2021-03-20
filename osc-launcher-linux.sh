#!/bin/bash

# Running GUI Applications inside Docker Containers
# https://medium.com/@SaravSun/running-gui-applications-inside-docker-containers-83d65c0db110

docker build -t oscdocker .

docker run -it --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \
--privileged -v /dev/bus/usb:/dev/bus/usb -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket  oscdocker

# User must be part of docker group and the script must started without sudo so that display works