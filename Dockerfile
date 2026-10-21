FROM acrossoffwest/php:8.2.35-fpm-alpine3.23

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
RUN install-php-extensions Imagick/imagick@3.8.1 gd exif

# Other
RUN install-php-extensions zip opcache xmlreader
RUN git clone --depth 1 --branch 6.3.0 --recurse-submodules https://github.com/phpredis/phpredis /tmp/phpredis \
 && install-php-extensions /tmp/phpredis \
 && rm -rf /tmp/phpredis

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

COPY ./supervisor /etc/supervisor

RUN rm -rf /var/cache/apk/*

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
