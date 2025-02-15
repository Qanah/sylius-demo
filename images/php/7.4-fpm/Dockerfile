# Set the different ARGs for versions
ARG PHP_VERSION=7.4
ARG ALPINE_VERSION=3.14
ARG COMPOSER_VERSION=2.4
ARG PHP_EXTENSION_INSTALLER_VERSION=latest

########################################################################################

# Composer image stage
FROM composer:${COMPOSER_VERSION} AS composer

########################################################################################

# PHP Extension Installer image stage
FROM mlocati/php-extension-installer:${PHP_EXTENSION_INSTALLER_VERSION} AS php_extension_installer

########################################################################################

# Sylius PHP image stage
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS sylius_php

# Set working directory for the Sylius app
WORKDIR /srv/sylius

# Install persistent / runtime dependencies
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
    ;

# Copy PHP extension installer from previous image
COPY --from=php_extension_installer /usr/bin/install-php-extensions /usr/local/bin/

# Install default PHP extensions using install-php-extensions
RUN install-php-extensions apcu exif gd intl pdo_mysql opcache zip

# Copy Composer from the previous image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Copy custom php.ini and opcache.ini configurations
COPY etc/php.ini $PHP_INI_DIR/php.ini
COPY etc/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini

# Define volumes for persistent application data
VOLUME /srv/sylius/var
VOLUME /srv/sylius/public/media

# Copy custom entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/docker-entrypoint

# Set the entrypoint and command for the container
ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
