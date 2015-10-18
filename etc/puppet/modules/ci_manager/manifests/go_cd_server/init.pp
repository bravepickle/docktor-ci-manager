class ci_manager::go_cd_server::init (
    $docker,
    $app
) {

    $config = $docker['go_cd']['server']
    $dir = $config['data_dir']

    class { ci_manager::go_cd_server::config:
        config => $config,
    }

    docker::run { $config['container_name']:
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

    Class['ci_manager::go_cd_server::config'] -> Docker::Run[$config['container_name']]
}