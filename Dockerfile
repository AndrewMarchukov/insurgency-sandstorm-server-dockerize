FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive
RUN     apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
        lib32gcc-s1 \
        curl \
        ca-certificates \
        locales && \
        locale-gen "en_US.UTF-8" && \
        export LC_ALL="en_US.UTF-8" && \
        useradd -m steam && \
        su "steam" -c \
        "mkdir -p /home/steam/steamcmd && cd /home/steam/steamcmd && \
        curl -o steamcmd_linux.tar.gz "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
        tar zxf steamcmd_linux.tar.gz && \
        rm steamcmd_linux.tar.gz" && \
        apt-get remove --purge -y curl && \
        apt-get clean autoclean && \
        apt-get autoremove -y && \
        rm -rf /var/lib/{apt,dpkg} /var/{cache,log} && \
        su "steam" -c "./home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/steamcmd/sandstorm/ +login anonymous +app_update 581330 validate +quit && \
        mkdir -p /home/steam/steamcmd/sandstorm/Insurgency/Saved/SaveGames"
WORKDIR /home/steam/steamcmd
USER steam
ENTRYPOINT /home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/steamcmd/sandstorm/ +login anonymous +app_update 581330 +quit && \
           /home/steam/steamcmd/sandstorm/Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping ${LAUNCH_SERVER_ENV} -hostname="$HOSTNAME" -Port=$PORT -QueryPort=$QUERYPORT
