FROM ghcr.io/hdoc/hdoc:1.2.2

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
