FROM ubuntu:latest
ENV CONFIGINI /home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer
ENV CONFIGTXT /home/steam/steamcmd/sandstorm/Insurgency/Config/Server

ENV HOSTNAME="MY COOP DEFAULT SERVER" PORT=42433 QUERYPORT=42434


RUN apt-get update && apt-get install -y \
        lib32gcc1 \
        curl && \
        apt-get -y upgrade && \
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

COPY config/ini/ ${CONFIGINI}
COPY config/txt/ ${CONFIGTXT}

ENTRYPOINT ./home/steam/steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/steam/steamcmd/sandstorm/ +app_update 581330 +quit && \
./home/steam/steamcmd/sandstorm/Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping -hostname=$HOSTNAME -Port=$PORT -QueryPort=$QUERYPORT -MapCycle=MapCycle