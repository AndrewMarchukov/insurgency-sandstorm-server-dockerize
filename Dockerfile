FROM ubuntu:noble-20260917
ENV DEBIAN_FRONTEND noninteractive
RUN     apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
        lib32gcc-s1 \
        curl \
        ca-certificates \
        locales \
        jq && \
        apt-get -y upgrade && \
        locale-gen "en_US.UTF-8" && \
        export LC_ALL="en_US.UTF-8" && \
        useradd -m steam && \
        su "steam" -c \
        "mkdir -p /home/steam/steamcmd && cd /home/steam/steamcmd && \
        curl -o steamcmd_linux.tar.gz "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" && \
        tar zxf steamcmd_linux.tar.gz && \
        rm steamcmd_linux.tar.gz" && \
        apt-get clean autoclean && \
        apt-get autoremove -y && \
        rm -rf /var/lib/{apt,dpkg} /var/{cache,log} && \
        su "steam" -c "for try in 1 2 3; do ./home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/steamcmd/sandstorm/ +login anonymous +app_update 581330 validate +quit && break; [ \$try = 3 ] && exit 1; sleep 15; done && \
        mkdir -p /home/steam/steamcmd/sandstorm/Insurgency/Saved/SaveGames /home/steam/mod.io"
WORKDIR /home/steam/steamcmd
COPY --chmod=755 entrypoint.sh modio /usr/local/bin/
USER steam
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
