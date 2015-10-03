# docktor-ci-manager
Server for management CI/CD management project, puppet management and servers' status checks


## TODO
- split docker class to multiple subclasses
- clean code
- add comments
- remove unused code


## Default web interfaces:
- http://docktor-ci-manager:9000/ - dockerUI interface to manage images and containers
- http://docktor-ci-manager:5000/ - Docker registry
- http://docktor-ci-manager:8153/ - Dockerized GO CD Server
<!-- - http://docktor-ci-manager:8160/ - Dockerized GO CD Agent -->

See https://github.com/docker/docker/issues/9015 for API usage of Registry V2

## Manager contain
- Docker
- Puppet
- DockerUI
- Docker Registry
- CI Server: GO CD Server + Agent
- add volumes for GO CD Agent 
