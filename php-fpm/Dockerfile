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
ARG PHP_FPM_VERSION
ENV PHP_VER ${PHP_FPM_VERSION}
ARG PHP_FPM_SYSTEM_PACKAGES
ENV COMPOSER_HOME /.composer

COPY xdebug-bin /usr/bin/xdebug
COPY fpm-bin /usr/bin/php-fpm

RUN apt-get update \
    && apt-get -y install curl software-properties-common tzdata \
    && yes | add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests php${PHP_VER}-fpm php${PHP_VER}-cli ${PHP_FPM_SYSTEM_PACKAGES} \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/lib/x86_64-linux-gnu/perl /usr/share/perl /usr/lib/x86_64-linux-gnu/libperl.* \
    && rm -rf /usr/share/{man,doc} \
    && install -d -m 0755 -o www-data -g www-data /var/run/php-fpm \
    && install -d -m 0755 -o www-data -g www-data /var/lib/php/sessions \
    && chmod +x /usr/bin/xdebug \
    && chmod +x /usr/bin/php-fpm \
    && ln -sf /usr/sbin/php-fpm${PHP_VER} /usr/sbin/php-fpm

ARG PHP_FPM_PEAR_PACKAGES
RUN if [ ! -z "$PHP_FPM_PEAR_PACKAGES" ]; then \
    printf "\n" | pear install -o -f ${PHP_FPM_PEAR_PACKAGES} \
;fi

ARG PHP_FPM_PECL_PACKAGES
RUN if [ ! -z "$PHP_FPM_PECL_PACKAGES" ]; then \
    pecl channel-update pecl.php.net \
    && printf "\n" | pecl install -o -f ${PHP_FPM_PECL_PACKAGES} \
;fi

ARG PHP_FPM_COMPOSER_INSTALL=0
RUN if [ $PHP_FPM_COMPOSER_INSTALL -ne 0 ]; then \
    install -d -m 0755 -o www-data -g www-data /.composer \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin \
        --filename=composer \
;fi

WORKDIR /var/www
USER www-data

EXPOSE 9000

CMD /usr/bin/php-fpm
