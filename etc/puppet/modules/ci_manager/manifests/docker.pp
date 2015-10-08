class ci_manager::docker (
    $docker_registry_host = 'docktor-ci-manager',
    $docker_registry_image_name = 'images_registry',
    $docker_registry_host = 'docktor-ci-manager',
    $docker_registry_port = '5000',
    $docker_registry_user = 'user',
    $docker_registry_password = 'pa$$word',
    $docker_registry_email = 'user@example.com',
    $docker_registry_lib = "/registry_lib",
    $certs_dir = '/certs',
    $bin_dir = '/usr/local/bin',
    $docker_certs_crt_dir = "/etc/docker/certs.d",
    $docker_socket = '/var/run/docker.sock',
    $docker_ui_name = 'dockerui',
    $docker_ui_port = '9000',
    $docker_gocd_srv_host = 'docktor-ci-manager',
    $docker_gocd_srv_name = 'go_cd_server',
    $docker_gocd_srv_port = '8153',
    $docker_gocd_agent_host = 'docktor-ci-manager',
    $docker_gocd_agent_port = '8160',
    $docker_gocd_agent_name = 'go_cd_agent',
    $docker_gocd_volume_dir = '/data/private/go_cd',
    $docker_sonar_volume_dir = '/data/private/sonarqube',
) {

    class { '::docker':
        socket_bind => "unix://$docker_socket",
    }

    if $::environment != 'production' {
        notify { "This is $::environment environment. Try generate certificates to $certs_dir": }

        exec { 'ci_manager:certs_gen':
            command => "$bin_dir/gen_signed_certificate.sh $certs_dir",
            cwd     => $certs_dir,
            creates => "$certs_dir/domain.crt",
        }

        exec { 'docker_certs_d':
            command => "/bin/mkdir -p '$docker_certs_crt_dir/$docker_registry_host:$docker_registry_port'",
            creates => "$docker_certs_crt_dir/$docker_registry_host:$docker_registry_port",
            require => Exec['ci_manager:certs_gen'],
        }

        file { "docker_cert:$docker_registry_host:$docker_registry_port":
            ensure  => file,
            source  => "$certs_dir/domain.crt",
            path    => "$docker_certs_crt_dir/$docker_registry_host:$docker_registry_port/domain.crt",
            require => Exec["docker_certs_d"],
            notify  => Service['docker'],
        }

        File["docker_cert:$docker_registry_host:$docker_registry_port"] -> Docker::Run['images_registry']
    }

    $docker = hiera('docker')
    $app = hiera('ci_manager')

    $certs_dir_source = $docker['registry']['certs_dir']

    docker::run { 'images_registry':
        volumes         => ["$certs_dir_source:/certs", "$docker_registry_lib:/var/lib/registry"],
        name            => $docker_registry_image_name,
        image           => 'registry:2',
        ports           => ["$docker_registry_port:5000"],
        use_name        => true,
        hostname        => $docker_registry_host,
        env             => [
            "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt",
            "REGISTRY_HTTP_TLS_KEY=/certs/domain.key"
        ],
        dns             => ['8.8.8.8', '8.8.4.4'],
        manage_service  => true,
        restart_service => true,
    }

    docker::run { 'dockerui':
        volumes         => ["$docker_socket:/var/run/docker.sock"],
        name            => $docker_ui_name,
        image           => 'dockerui/dockerui',
        ports           => ["$docker_ui_port:9000"],
        use_name        => true,
        hostname        => $docker_registry_host,
        dns             => ['8.8.8.8', '8.8.4.4'],
        manage_service  => true,
        restart_service => true,
    #        privileged      => true,
    }

    class { ci_manager::go_cd_server::init:
        docker => $docker,
        app => $app,
    }

    class { ci_manager::go_cd_agent::init:
        docker => $docker,
        app => $app,
    }

    class { ci_manager::sonar::init:
        docker => $docker,
        app => $app,
    }

}
