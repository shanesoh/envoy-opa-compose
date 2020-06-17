#!/bin/sh

# Logs in to keycloak management portal, and sets KEYCLOAK_TOKEN with the token
#   (Lasts 1 minute by default)

username=$KEYCLOAK_USERNAME
password=$KEYCLOAK_PASSWORD

if [ -z $username ] || [ -z $password ]; then
    echo "KEYCLOAK_USERNAME and KEYCLOAK_PASSWORD must be set as environment variables" 1>&2
    exit 1
fi

realm=master
client_id=admin-cli
grant_type=password
keycloak_url=${KEYCLOAK_URL:-http://keycloak.localhost}

# Gets you a token from client
token=$(curl -X POST -H 'Accept: application/json' -sSk "$keycloak_url/auth/realms/${realm}/protocol/openid-connect/token" -d "client_id=${client_id}&password=${password}&username=${username}&grant_type=${grant_type}" | cut -d '"' -f4)

export KEYCLOAK_TOKEN=$token

# In case applications want to use it directly
echo $token
