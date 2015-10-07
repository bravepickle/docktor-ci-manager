#!/bin/bash
# Deploy docker master app
# run as root

set -e

# Variables
DOCKER_INSTALL=0

DOCKER_COMPOSE_INSTALL=0
DOCKER_COMPOSE_VERSION=1.4.2
DOCKER_COMPOSE_BIN=/usr/local/bin

CERTS_DIR=/certs

APP_ENV=dev

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run by root user"
    exit 1
fi

echo You are running in $APP_ENV mode

if [[ "$DOCKER_INSTALL" == "1" ]]; then
# Try installing docker if not installed yet
echo Setup Docker
docker --version || (\
    apt-get update > /dev/null && \
    apt-get install wget -y && \
    (wget -qO- https://get.docker.com/ | sh) && \
    usermod -aG docker vagrant)
else
    echo skipping Setup Docker
fi

if [[ "$DOCKER_COMPOSE_INSTALL" == "1" ]]; then
echo Setup Docker Compose
docker-compose --version || (\
    curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > $DOCKER_COMPOSE_BIN/docker-compose && \
    chmod +x $DOCKER_COMPOSE_BIN/docker-compose && \
    docker-compose --version
)
else
    echo skipping Setup Docker Compose
fi

# Install puppet
echo Setup Puppet
puppet --version || (\
    cd /tmp && \
    wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    dpkg -i puppetlabs-release-trusty.deb && \
    apt-get update > /dev/null && \
    apt-get install puppet-common -y && \
    apt-get autoremove -y && \
    puppet --version)

echo Setup Puppet modules
install_module() {
    CURRENT=$1
    echo Trying to install module $CURRENT...

    (puppet module list | grep -q "$CURRENT") && echo module $CURRENT already installed || puppet module install $CURRENT
}

install_module garethr/docker
install_module puppetlabs/stdlib
install_module saz/locales
install_module jfryman/nginx
install_module saz-timezone

echo Setup NGINX
nginx -v || (wget -q http://nginx.org/keys/nginx_signing.key -O- | apt-key add - && \
    echo deb http://nginx.org/packages/ubuntu/ trusty nginx >> /etc/apt/sources.list && \
    echo deb-src http://nginx.org/packages/ubuntu/ trusty nginx >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install nginx && \
    sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
    sed -i "s/.*conf\.d\/\*\.conf;.*/&\n    include \/etc\/nginx\/sites-enabled\/\*;/" /etc/nginx/nginx.conf && \
    rm -Rf /etc/nginx/conf.d/* && \
    mkdir -p /etc/nginx/sites-available/ && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    mkdir -p /etc/nginx/ssl/ && \
    nginx -v)