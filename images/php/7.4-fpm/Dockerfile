# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/compose/compose-file/#target

ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.14
ARG COMPOSER_VERSION=2.4
ARG PHP_EXTENSION_INSTALLER_VERSION=latest

########################################################################################

FROM composer:${COMPOSER_VERSION} AS composer

########################################################################################

FROM mlocati/php-extension-installer:${PHP_EXTENSION_INSTALLER_VERSION} AS php_extension_installer

########################################################################################

FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS sylius_php

WORKDIR /srv/sylius

# persistent / runtime deps
RUN apk add --no-cache \
        acl \
        file \
        gettext \
        unzip \
        git \
        icu-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libzip-dev \
        libxml2-dev \
        bash \
        build-base \
        autoconf \
        bison \
        re2c \
    ;

COPY --from=php_extension_installer /usr/bin/install-php-extensions /usr/local/bin/

# default PHP image extensions
# ctype curl date dom fileinfo filter ftp hash iconv json libxml mbstring mysqlnd openssl pcre PDO pdo_sqlite Phar
# posix readline Reflection session SimpleXML sodium SPL sqlite3 standard tokenizer xml xmlreader xmlwriter zlib
RUN install-php-extensions apcu exif gd intl pdo_mysql opcache zip

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY etc/php.ini        $PHP_INI_DIR/php.ini
COPY etc/opcache.ini    $PHP_INI_DIR/conf.d/opcache.ini

VOLUME /srv/sylius/var
VOLUME /srv/sylius/public/media

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]