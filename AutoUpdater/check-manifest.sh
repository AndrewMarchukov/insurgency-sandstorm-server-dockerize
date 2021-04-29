#!/bin/bash
rconlist=127.0.0.1:55555,127.0.0.1:44444,127.0.0.1:33333
rconpass=my_rcon_password

while true; do
    TOTAL=0
    sleep $(((RANDOM % 360) + 60))
    for rconip in $(echo "${rconlist//,/ }"); do
        PLAYERSCOUNT=$(rcon -a "$rconip" -p "$rconpass" listplayers | tail -n +3 | wc -l)
        TOTAL=$(("$PLAYERSCOUNT" + "$TOTAL"))
    done
    if [ $TOTAL -eq 0 ]; then
        LOCALAPPVER=$(cat /opt/sandstorm-server.version)
        REMOTEAPPVER=$(curl -s -X GET 'https://api.steamcmd.net/v1/info/581330' | jq -r -e '.data."581330".depots."581333".manifests.public')
        EXITSTATUS=$?
        if [ $EXITSTATUS -eq 0 ]; then
            if [ "$LOCALAPPVER" != "$REMOTEAPPVER" ]; then
                for n in {60..1}; do
                    for rconip in $(echo "${rconlist//,/ }"); do
                        rcon -a "$rconip" -p "$rconpass" "say 'THE SERVER WILL BE RESTARTED IN $n'"
                        sleep 1
                    done
                done
                /opt/restart-ins.sh
            fi
        fi
    fi
done
