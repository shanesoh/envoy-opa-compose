#!/bin/sh

command -v wait-for-it.sh || curl -o /tmp/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && chmod +x /tmp/wait-for-it.sh

/setup.sh &

exec /opt/jboss/tools/docker-entrypoint.sh -Dkeycloak.profile=preview
