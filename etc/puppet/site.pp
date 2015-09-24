package { 'git':
    ensure => present
}

$packages = hiera('extra_packages')
$ci_manager = hiera('ci_manager')

package { $packages:
    ensure => present
}

host { 'ci_manager':
    name => $ci_manager['host'],
    ip   => $ci_manager['ip'],
    comment => 'Managed by Puppet'
}