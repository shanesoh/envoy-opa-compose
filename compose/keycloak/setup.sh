#!/bin/sh

/tmp/wait-for-it.sh keycloak:8443 -t 60

export PATH=$PATH:/opt/jboss/keycloak/bin

echo '>>> Logging into Keycloak'
kcadm.sh config credentials --server http://keycloak.localhost/auth --realm master --user admin --password password

# This won't create another realm if one with this name exists
echo '>>> Creating applications realm'
kcadm.sh get realms/applications || kcadm.sh create realms -s realm=applications -s displayName=Applications -s enabled=true

# This won't create another user if one with this name exists
echo '>>> Adding a user if necessary'
kcadm.sh create users \
         -s username=user0 \
         -s firstName=User \
         -s lastName=Zero \
         -s email=user0@mail.com \
         -s enabled=true \
         -r applications && \
    kcadm.sh set-password -r applications --username user0 --new-password password --temporary
