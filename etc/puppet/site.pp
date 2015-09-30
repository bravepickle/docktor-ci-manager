package { 'git':
    ensure => present
}

$packages = hiera('extra_packages')
$ci_manager = hiera('ci_manager')

package { $packages:
    ensure => present,
}

host { 'ci_manager':
    name => $ci_manager['host'],
    ip   => $ci_manager['ip'],
    comment => 'Managed by Puppet',
}


# ONLY FOR DEV!
#file_line { 'docker_options':
#	ensure => present,
#	line   => hiera('docker_opts'),
#	path   => '/etc/default/docker',
#    match  => '^DOCKER_OPTS=',
#    notify => Service['docker'],
#}

service { 'docker':
    ensure => running,
    enable => true,
}

# DEV mode end

#TODO ensure that registry is running, especially after docker restart
#service { 'images_registry':
#    ensure => running,
#    enable => true,
#
#}
#node default {
#	include project

#    include '::ci_manager'
#    include '::ci_manager'

	class {'basic':

	}
#}
