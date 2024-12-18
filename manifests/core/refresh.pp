#
class base::core::refresh ( ) {
  #
  ## Defaults
  #

  Exec {
    cwd         => '/tmp',
    path        => ['/bin', '/sbin' , '/usr/bin', '/usr/sbin'],
    refreshonly => true,
  }

  #
  ## Resources
  #

  exec { 'Refresh systemd':
    command => 'systemctl daemon-reload ; true',
  }

  exec { 'Refresh tmpfiles.d':
    command => 'systemd-tmpfiles --create; true',
  }
}
