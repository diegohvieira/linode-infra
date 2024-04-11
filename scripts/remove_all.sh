#!/bin/sh

PG_VERSION="16"
PHP_VERSION="8.2"

if dpkg -s nginx >/dev/null 2>&1; then
    sudo apt purge -y nginx
fi

if dpkg -s php${PHP_VERSION}-common >/dev/null 2>&1; then
    sudo apt purge -y php${PHP_VERSION}-common \
                   php${PHP_VERSION}-cli \
                   php${PHP_VERSION}-fpm \
                   php${PHP_VERSION}-bcmath \
                   php${PHP_VERSION}-curl \
                   php${PHP_VERSION}-mbstring \
                   php${PHP_VERSION}-pgsql \
                   php${PHP_VERSION}-xml \
                   php${PHP_VERSION}-zip \
                   php${PHP_VERSION}-gd
fi

if dpkg -s openjdk-8-jdk >/dev/null 2>&1; then
    sudo apt purge -y openjdk-8-jdk
fi

if dpkg -s redis >/dev/null 2>&1; then
    sudo apt purge -y redis
fi

if dpkg -s postgresql-${PG_VERSION} >/dev/null 2>&1; then
    sudo apt purge -y postgresql-${PG_VERSION} \
                   postgresql-contrib-${PG_VERSION}
fi

sudo apt autoremove -y
sudo apt-get autoclean