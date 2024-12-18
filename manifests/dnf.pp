#
class base::dnf {
  #
  ## Defaults
  #
  File {
    ensure   => file,
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    seluser  => 'system_u',
    selrole  => 'object_r',
    seltype  => 'etc_t',
    selrange => 's0',
    require  => Package['dnf-automatic'],
  }

  #
  ## Resources
  #

  package {'dnf-automatic':
    ensure => installed,
  }

  service { 'dnf-automatic.timer':
    ensure  => running,
    enable  => true,
    require => [Package['dnf-automatic'], File['/etc/dnf/automatic.conf']],
  }
  service { 'dnf-automatic-notifyonly.timer':
    ensure  => stopped,
    enable  => false,
    require => [Package['dnf-automatic'], File['/etc/dnf/automatic.conf']],
  }

  file {'/etc/dnf/automatic.conf':
    content => template('base/dnf/dnf-automatic.conf.erb'),
  }

  file {'/etc/dnf/dnf.conf':
    source => 'puppet:///modules/base/dnf/dnf.conf',
  }
}
