class ci_manager::go_cd (
    $server_uri = 'http://download.go.cd/gocd-deb/go-server-15.2.0-2248.deb',
    $agent_uri = 'http://download.go.cd/gocd-deb/go-agent-15.2.0-2248.deb',
    $tmp_dir = '/tmp'
) {

#  apt::source { 'go_cd':
#    comment  => 'Installing GO CD sources',
#    location => 'http://dl.bintray.com/gocd/gocd-deb/',
#    key      => {
#      id => 'bb111222',
#      source => "https://bintray.com/user/downloadSubjectPublicKey?username=gocd",
#    },
#    # include  => {
#    #   'src' => true,
#    #   'deb' => true,
#    # },
#  }



#   $ echo "deb http://dl.bintray.com/gocd/gocd-deb/ /" > /etc/apt/sources.list.d/gocd.list
# $ wget --quiet -O - "https://bintray.com/user/downloadSubjectPublicKey?username=gocd" | sudo apt-key add -
# $ apt-get update
# $ apt-get install go-server

# exec { 'go-cd-server-download':
#     command => "curl -o ./go-cd-server.deb '$server_uri'",
#     path => "/usr/bin",
#     cwd => $tmp_dir,
# }
#
# package { 'go-cd-server':
#   ensure => latest,
#   provider => dpkg,
#   source => "$tmp_dir/go-cd-server.deb",
#   require => Exec['go-cd-server-download'],
# }
#
# exec { 'go-cd-agent-download':
#     command => "curl -o ./go-cd-agent.deb '$agent_uri'",
#     path => "/usr/bin",
#     cwd => $tmp_dir,
# }
#
# package { 'go-cd-agent':
#   ensure => latest,
#   provider => dpkg,
#   source => "$tmp_dir/go-cd-agent.deb",
#   require => Exec['go-cd-agent-download'],
# }
}
