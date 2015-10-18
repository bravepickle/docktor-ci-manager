class ci_manager::go_cd_server::config (
    $config
) {
    $dir = $config['data_dir']

    exec { "go_server_lib":
        command => "mkdir -p $dir/server/lib",
        path => '/bin',
        creates => "$dir/server/lib"
    }

    file { "go_server_lib":
        path => "$dir/server/lib",
        ensure => directory,
        owner => 'docker',
        group => 'docker',
        require => Exec['go_server_lib'],
    }

    exec { "go_server_log":
        command => "mkdir -p $dir/server/log",
        path => '/bin',
        creates => "$dir/server/log"
    }

    file {"go_server_log":
        path => "$dir/server/log",
        ensure => directory,
        owner => 'docker',
        group => 'docker',
        require => Exec['go_server_log'],
    }

    exec { "go_server_etc":
        command => "mkdir -p $dir/server/etc",
        path => '/bin',
        creates => "$dir/server/etc"
    }

    file { "go_server_etc":
        path => "$dir/server/etc",
        ensure => directory,
        owner => 'docker',
        group => 'docker',
        require => Exec['go_server_etc'],
    }

    exec { "go_server_addons":
        command => "mkdir -p $dir/server/addons",
        path => '/bin',
        creates => "$dir/server/addons"
    }

    file { "go_server_addons":
        path => "$dir/server/addons",
        ensure => directory,
        owner => 'docker',
        group => 'docker',
        require => Exec['go_server_addons'],
    }
}