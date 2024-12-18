#
class base::sudo {
  #
  ## Defaults
  #

  File {
    owner    => 'root',
    group    => 'root',
    mode     => '0440',
    seluser  => 'system_u',
    selrole  => 'object_r',
    seltype  => 'etc_t',
    selrange => 's0',
  }

  #
  ## Resources
  #

  file {'/etc/sudoers.d':
    ensure  => directory,
    recurse => true,
    purge   => true,
    source  => 'puppet:///modules/base/sudo/sudoers.d',
  }
}
