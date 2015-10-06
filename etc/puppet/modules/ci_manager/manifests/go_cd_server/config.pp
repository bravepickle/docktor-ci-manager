class ci_manager::go_cd_server::config (
    $config
) {
    $dir = $config['data_dir']

    notify {"GOCD data dir $dir":}

    exec { "mkdir -p $dir/server/lib":
        path => '/bin',
        creates => "$dir/server/lib"
    }

    exec {"mkdir -p $dir/server/log":
        path => '/bin',
        creates => "$dir/server/log"
    }

    exec {"mkdir -p $dir/server/etc":
        path => '/bin',
        creates => "$dir/server/etc"
    }

    exec {"mkdir -p $dir/server/addons":
        path => '/bin',
        creates => "$dir/server/addons"
    }

    exec {"mkdir -p $dir/server/nice":
        path => '/bin',
        creates => "$dir/server/nice"
    }
}