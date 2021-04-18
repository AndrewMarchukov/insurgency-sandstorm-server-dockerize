FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update && apt-get install --no-install-recommends -y \
        lib32gcc1 \
        curl \
        ca-certificates \
        language-pack-en-base \
        locales && \
        apt-get -y upgrade && \
        locale-gen "en_US.UTF-8" && \
        export LC_ALL="en_US.UTF-8" && \
        apt-get clean autoclean && \
        apt-get autoremove -y && \
        rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
        useradd -m steam

USER steam

RUN mkdir -p /home/steam/steamcmd && cd /home/steam/steamcmd && \
        curl -o steamcmd_linux.tar.gz "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
        tar zxf steamcmd_linux.tar.gz && \
        rm steamcmd_linux.tar.gz

RUN ./home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/steamcmd/sandstorm/ +app_update 581330 validate +quit

ENTRYPOINT /home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/steamcmd/sandstorm/ +app_update 581330 +quit && \
/home/steam/steamcmd/sandstorm/Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping -hostname="$HOSTNAME" -Port=$PORT -QueryPort=$QUERYPORT ${LAUNCH_SERVER_ENV}
