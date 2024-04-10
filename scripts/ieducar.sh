#!/bin/sh

# Tested on Ubuntu 22.04

# Colors scheme
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Variables
DB_PASS=${1:-Y4T3C13duc4rD4t4b4s3}
DB_NAME="ieducar"
DB_USER="ieducar"
INSTALL_DIR="/var/www/ieducar"
PG_VERSION="16"
PHP_VERSION="8.2"
DEFAULT_TZ="America/Maceio"

# Check if the script is running as root
if [ "$EUID" -ne 0 ]
  then echo -e "${YELLOW}Please run as root${NC}"
  exit
fi

# Fix locale
echo "Fixing locale"
locale-gen pt_BR.UTF-8

# Add the dependency repositories and update the package list
add-apt-repository ppa:openjdk-r/ppa -y && \
add-apt-repository ppa:ondrej/php -y && \
apt update && \
apt upgrade -y

# Install the dependencies
echo "Installing dependencies"
sudo DEBIAN_FRONTEND=noninteractive apt install -y redis \
               gnupg2 \
               wget \
               openssl \
               unzip \
               git

# Install Nginx
echo "Installing Nginx"
apt install -y nginx

# Install Java
echo "Installing Java"
apt install -y openjdk-8-jdk

               
# Install PHP and its extensions
echo "Installing PHP $PHP_VERSION and extensions"
apt install -y php${PHP_VERSION}-common \
               php${PHP_VERSION}-cli \
               php${PHP_VERSION}-fpm \
               php${PHP_VERSION}-bcmath \
               php${PHP_VERSION}-curl \
               php${PHP_VERSION}-mbstring \
               php${PHP_VERSION}-pgsql \
               php${PHP_VERSION}-xml \
               php${PHP_VERSION}-zip \
               php${PHP_VERSION}-gd

# Install PostgreSQL 43er!NXaVYHWJj8
echo "Installing PostgreSQL $PG_VERSION"
wget -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add - && \
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
sudo curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
apt update && \
apt-get -y install pgdg-keyring

# Install PostgreSQL
apt install -y postgresql-${PG_VERSION} \
               postgresql-contrib-${PG_VERSION} \
               postgresql-common

# Start and Enable PostgreSQL service
echo "Starting and enabling PostgreSQL $PG_VERSION service"
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configure PostgreSQL
echo "Configuring PostgreSQL $PG_VERSION"

## IF Create a new cluster
#sudo pg_dropcluster --stop $PG_VERSION main && \
#sudo pg_createcluster -u postgres -g postgres "$PG_VERSION" -e UTF8 --locale="pt_BR.UTF-8" --lc-collate="pt_BR.UTF-8" main && \
# sudo systemctl restart postgresql
# sudo systemctl start postgresql@16-main.service
# sudo systemctl enable postgresql@16-main.service

sed -i "s/ident/md5/g" /var/lib/pgsql/${PG_VERSION}/data/pg_hba.conf && \
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/${PG_VERSION}/data/postgresql.conf && \
sudo systemctl restart postgresql

# Create the database and user
echo "Creating database and user"
sudo -u postgres psql -c "CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASS';"
sudo -u postgres psql  -c "CREATE DATABASE $DB_NAME OWNER $DB_USER"
sudo -u postgres psql  -c "ALTER USER $DB_USER WITH SUPERUSER;"

# Confirure Composer
echo "Configuring Composer"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php --install-dir=/usr/bin --filename=composer
php -r "unlink('composer-setup.php');"
export COMPOSER_ALLOW_SUPERUSER=1

# Clone repo and configure i-Educar
echo "Installing i-Educar"
git clone https://github.com/portabilis/i-educar.git $INSTALL_DIR
cd ${INSTALL_DIR}
cp .env.example .env

# Configure the .env file
sed -i "s/DB_PASSWORD=ieducar/DB_PASSWORD=$DB_PASS/" .env
sed -i "s|APP_TIMEZONE=America/Sao_Paulo|APP_TIMEZONE=$DEFAULT_TZ|" .env

# Configure Nginx
cp $INSTALL_DIR/docker/nginx/default.conf /etc/nginx/conf.d/default.conf
cp $INSTALL_DIR/docker/nginx/upstream.conf /etc/nginx/conf.d/upstream.conf
sed -i 's/php:9000/unix:\/run\/php\/php-fpm.sock/g' /etc/nginx/conf.d/upstream.conf
rm /etc/nginx/sites-enabled/default
nginx -s reload

# Install i-Educar
cd ${INSTALL_DIR} && \
compose new-install && \
php artisan db:seed --class=DemoSeeder
