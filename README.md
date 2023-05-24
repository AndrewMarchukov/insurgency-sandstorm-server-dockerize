## Insurgency: Sandstorm Docker Container
[![Docker Image CI](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/actions/workflows/docker-image.yml/badge.svg)](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/actions/workflows/docker-image.yml)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/andrewmhub/insurgency-sandstorm/lite?label=image%20size%20lite&logo=docker)](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/andrewmhub/insurgency-sandstorm/latest?label=image%20size%20latest&logo=docker)](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm)
[![Docker Pulls](https://img.shields.io/docker/pulls/andrewmhub/insurgency-sandstorm?color=red&logo=docker)](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm)

<p align="center">
  <img src="https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/sandstorm-logo.png">
  <img src="https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/docker-logo.png"
</p>
</p>

<details>
  <summary>Changelog</summary>

```
Feb, 2022
some fixes in modmap.env
mod.io token moved from Engine.ini to GameUserSettings.ini (because NWI)
fixed steam warning in dockerfile "Please use force_install_dir before logon!"
changed readme
changed ENTRYPOINT now you can use LAUNCH_SERVER_ENV to set map
new options on ini files
Nov, 2022
added lite version, because it's become so beefy
```
</details>

This repository contains a docker image with a dedicated server for Insurgency Sandstorm that you can fully customize to your need for COOP and PVP servers.

This image will be built any time there are updates to the steam app or upstream docker image, so you don’t have to update anything inside a container. I tried to build the image as “best-practice” as possible and to document everything for you.
#### Official documentation: [Sandstorm Server Admin Guide](https://sandstorm-support.newworldinteractive.com/hc/en-us/articles/360049211072-Server-Admin-Guide)
#### Another Server Admin Guide [Server Admin Guide by mod.io](https://insurgencysandstorm.mod.io/guides/server-admin-guide)
#### More config examples: [Configs by zWolfi](https://github.com/zWolfi/INS_Sandstorm)
#### ISMC Guide: [ISMCmod Installation Guide](https://insurgencysandstorm.mod.io/guides/ismcmod-installation-guide)

## How to build/get Insurgency Sandstorm dedicated server
cd directory where ```Dockerfile```
```docker build -t andrewmhub/insurgency-sandstorm:latest .``` or get it on [docker hub](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm) ```docker pull andrewmhub/insurgency-sandstorm```
## How to launch Insurgency Sandstorm dedicated server
Running multiple instances (use PORT, QUERYPORT and HOSTNAME) and LAUNCH_SERVER_ENV in [modmap.env](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/modmap.env): 
```
docker run -d --restart unless-stopped --env-file /home/user/coop-modmap/modmap.env \
--name sandstorm-modmap --net=host \
-v /home/user/coop-modmap/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw \
-v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
-v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest
```
#### Lite version

All game data will be stored on disk
```
docker run -d --restart unless-stopped --env-file /home/user/coop-modmap/modmap.env \
--name sandstorm-modmap --net=host \
-v /home/user/my_dir:/home/steam/steamcmd/sandstorm:rw \
 andrewmhub/insurgency-sandstorm:lite
```

Examples config files in directory [config](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/tree/master/config)

Optional launch options:

```-NoEAC``` have problem with EAC just disables it

```-nominidumps``` some crash dump handler that uploads crash information to insurgency devs servers this option disables it 

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
      - "${PORT}:${PORT}/udp"
      - "${QUERYPORT}:${QUERYPORT}/udp"
```
### .env example

```.env
HOSTNAME=[ISMC] MOD MAPS ONLY @120hz
PORT=12345
QUERYPORT=54321
LAUNCH_SERVER_ENV=LAUNCH_SERVER_ENV=Ministry?Scenario=Scenario_Ministry_Checkpoint_Security?Game=CheckpointHardcore?password=MyPa$$word?MaxPlayers=10 -MapCycle=MapCycle -Mods -ModList=Mods.txt -mutators="ISMCarmory_legacy,ImprovedAI,NoRestrictedArea,ScaleBotAmount,AdvancedSupplyPoints,WelcomeMessage,JoinLeaveMessage,FpLegs,JumpShoot" -GameStatsToken=my_token -GameStats -GSLTToken=my_token -ModDownloadTravelTo=TORO?Scenario=Scenario_TORO_Checkpoint_Security
```

## Server auto update
Autoupdate game server. This script will keep your game servers automaticly updated updating intervals announce the server is shutting down for updates

Requirements: [rcon-cli](https://github.com/gorcon/rcon-cli/releases)
```
wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.1/rcon-0.10.1-amd64_linux.tar.gz
tar -xvzf rcon-0.10.1-amd64_linux.tar.gz
cp rcon-0.10.1-amd64_linux/rcon /usr/local/bin/
```

Get restart script example

```
wget --no-check-certificate -O /opt/restart-ins.sh https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/AutoUpdater/restart-ins.sh
chmod +x /opt/restart-ins.sh
```
The next script make version comparison
if game server version changed in steam or ISMC mod version you insurgency sandstorm server will automatically restarted and get update

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
## Tips and Tricks
### How to save RAM on UE4 Linux(Docker) dedicated server

if you launch multiple servers on same host you can save some memory, on 2 game servers more than 1gb memory saved.

Make sure that parameter set on 1 after host reboot

```echo 1 > /sys/kernel/mm/ksm/run```

and add launch options ```-useksm -ksmmergeall``` then restart servers

wait some amount of time and check statistics ```grep -H '' /sys/kernel/mm/ksm/*```

```pages_shared``` - how many shared pages are being used

```pages_sharing``` - how many more sites are sharing them i.e. how much saved

```pages_unshared``` - how many pages unique but repeatedly checked for merging

```pages_sharing*4096/1024/1024=how much memory saved```

So, in your example, 264281 pages have been found to be shareable. KSM saved you about 1032 MB of memory.
