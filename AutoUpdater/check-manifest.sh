#!/bin/bash
rconlist=127.0.0.1:55555,127.0.0.1:44444,127.0.0.1:33333
rconpass=my_rcon_password
modio_api_key=my_modio_apikey_!NOT_OAuth2_KEY!

while true; do
    TOTAL=0
    sleep $(((RANDOM % 360) + 60))
    for rconip in $(echo "${rconlist//,/ }"); do
        PLAYERSCOUNT=$(rcon -a "$rconip" -p "$rconpass" listplayers | tail -n +3 | wc -l)
        TOTAL=$(("$PLAYERSCOUNT" + "$TOTAL"))
    done
    #CHECKING NEW GAME VERSION
    if [ $TOTAL -eq 0 ]; then
        LOCALAPPVER=$(cat /opt/sandstorm-server.version)
        REMOTEAPPVER=$(curl -s -X GET 'https://api.steamcmd.net/v1/info/581330' | jq -r -e '.data."581330".depots."581333".manifests.public')
        EXITSTATUS=$?
        if [ $EXITSTATUS -eq 0 ]; then
            #CHECKING ISMC NEW VERSION
            LOCALMODVER=$(cat /opt/sandstorm-mod.version)
            REMOTEMODVER=$(curl -s -X GET "https://api.mod.io/v1/games/254/mods/150867?api_key=$modio_api_key" -H 'Accept: application/json' | jq -r -e .modfile.filehash.md5)
            EXITSTATUS=$?
            if [ $EXITSTATUS -eq 0 ]; then
                if [[ ("$LOCALAPPVER" != "$REMOTEAPPVER" || "$LOCALMODVER" != "$REMOTEMODVER") ]]; then
                    echo "$REMOTEAPPVER" >/opt/sandstorm-server.version
                    echo "$REMOTEMODVER" >/opt/sandstorm-mod.version
                    for n in {60..1}; do
                        for rconip in $(echo "${rconlist//,/ }"); do
                            rcon -a "$rconip" -p "$rconpass" "say 'THE SERVER WILL BE RESTARTED IN $n'"
                            sleep 1
                        done
                    done
                    #START OF BLOCK WHERE YOU CAN WRITE RESTART COMMANDS
                    /opt/restart-ins.sh
                    #END BLOCK WHERE YOU CAN WRITE RESTART COMMANDS
                fi
            fi
        fi
    fi
done
