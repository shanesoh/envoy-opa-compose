#!/bin/sh

# Sets up the applications realm if it does not exist, then
# Sets up a client if it does not exist, then
# Writes client's client_secret to stdout

keycloak_url=${KEYCLOAK_URL:-http://keycloak.localhost}
export KEYCLOAK_USERNAME=${KEYCLOAK_USERNAME:-admin}
export KEYCLOAK_PASSWORD=${KEYCLOAK_PASSWORD:-password}

client_roles="$@"
client_name="$CLIENT_NAME"

if [ -z "$client_name" ]; then
    echo ">>> CLIENT_NAME must be set!" 1>&2
    exit 1
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Wait up to 30s until applications realm is created
for i in $(seq 30); do
    echo "Wait for applications realm to be created... $i" 1>&2

    # Get the token (default: expires in 1 minute)
    token=$("${script_dir}/get-token.sh")

    return_code=$(curl -X GET -o /dev/null -H "Content-Type: application/json" \
                       -H "Authorization: Bearer $token" -w '%{http_code}' \
                       -sSk "$keycloak_url/auth/admin/realms/applications")
    [ "$return_code" -eq "200" ] && break
    sleep 1;
done

# Quit if we couldn't find the applications realm after timeout
[ "$return_code" -ne "200" ] && exit 1

# Create get id of client first
client_id=$(curl -X GET -H "Content-Type: application/json" \
                 -H "Authorization: Bearer $token" \
                 -sSk "$keycloak_url/auth/admin/realms/applications/clients" \
                | jq -r ".[] | select(.clientId == \"${client_name}\") | .id")

# Get client's id
if [ -z "$client_id" ]; then
    # Create a client
    echo "Creating client $client_name" 1>&2
    curl -X POST -H "Content-Type: application/json" \
         -H "Authorization: Bearer $token" \
         -sSk "$keycloak_url/auth/admin/realms/applications/clients" \
         --data-binary @- >/dev/null <<EOF
{
  "clientId": "${client_name}",
  "name": "${client_name}",
  "enabled": true,
  "fullScopeAllowed": "false",
  "baseUrl": "https://${client_name}.localhost",
  "redirectUris": ["https://${client_name}.localhost/*"],
  "defaultClientScopes": [
    "role_list",
    "profile",
    "roles",
    "email"
  ],
  "optionalClientScopes": [
    "address",
    "phone"
  ],
  "directAccessGrantsEnabled": true
}
EOF

    # Get the id again
    client_id=$(curl -X GET -H "Content-Type: application/json" \
                     -H "Authorization: Bearer $token" \
                     -sSk "$keycloak_url/auth/admin/realms/applications/clients" \
                    | jq -r ".[] | select(.clientId == \"${client_name}\") | .id")

    echo "Adding client scope for client" 1>&2
    curl -H "Content-Type: application/json" \
         -H "Authorization: Bearer $token" \
         -sSk "$keycloak_url/auth/admin/realms/applications/client-scopes" \
         --data-binary @- >/dev/null <<EOF
{
  "name": "$client_name",
  "protocol": "openid-connect",
  "protocolMappers": [
    {
      "name": "audience-mapper",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-audience-mapper",
      "consentRequired": false,
      "config": {
        "included.client.audience": "$client_name",
        "id.token.claim": "false",
        "access.token.claim": "true"
      }
    }
  ]
}
EOF

    client_scope_id=$(curl -X GET -H "Content-Type: application/json" \
                           -H "Authorization: Bearer $token" \
                           -sSk "$keycloak_url/auth/admin/realms/applications/client-scopes" \
                          | jq -r ".[] | select(.name == \"${client_name}\") | .id")


    echo "Adding client scope to client" 1>&2
    curl -H "Content-Type: application/json" \
         -H "Authorization: Bearer $token" \
         -X PUT \
         -sSk "$keycloak_url/auth/admin/realms/applications/clients/$client_id/optional-client-scopes/$client_scope_id" \
         --data-binary @- >/dev/null <<EOF
{
  "clientScopeId": "$client_scope_id",
  "id": "$client_id",
  "realm": "applications"
}
EOF

    # Add any requested client roles
    for role in $client_roles; do
        echo "Adding role $role to client" 1>&2
        curl -H "Content-Type: application/json" \
             -H "Authorization: Bearer $token" \
             -sSk "$keycloak_url/auth/admin/realms/applications/clients/$client_id/roles" \
             --data-binary "{\"name\": \"$role\"}"
    done
fi

# Get client's secret
curl -X GET -H "Content-Type: application/json" \
     -H "Authorization: Bearer $token" \
     -sSk "$keycloak_url/auth/admin/realms/applications/clients/$client_id/client-secret" \
    | jq -r '.value'
