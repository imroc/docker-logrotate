FROM alpine:latest

ARG LOGROTATE_VERSION=3.21.0-r1

RUN set -x && \
  apk add --no-cache logrotate=${LOGROTATE_VERSION} tini tzdata moreutils && \
  rm /etc/logrotate.conf && rm -rf /etc/logrotate.d 

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh"]
