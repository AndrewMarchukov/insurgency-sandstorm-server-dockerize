#!/bin/bash
docker stop sandstorm-modmap
docker rm sandstorm-modmap
docker run -d --restart always --env-file /home/user/coop-modmap/modmap.env \
--name sandstorm-modmap -p 12345:12345/udp -p 54321:54321/udp \
-v /home/user/coop-modmap/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw \
-v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
-v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest
curl -X GET 'https://api.steamcmd.net/v1/info/581330' | jq -r '.data."581330".depots."581333".manifests.public' > /opt/sandstorm-server.version