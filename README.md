## Insurgency: Sandstorm Docker Container
[![Docker Image CI](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/actions/workflows/docker-image.yml/badge.svg)](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/actions/workflows/docker-image.yml)

![](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/sandstorm-logo.png)
![](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/docker-logo.jpg)

This repository contains a docker image with a dedicated server for Insurgency Sandstorm that you can fully customise to your need for COOP and PVP servers.

This image will be build everyday so you don’t have to update anything inside a container. I tried to build the image as “best-practice” as possible and to document everything for you.
#### Official documentation: [Sandstorm Server Admin Guide](https://sandstorm-support.newworldinteractive.com/hc/en-us/articles/360049211072-Server-Admin-Guide)
## How to build Insurgency Sandstorm dedicated server
cd directory where ```Dockerfile```
```docker build -t andrewmhub/insurgency-sandstorm:latest .``` or get it on docker hub ```docker pull andrewmhub/insurgency-sandstorm```
## How to launch Insurgency Sandstorm dedicated server
Running multiple instances (use PORT, QUERYPORT and HOSTNAME) and LAUNCH_SERVER_ENV in modmap.env:
```
docker run -d --restart always --env-file /home/user/coop-modmap/modmap.env \
--name sandstorm-modmap --net=host \
-v /home/user/coop-modmap/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw \
-v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
-v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest
```
Examples config files see in directory ```config```

### docker-compose.yml example
```dockerfile
version: '3.7'
services:
  insurgency-sandstorm:
    image: andrewmhub/insurgency-sandstorm:latest
    container_name: insurgency-sandstorm
    restart: unless-stopped
    env_file:
       - .env
    volumes:
      - /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro
      - /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro
      - /home/user/coop-modmap/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw
    ports:
      - "${PORT}:${PORT}"
      - "${QUERYPORT}:${QUERYPORT}"
```
### .env example

```.env
HOSTNAME=[ISMC] MOD MAPS ONLY @120hz
PORT=12345
QUERYPORT=54321
LAUNCH_SERVER_ENV=-MapCycle=MapCycle -Mods ModList=Mods.txt -mutators=ISMCarmory_legacy,ImprovedAI,NoRestrictedArea,ScaleBotAmount,AdvancedSupplyPoints,WelcomeMessage,JoinLeaveMessage,FpLegs,JumpShoot -GameStatsToken=my_token -GameStats -GSLTToken=my_token -ModDownloadTravelTo=TORO?Scenario=Scenario_TORO_Checkpoint_Security
```

### Tips and Tricks
#### Server auto update
SteamCMD to autoupdate game server. This script will keep your game servers automaticly updated updating intervals announce the server is shutting down for updates

Requirements: [rcon-cli](https://github.com/gorcon/rcon-cli/releases)
```
wget https://github.com/gorcon/rcon-cli/releases/download/v0.9.1/rcon-0.9.1-amd64_linux.tar.gz
tar -xvzf rcon-0.9.1-amd64_linux.tar.gz
cp rcon-0.9.1-amd64_linux/rcon /usr/local/bin/
```

Get restart script example

in the end of server restart or start curl get last manifest server version on steam
```
wget --no-check-certificate -O /opt/restart-ins.sh https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/AutoUpdater/restart-ins.sh
chmod +x /opt/restart-ins.sh
```
The next script make version comparison
if game server version changed in steam you insurgency sandstorm server will automatically restarted and get update

```
wget --no-check-certificate -O /opt/check-manifest.sh https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/AutoUpdater/check-manifest.sh
chmod +x /opt/check-manifest.sh
```
Get systemd unit daemon
```
wget --no-check-certificate -O /etc/systemd/system/my-server-check.service https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/AutoUpdater/my-server-check.service
systemctl daemon-reload
systemctl enable my-server-check.service
systemctl start my-server-check.service
```
