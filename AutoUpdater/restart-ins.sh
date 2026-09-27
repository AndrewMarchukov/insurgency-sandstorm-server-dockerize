#!/bin/bash
docker stop sandstorm-modmap
docker rm sandstorm-modmap
docker pull andrewmhub/insurgency-sandstorm
docker run -d --restart unless-stopped --env-file /home/user/coop-modmap/modmap.env \
  --name sandstorm-modmap --net=host \
  --security-opt seccomp=/home/user/coop-modmap/seccomp-modio.json \
  -v sandstorm-modmap-modio:/home/steam/mod.io \
  -v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
  -v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest
