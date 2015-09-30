#!/bin/bash
# Deploy docker master app
# run as root

set -e

# Variables
DOCKER_REGISTRY_HOSTNAME=docktor-ci-manager
DOCKER_REGISTRY_IMAGE_NAME=images_registry
DOCKER_REGISTRY_PORT=7111
DOCKER_REGISTRY_CA_DIR=/etc/docker/certs.d/${DOCKER_REGISTRY_HOSTNAME}:${DOCKER_REGISTRY_PORT}

DOCKER_COMPOSE_VERSION=1.4.2
DOCKER_COMPOSE_BIN=/usr/local/bin

PUPPET_DOCKER=garethr/docker
PUPPET_STDLIB=puppetlabs/stdlib
CERTS_DIR=/certs

APP_ENV=dev

echo You are running in $APP_ENV mode

# Try installing docker if not installed yet
echo Setup Docker
docker --version || (\
    apt-get update > /dev/null && \
    apt-get install wget -y && \
    (wget -qO- https://get.docker.com/ | sh) && \
    usermod -aG docker vagrant)

if [[ "$APP_ENV" == "dev" ]]; then
# TODO non-interactive mode for certs gen
    echo Generate self-signed CA certificates
    
    test -f $CERTS_DIR/domain.crt || (mkdir -p certs && openssl req \
      -newkey rsa:4096 -nodes -sha256 -keyout $CERTS_DIR/domain.key \
      -x509 -days 365 -out $CERTS_DIR/domain.crt && \
      mkdir -p $DOCKER_REGISTRY_CA_DIR && \
      cp certs/domain.crt $DOCKER_REGISTRY_CA_DIR/ca.crt && \
      service docker stop && service docker start && \
      docker start $DOCKER_REGISTRY_IMAGE_NAME
      )

else
    echo Skipping creation certificates
#    /etc/docker/certs.d/myregistrydomain.com:5000/ca.crt
fi


# Pull Docker images
#echo Setup Docker registry
#docker inspect registry:2 > /dev/null || \
#    (docker pull registry:2 && \
#        docker run -d -p ${DOCKER_REGISTRY_PORT}:5000  --restart=always \
#        --name $DOCKER_REGISTRY_IMAGE_NAME registry:2 \
#        -e REGISTRY_HTTP_TLS_CERTIFICATE=$CERTS_DIR/domain.crt \
#        -e REGISTRY_HTTP_TLS_KEY=$CERTS_DIR/domain.key \
#    )

echo Setup Docker Compose
docker-compose --version || (\
    curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > $DOCKER_COMPOSE_BIN/docker-compose && \
    chmod +x $DOCKER_COMPOSE_BIN/docker-compose && \
    docker-compose --version
)

# Install puppet
echo Setup Puppet
puppet --version || (\
    cd /tmp && \
    wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    dpkg -i puppetlabs-release-trusty.deb && \
    apt-get update > /dev/null && \
    apt-get install puppet-common -y && \
    puppet --version)

echo Setup Puppet modules
(puppet module list | grep $PUPPET_STDLIB | wc -l) || puppet module install $PUPPET_STDLIB
(puppet module list | grep $PUPPET_DOCKER | wc -l) || puppet module install $PUPPET_DOCKER
