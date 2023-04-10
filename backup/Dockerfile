FROM alpine:latest

# Setting the default timezone (tzdata required).
ARG DEFAULT_TIMEZONE=UTC
ENV TZ=${DEFAULT_TIMEZONE}

COPY ./scripts/* /var/backup/scripts/

RUN apk update && \
    apk upgrade && \
    apk add --no-cache mariadb-client tzdata && \
    chmod a+x /var/backup/scripts/*

CMD ["/var/backup/scripts/backup"]
