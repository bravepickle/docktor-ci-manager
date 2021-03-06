class ci_manager::nginx {

    class { ::nginx:
        service_ensure => running,
    }

    file { '_nginx_vhost':
        path   => '/etc/nginx/sites-enabled/default-vhost.conf',
        ensure => present,
        content => template('ci_manager/nginx-vhost.conf.erb'),
        notify => Service['nginx'],
    }
}
