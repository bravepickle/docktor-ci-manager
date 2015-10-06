class ci_manager::go_cd_server::init (
    $docker,
    $app
) {

    $config = $docker['go_cd']['server']
    $dir = $config['data_dir']
#$docker_gocd_srv_host = 'docktor-ci-manager',
#$docker_gocd_srv_name = 'go_cd_server',
#$docker_gocd_srv_port = '8153',

    class { ci_manager::go_cd_server::config:
        config => $config,
    }
#    ci_manager:
#    host: "docktor-ci-manager"
#ip: "127.0.0.1"

    docker::run { 'go_cd_server':
        name            => $config['container_name'],
        image           => 'gocd/gocd-server',
        ports           => ["${config[port_web]}:8153", "${config[port_agent]}:8154"],
        use_name        => true,
        hostname        => $app['host'],
        manage_service  => true,
        restart_service => true,
        env             => ["AGENT_KEY=${docker[go_cd][agent_key]}"],
        volumes         => [
            "$dir/server/lib:/var/lib/go-server",
            "$dir/server/log:/var/log/go-server",
            "$dir/server/etc:/etc/go",
            "$dir/server/addons:/go-addons",
        ],
    }

    Class['ci_manager::go_cd_server::config'] -> Docker::Run['go_cd_server']
}