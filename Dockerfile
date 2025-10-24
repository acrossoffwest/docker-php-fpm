FROM php:8.4-fpm-alpine3.20

MAINTAINER Yurij Karpov <acrossoffwest@gmail.com>

ADD  https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apk update && \
    chmod +x /usr/local/bin/install-php-extensions && \
    apk add --no-cache \
        nginx \
        postgresql-client \
        postgresql-dev \
        git \
        dcron \
        nano \
        bash \
        libzip-dev \
        unzip \
        g++ && \
    mkdir -p /run/nginx

### PHP Extensions

RUN install-php-extensions \
    pdo \
    pdo_pgsql \
    pgsql \
    pdo_mysql \
    mysqli \
    imagick \
    gd \
    exif \
    pcntl \
    swoole \
    zip \
    opcache \
    xmlreader \
    redis

# Composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Configs

COPY ./conf.d/custom.ini /usr/local/etc/php/conf.d/custom_docker_php_fpm.ini

### Cron: Copy schedule
COPY ./cron.d /etc/cron.d

### Supervisor & Additional Libraries

RUN apk --no-cache upgrade && \
    apk add --no-cache \
        supervisor \
        mysql-client \
        freetype \
        libpng \
        freetype-dev \
        libpng-dev \
        jpeg-dev \
        libjpeg \
        libjpeg-turbo-dev \
        wget \
        zlib-dev \
        ttf-freefont \
        fontconfig \
        xvfb \
        libxrender-dev \
        gettext \
        gettext-dev \
        libxml2-dev \
        gnu-libiconv-dev \
        autoconf \
        icu-dev && \
    mkdir -p /var/log/supervisor /etc/supervisor && \
    rm -rf /var/cache/apk/*

COPY ./supervisor /etc/supervisor

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
