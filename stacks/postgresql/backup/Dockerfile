ARG POSTGRES_VERSION=14
FROM postgres:${POSTGRES_VERSION}-alpine

RUN apk add --no-cache bash curl gpg gpg-agent rclone \
  && mkdir -p /root/.config/rclone \
  && touch /root/.config/rclone/rclone.conf

COPY backup.sh /usr/local/bin/

CMD ["backup.sh"]