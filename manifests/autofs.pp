#
class base::autofs {
  #
  ## Defaults
  #

  File {
    ensure   => present,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    seluser  => 'system_u',
    selrole  => 'object_r',
    seltype  => 'etc_t',
    selrange => 's0',
    notify   => Service['autofs'],
    require  => Package['autofs'],
  }

  #
  ## Resources
  #

  package {'autofs':
    ensure => installed,
  }

  file {'/etc/autofs-direct.conf':
    source => 'puppet:///modules/base/autofs/autofs-direct.conf',
  }

  file {'/etc/auto.master.d/direct.autofs':
    source => 'puppet:///modules/base/autofs/direct.autofs',
  }

  service {'autofs':
    ensure  => running,
    enable  => true,
    require => Package['autofs'],
  }
}
