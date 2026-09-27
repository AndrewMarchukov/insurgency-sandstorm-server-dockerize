#!/bin/bash

read -r -p "Dedicated mod.io account email: " MODIO_EMAIL
curl -sS -L -X POST   'https://g-254.modapi.io/v1/oauth/emailrequest?api_key=bbf3af200848aef28418c032a601e7a2'   \
                                 -H 'Content-Type: application/x-www-form-urlencoded'   \
                                 -H 'Accept: application/json'   \
                                 --data-urlencode "email=${MODIO_EMAIL}"
unset MODIO_EMAIL
