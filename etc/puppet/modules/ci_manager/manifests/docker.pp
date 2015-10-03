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
) {

    class {'::docker':
      socket_bind => "unix://$docker_socket",
    }

    if $::environment != 'production' {
        notify {"This is $::environment environment. Try generate certificates to $certs_dir": }

        exec { 'ci_manager:certs_gen':
            command => "$bin_dir/gen_signed_certificate.sh $certs_dir",
            cwd => $certs_dir,
            creates => "$certs_dir/domain.crt",
            # before => Docker::Image['registry']
        }

        exec { 'docker_certs_d':
          command => "/bin/mkdir -p '$docker_certs_crt_dir/$docker_registry_host:$docker_registry_port'",
          creates => "$docker_certs_crt_dir/$docker_registry_host:$docker_registry_port",
          require => Exec['ci_manager:certs_gen'],
        }

        file { "docker_cert:$docker_registry_host:$docker_registry_port":
            ensure => file,
            source => "$certs_dir/domain.crt",
            path => "$docker_certs_crt_dir/$docker_registry_host:$docker_registry_port/domain.crt",
            require => Exec["docker_certs_d"],
            notify => Service['docker'],
        }

      #  Class['ci_manager::certs_gen'] -> docker::image['registry']
        File["docker_cert:$docker_registry_host:$docker_registry_port"] -> Docker::Run['images_registry']
    }



    docker::run { 'images_registry':
        volumes         => ["$certs_dir:/certs", "$docker_registry_lib:/var/lib/registry"],
#        volumes_from    => '6446ea52fbc9',
#        memory_limit    => '10m', # (format: '<number><unit>', where unit = b, k, m or g)
#        cpuset          => ['0', '3'],
#        username        => $docker_registry_user,
        # require => Docker::Image['registry'],
        name => $docker_registry_image_name,
        image           => 'registry:2',
#        command         => '/bin/sh -c "while true; do echo hello world; sleep 1; done"',
        ports           => ["$docker_registry_port:5000"],
#        expose          => [$docker_registry_port],
#        links           => ['mysql:db'],
        use_name        => true,
        hostname        => $docker_registry_host,
        env             => [
            "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt",
            "REGISTRY_HTTP_TLS_KEY=/certs/domain.key"
        ],
#        env             => ['FOO=BAR', 'FOO2=BAR2'],
#        env_file        => ['/etc/foo1', '/etc/bar'],
        dns             => ['8.8.8.8', '8.8.4.4'],
        manage_service => true,
        restart_service => true,
#        privileged      => false,
#        pull_on_start   => false,
        before_stop     => 'echo "Stopping Registry..."',
#        depends         => [ 'container_a', 'postgres' ],
    }

    # docker run -d -p 9000:9000 --privileged -v /var/run/docker.sock:/var/run/docker.sock dockerui/dockerui

    docker::run { 'dockerui':
        volumes         => ["$docker_socket:/var/run/docker.sock"],
        name => $docker_ui_name,
        image           => 'dockerui/dockerui',
        ports           => ["$docker_ui_port:9000"],
        use_name        => true,
        hostname        => $docker_registry_host,
        dns             => ['8.8.8.8', '8.8.4.4'],
        manage_service => true,
        restart_service => true,
#        privileged      => false,
    }

    # TODO: move docker images to separate files


    docker::run { 'go_cd_server':
        name => $docker_gocd_srv_name,
        image           => 'gocd/gocd-server',
        ports           => ["$docker_gocd_srv_port:8153"],
        use_name        => true,
        hostname        => $docker_gocd_srv_host,
        manage_service => true,
        restart_service => true,
        env => ["AGENT_KEY=123456789abcdef#!!"],
    }
# https://docktor-ci-manager:8154/go/
    docker::run { 'go_cd_agent':
        name => $docker_gocd_agent_name,
        # links           => ["172.17.42.1:gocd-server"],
        links           => ["$docker_gocd_srv_name:gocd-server"],
        # tty => true,
        # hostname        => $docker_gocd_agent_host,
        image           => 'gocd/gocd-agent',
        # use_name        => true,
        # manage_service => true,
        # restart_service => true,
        # ports           => ["$docker_gocd_agent_port:8154"],
        env => ["GO_SERVER=$docker_gocd_srv_host"],
        depends         => [ $docker_gocd_srv_name ],
    }

    # see https://hub.docker.com/r/gocd/gocd-agent/ for installing remote gocd agent


}
