FROM ubuntu:20.04

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Setting the default timezone.
ARG DEFAULT_TIMEZONE=UTC
ENV TZ=${DEFAULT_TIMEZONE}

# Custom user and group ID.
ARG PUID=1000
ARG PGID=1000

# Assigning host user and group ID to the running container user
# This prevents permission and overnership issues inside the container.
RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

# Image provisioning.
ARG APACHE_SYSTEM_PACKAGES

RUN apt-get update \
    && apt-get -y install curl software-properties-common tzdata \
    && yes | add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests apache2 ${APACHE_SYSTEM_PACKAGES} \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/share/{man,doc} \
    && rm -f conf-enabled/serve-cgi-bin.conf mods-enabled/autoindex.conf mods-enabled/autoindex.load \
    && install -d -m 0755 -o www-data -g www-data /var/run/apache2 \
    && chmod 755 /var/log/apache2 \
    && chown -R www-data:www-data /var/log/apache2 \
    && ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stdout /var/log/apache2/vhost-access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log \
    && ln -sf /dev/stderr /var/log/apache2/vhost-error.log

ARG APACHE_MODULES_DISABLE
RUN if [ ! -z "$APACHE_MODULES_DISABLED" ]; then \
    a2dismod $APACHE_MODULES_DISABLED \
;fi

ARG APACHE_MODULES_ENABLED
RUN if [ ! -z "$APACHE_MODULES_ENABLED" ]; then \
    a2enmod $APACHE_MODULES_ENABLED \
;fi

WORKDIR /var/www
USER www-data

EXPOSE 8080

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
