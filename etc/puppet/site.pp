package { 'git':
    ensure => present
}

$packages = hiera('extra_packages')
$ci_manager = hiera('ci_manager')
$docker = hiera('docker')

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

#service { 'docker':
#    ensure => running,
#    enable => true,
#}

# DEV mode end

#TODO ensure that registry is running, especially after docker restart
#service { 'images_registry':
#    ensure => running,
#    enable => true,
#
#}

notify {$docker['registry']['lib_dir']:}

class {'ci_manager':
    certs_dir => $docker['registry']['certs_dir'],
    docker_registry_lib => $docker['registry']['lib_dir'],
    docker_registry_image_name => $docker['registry']['name'],
    docker_registry_host => $docker['registry']['host'],
    docker_registry_port => $docker['registry']['port'],
    docker_registry_user => $docker['registry']['user'],
    docker_registry_password => $docker['registry']['password'],
    docker_registry_email => $docker['registry']['email'],
}

#class {ci_manager::docker:
#}

class {'locales':
    default_locale  => 'en_US.UTF-8',
    locales => ['en_US.UTF-8 UTF-8', 'ru_UA.UTF-8 UTF-8'],
}
