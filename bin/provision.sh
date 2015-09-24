#!/bin/sh
# Deploy docker master app
# run as root

# Variables
DOCKER_REGISTRY_IMAGE_NAME=images_registry
DOCKER_REGISTRY_PORT=7111

# Try installing docker if not installed yet
echo Setup Docker
docker --version || (\
    #apt-get update && \
    apt-get install wget -y && \
    (wget -qO- https://get.docker.com/ | sh) && \
    usermod -aG docker vagrant)

# Pull Docker images
echo Setup Docker registry
docker inspect registry:2 > /dev/null || \
	(docker pull registry:2 && docker run -d -p ${DOCKER_REGISTRY_PORT}:5000 --name $DOCKER_REGISTRY_IMAGE_NAME registry:2)

# Install puppet
echo Setup Puppet
puppet --version || (\
    cd /tmp && \
    wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && \
    dpkg -i puppetlabs-release-trusty.deb && \
    apt-get update > /dev/null && \
    apt-get install puppet-common -y && \
    puppet --version)
