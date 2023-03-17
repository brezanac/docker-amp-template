FROM alpine:latest

COPY ./scripts/* /var/backup/scripts/

RUN apk update && \
    apk upgrade && \
    apk add --no-cache mariadb-client && \
    chmod a+x /var/backup/scripts/*

CMD ["/var/backup/scripts/backup"]
