class ci_manager::sonar::init (
    $docker,
    $app
) {
    $config = $docker['sonar']
    $dir = $config['data_dir']

    # TODO: see https://hub.docker.com/_/sonarqube/ for prod env

    class { ci_manager::sonar::config:
        config => $config,
    }

    docker::run { $config['container_name']:
        image           => 'sonarqube:5.1',
        ports           => ["${config[port_web]}:9000", "${config[port_api]}:9092"],
        use_name        => true,
        hostname        => $app['host'],
        manage_service  => true,
        restart_service => true,
        volumes         => [
            "$dir/data:/opt/sonarqube/data",
            "$dir/extensions:/opt/sonarqube/extensions",
        ],
    }

    Class['ci_manager::sonar::config'] -> Docker::Run[$config['container_name']]
}