# == Class: ci_manager
#
# Full description of class ci_manager here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { ci_manager:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class ci_manager (
      $docker_registry_host = 'docktor-ci-manager',
      $docker_registry_image_name = 'images_registry',
      $docker_registry_host = 'docktor-ci-manager',
      $docker_registry_port = '5000',
      $docker_registry_user = 'user',
      $docker_registry_password = 'pa$$word',
      $docker_registry_email = 'user@example.com',
      $certs_dir = '/certs',
      $bin_dir = '/usr/local/bin',
      $docker_certs_crt_dir = "/etc/docker/certs.d",
      $docker_registry_lib = "/registry_lib",
      $docker_socket = '/var/run/docker.sock',
) {
    class { ci_manager::docker:
      docker_registry_image_name => $docker_registry_image_name,
      docker_registry_host => $docker_registry_host,
      docker_registry_port => $docker_registry_port,
      docker_registry_user => $docker_registry_user,
      docker_registry_password => $docker_registry_password,
      docker_registry_email => $docker_registry_email,
      certs_dir => $certs_dir,
      bin_dir => $bin_dir,
      docker_certs_crt_dir => $docker_certs_crt_dir,
      docker_registry_lib => $docker_registry_lib,
      docker_socket => $docker_socket,
    }

    class { ci_manager::go_cd:

    }

    class {  ci_manager::nginx: }
}
