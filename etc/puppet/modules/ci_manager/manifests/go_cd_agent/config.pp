class ci_manager::go_cd_agent::config (
    $config
) {
    $dir = $config['data_dir']

    exec { "mkdir -p $dir/agent/lib":
        path => '/bin',
        creates => "$dir/agent/lib"
    }

    exec { "mkdir -p $dir/agent/log":
        path => '/bin',
        creates => "$dir/agent/log"
    }
}