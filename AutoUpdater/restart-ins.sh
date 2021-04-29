#!/bin/bash
LOCALAPPVER=$(curl -s -X GET 'https://api.steamcmd.net/v1/info/581330' | jq -r -e '.data."581330".depots."581333".manifests.public')
EXITSTATUS=$?
if [ $EXITSTATUS -eq 0 ]; then
  echo "$LOCALAPPVER" >/opt/sandstorm-server.version
  for n in {60..1}; do
    for rconip in $(echo "${rconlist//,/ }"); do
      rcon -a "$rconip" -p "$rconpass" "say 'THE SERVER WILL BE RESTARTED IN $n'"
      sleep 1
    done
  done
  docker stop sandstorm-modmap
  docker rm sandstorm-modmap
  docker pull andrewmhub/insurgency-sandstorm
  docker run -d --restart always --env-file /home/user/coop-modmap/modmap.env \
    --name sandstorm-modmap --net=host \
    -v /home/user/coop-modmap/Mods:/home/steam/steamcmd/sandstorm/Insurgency/Mods:rw \
    -v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
    -v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest
fi
