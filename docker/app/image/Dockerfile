FROM php:7.4-alpine

###> Environment ###
ENV COMPOSER_HOME="/tmp/composer"

ENV PERMANENT_DEPS \
    postgresql-dev \
    gettext-dev \
    icu-dev \
    libintl
###< Environment ###

###> Dependencies ###
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN set -xe \
    && apk add --no-cache ${PERMANENT_DEPS} \
    && apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv \
    && docker-php-ext-configure opcache \
    && docker-php-ext-configure pdo_pgsql \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-install -j$(nproc) \
        pdo_pgsql \
        sockets \
        opcache \
        intl \
    && rm -rf /app /home/user ${COMPOSER_HOME} /var/cache/apk/* \
    && mkdir /app /home/user ${COMPOSER_HOME} \
    && ln -s /usr/bin/composer /usr/bin/c
###< Dependencies ###

###> Configuration ###
COPY ./docker/app/config/php/php.ini /usr/local/etc/php/php.ini
COPY ./docker/app/config/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY ./docker/app/shell/entrypoint.sh /entrypoint.sh
###< Configuration ###

WORKDIR /app

COPY ./app/ /app/
COPY ./app/composer.* /app/
RUN ./vendor/bin/rr get-binary --location /usr/local/bin

RUN set -xe \
    && chmod +x /entrypoint.sh \
    && composer --version \
    && php -v \
    && php -m \
    && rr -h \
    && composer dump-autoload

EXPOSE 80
EXPOSE 443
#VOLUME ["/app"]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["rr", "serve", "-v", "-d"]
