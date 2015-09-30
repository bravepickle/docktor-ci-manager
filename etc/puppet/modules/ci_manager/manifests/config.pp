class ci_manager::config inherits ci_manager {

    file { '_docker_compose':
        path => $docker_compose_path,
        ensure => present,
        source => template('project/docker-compose.yml.erb'),
    }



}