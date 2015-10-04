#!/bin/bash
# Deploy docker master app
# run as root

set -e

# Variables
DOCKER_INSTALL=0

DOCKER_COMPOSE_INSTALL=0
DOCKER_COMPOSE_VERSION=1.4.2
DOCKER_COMPOSE_BIN=/usr/local/bin

PUPPET_DOCKER=garethr/docker
PUPPET_STDLIB=puppetlabs/stdlib
PUPPET_LOCALE=saz/locales
PUPPET_NGINX=jfryman/nginx

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
(puppet --version | grep -q "3.4.3") && apt-get remove -y puppet || echo skipping... # remove outdated Puppet version and configs

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

    (puppet module list | grep -q "$CURRENT") && puppet module install $CURRENT || echo module $CURRENT already installed
}

install_module $PUPPET_STDLIB
install_module $PUPPET_DOCKER
install_module $PUPPET_LOCALE
install_module $PUPPET_NGINX
