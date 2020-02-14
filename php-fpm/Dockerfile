FROM brezanac/apt-image:18.04

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

# Custom user and group ID
ARG USER_ID
ARG GROUP_ID
RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    userdel -f www-data \
    && if getent group www-data ; then groupdel www-data; fi \
    && groupadd -g ${GROUP_ID} www-data \
    && useradd -l -u ${USER_ID} -g www-data www-data \
;fi

# Per-image commands
ARG PHP_FPM_VERSION
ENV PHP_VER ${PHP_FPM_VERSION}
ARG PHP_FPM_SYSTEM_PACKAGES
ENV COMPOSER_HOME /.composer

COPY xdebug-bin /usr/bin/xdebug
COPY fpm-bin /usr/bin/php-fpm

RUN apt-get update \
    && get-gpg-key 0x14AA40EC0831756756D7F66C4F4EA0AAE5267A6C | apt-key add \
    && printf "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main\n" \
>/etc/apt/sources.list.d/ondrej.list \
    && apt-get update \
    && apt-get -y install --no-install-recommends --no-install-suggests \
        php${PHP_VER}-fpm php${PHP_VER}-cli ${PHP_FPM_SYSTEM_PACKAGES} \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/lib/x86_64-linux-gnu/perl /usr/share/perl /usr/lib/x86_64-linux-gnu/libperl.* \
    && rm -rf /usr/share/{man,doc} \
    \
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

ARG PHP_FPM_BLACKFIRE_SERVER
RUN if [ ! -z "$PHP_FPM_BLACKFIRE_SERVER" ]; then \
    curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s \
        https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${PHP_VER} \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://${PHP_FPM_BLACKFIRE_SERVER}:8707\n" > \
        /etc/php/${PHP_VER}/cli/conf.d/blackfire.ini \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://${PHP_FPM_BLACKFIRE_SERVER}:8707\n" > \
        /etc/php/${PHP_VER}/fpm/conf.d/blackfire.ini \
    && rm -f /tmp/* \
;fi

WORKDIR /var/www
USER www-data

EXPOSE 9000

CMD /usr/bin/php-fpm