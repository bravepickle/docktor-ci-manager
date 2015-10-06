class ci_manager::go_cd_agent::init (
    $docker,
    $app
) {
    $config = $docker['go_cd']['agent']
    $dir = $config['data_dir']

    class { ci_manager::go_cd_agent::config:
        config => $config,
    }

    docker::run { 'go_cd_agent':
        name            => $config['container_name'],
        image           => 'gocd/gocd-agent',
        env             => [
            "GO_SERVER=${app[host]}",
            "AGENT_KEY=${docker[go_cd][agent_key]}"
        ],
        volumes         => [
            "$dir/agent/lib:/var/lib/go-agent",
            "$dir/agent/log:/var/log/go-agent",
        ],
    }

    Class['ci_manager::go_cd_agent::config'] -> Docker::Run['go_cd_agent']
}