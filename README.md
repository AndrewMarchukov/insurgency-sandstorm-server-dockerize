![](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/sandstorm-logo.png)
![](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/docker-logo.jpg)
## How to build
cd directory where ```Dockerfile```
```docker build -t sandstorm:latest .``` or get it on docker hub ```docker pull andrewmhub/insurgency-sandstorm```
## How to launch
Running multiple instances (use PORT, QUERYPORT and HOSTNAME) and LAUNCH_SERVER_ENV in modmap.env:
```
docker run -d --restart always --env-file /home/user/coop-modmap/modmap.env \
--name sandstorm-modmap -p 12345:12345/udp -p 54321:54321/udp \
-v /home/user/coop-modmap/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw \
-v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
-v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro sandstorm:latest
```
Examples config files see directory ```config```

### Official documentation: [Server Admin Guide](https://sandstorm-support.newworldinteractive.com/hc/en-us/articles/360049211072-Server-Admin-Guide)
#### Source in github: [Insurgency: Sandstorm docker server](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize)


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
