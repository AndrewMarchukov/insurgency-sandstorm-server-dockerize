#!/bin/bash
while true ; do
sleep $(( ( RANDOM % 360 )  + 60 ))
LOCALAPPVER=$(cat /opt/sandstorm-server.version)
REMOTEAPPVER=$(curl -s -X GET 'https://api.steamcmd.net/v1/info/581330' | jq -r -e '.data."581330".depots."581333".manifests.public')
EXITSTATUS=$?
if [ $EXITSTATUS -eq 0 ]; then
if [ "$LOCALAPPVER" != "$REMOTEAPPVER" ]; then
/opt/restart-ins.sh
fi
fi
done