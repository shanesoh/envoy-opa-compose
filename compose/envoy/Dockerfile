FROM envoyproxy/envoy:v1.17.1

COPY entrypoint.sh /
RUN chmod 500 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
