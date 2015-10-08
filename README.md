# docktor-ci-manager
Server for management CI/CD management project, puppet management and servers' status checks


## TODO
- split docker class to multiple subclasses
- clean code
- add comments
- remove unused code


## Default web interfaces:
- http://docktor-ci-manager/ - entry point for all other web UI
- http://docktor-ci-manager:9000/ - dockerUI interface to manage images and containers
- http://docktor-ci-manager:9001/ - SonarQube
- http://docktor-ci-manager:5000/ - Docker registry
- http://docktor-ci-manager:8153/ - Dockerized GO CD Server


See https://github.com/docker/docker/issues/9015 for API usage of Registry V2

## Manager contain
- Docker
- Puppet
- DockerUI
- Docker Registry
- CI Server: GO CD Server + Agent
- add volumes for GO CD Agent 
- restructure puppet module, use directly in it values from hiera config, split docker.pp to multiple files
- extract more variables to hiera configs remove unused
- configure go cd reverse proxy [done]
- fix proxy for docker ui - persistent connection closed for ajax requests
- use Supervisor and Docker Compose for handling docker containers and other apps
- improve base vagrant box: remove cache, install additional apps like vim, htop etc.
- replace packer-vmware-iso user with another one
- think of removal of docker installation in Puppet, because it should already exist on virtual machine, server per se. But do not delete setup from Puppet because it has some additional features, such as cleaning base configs
- add server performance tools (Nagios, Zabbix or similar)
- consider https://hub.docker.com/r/francescou/docker-compose-ui/
- consider https://forge.puppetlabs.com/garystafford/docker_compose
- switch packer vmware tools patches to main repo from my fork. Bugs are fixed