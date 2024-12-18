#
class base::scripts {

  #
  ## Defaults
  #

  File {
    owner   => 'root',
    group   => 'root',
    seluser => 'system_u',
    selrole => 'object_r',
    notify  => Exec['Restore fcontexts on /opt/scripts'],
  }

  #
  ## Resources
  #

  file {'/opt/scripts':
    ensure  => directory,
    mode    => '0755',
    recurse => true,
    source  => 'puppet:///modules/base/scripts/dir',
  }

  exec {'Restore fcontexts on /opt/scripts':
    command     => 'restorecon -RF /opt/scripts',
    path        => ['/bin', '/sbin'],
    refreshonly => true,
  }
}
