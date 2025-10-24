FROM php:8.4-fpm-alpine3.20

MAINTAINER Yurij Karpov <acrossoffwest@gmail.com>

RUN apk update

ADD  https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

### Web server

# Server
RUN apk add nginx
RUN mkdir -p /run/nginx

# Database
RUN apk add postgresql-client postgresql-dev

# Other
RUN apk add git dcron nano bash libzip-dev unzip g++

### PHP

# Database
RUN install-php-extensions pdo pdo_pgsql pgsql pdo_mysql mysqli

# Image
RUN install-php-extensions imagick gd exif

# swoole
RUN install-php-extensions pcntl swoole

# Other
RUN install-php-extensions zip opcache xmlreader redis

# Composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php

# Configs

COPY ./conf.d/custom.ini /usr/local/etc/php/conf.d/custom_docker_php_fpm.ini

### Cron: Copy schedule
COPY ./cron.d /etc/cron.d

### Supervisor
# supervisor installation &&
# create directory for child images to store configuration in
RUN apk add supervisor && \
  mkdir -p /var/log/supervisor && \
  mkdir -p /etc/supervisor

# install mysql and image libraries
RUN apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache \
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
            g++ \
            git \
            bash \
            icu-dev

COPY ./supervisor /etc/supervisor

RUN rm -rf /var/cache/apk/*

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
