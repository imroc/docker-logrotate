FROM alpine:latest

RUN set -x \
  && apk add --no-cache logrotate tini tzdata moreutils \
  && rm /etc/logrotate.conf && rm -rf /etc/logrotate.d 

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["tini", "-g", "--"]
CMD ["/entrypoint.sh"]
