class ci_manager::sonar::config (
    $config
) {
    $dir = $config['data_dir']

    exec { "mkdir -p $dir/data":
        path => '/bin',
        creates => "$dir/data"
    }

    exec { "mkdir -p $dir/extensions":
        path => '/bin',
        creates => "$dir/extensions"
    }
}