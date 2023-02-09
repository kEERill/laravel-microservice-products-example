ARG PHP_VERSION=8.1
ARG COMPOSER_VERSION=2.4.1

###########################################
# PHP dependencies
###########################################

FROM composer:${COMPOSER_VERSION} AS vendor

WORKDIR /var/www/html

COPY ./src/composer* ./

RUN composer install \
  --no-dev \
  --no-interaction \
  --prefer-dist \
  --ignore-platform-reqs \
  --optimize-autoloader \
  --apcu-autoloader \
  --ansi \
  --no-scripts \
  --audit

###########################################
# Application
###########################################

FROM php:${PHP_VERSION}-cli-bullseye

# Prepend pipfail
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN set -ex \
    && RUN_DEPS=" \
        iproute2 \
        unzip \
        libzip4 \
        libonig5 \
        libpng16-16 \
        libicu-dev \
    " \
    && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
    && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && BUILD_DEPS=" \
        libpq-dev \
        libzip-dev \
        libpng-dev \
        libonig-dev \
        libicu-dev \
    " \
    && BUILD_MODULES=" \
        bcmath \
        pdo_mysql \
        zip \
        mbstring \
        exif \
        intl \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
    && docker-php-ext-install $BUILD_MODULES \
    \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/* \
    && php -m

# Install PHP extension gd
RUN apt-get update && apt-get install -y \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd

# Install Redis
RUN pecl install -o -f redis \
        && rm -rf /tmp/pear \
        && docker-php-ext-enable redis

# Install swoole
RUN pecl install swoole \
    && docker-php-ext-enable swoole

# Install PostgresQL
RUN apt-get install -y --no-install-recommends libpq-dev &&  \
    docker-php-ext-install pdo pdo_pgsql pgsql

# Install Opcache
RUN docker-php-ext-install opcache

# Install kafka
#RUN apt-get install -y gnupg wget software-properties-common \
#    && wget -qO - https://packages.confluent.io/deb/7.3/archive.key | apt-key add - \
##    && add-apt-repository "deb https://packages.confluent.io/clients/deb $(lsb_release -cs) main"
#RUN apt-get install -y libc6:amd64
#RUN echo 'deb http://deb.debian.org/debian/ bookworm main contrib non-free' >> /etc/apt/sources.list

RUN apt-get update && apt-get install -yqq --no-install-recommends librdkafka-dev \
      && pecl -q install -o -f rdkafka-5.0.2 \
      && docker-php-ext-enable rdkafka

RUN docker-php-source delete

# Install supervisor
RUN apt-get install -y --no-install-recommends supervisor

WORKDIR /var/www/html

COPY src .
COPY --from=vendor /var/www/html/vendor vendor

RUN cp .env.example .env

ENV APP_ENV="production"
ENV APP_KEY="base64:m7Ir3ydEyZD9BeECiCejxntyaJvZ6b61hJXjutXyOTM="
ENV APP_DEBUG=false

COPY .docker/start-container /usr/local/bin/start-container
COPY .docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# PHP Configuration
COPY .docker/php/php.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-app.ini
COPY .docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN chmod +x /usr/local/bin/start-container

EXPOSE 8080

ENTRYPOINT ["start-container"]
