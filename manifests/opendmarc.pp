#
class base::opendmarc (
  Integer                   $uid,
  Integer                   $gid,
) {

  #
  ## Defaults
  #
  File {
    owner   => 'root',
    group   => 'root',
    seluser => 'system_u',
    selrole => 'object_r',
    mode    => '0644',
    require => Package['opendmarc'],
    notify  => Service['opendmarc'],
  }

  #
  ## Resources
  #

  group {'opendmarc':
    ensure => present,
    gid    => $gid,
  }

  user {'opendmarc':
    ensure     => present,
    uid        => $uid,
    gid        => $gid,
    groups     => [ 'opendmarc', 'mail', 'postdrop' ],
    home       => '/var/run/opendmarc',
    shell      => '/sbin/nologin',
    password   => '!!',
    require    => Group['opendmarc'],
  }

  package { ['opendmarc', 'perl-DBD-MySQL']:
    ensure => present,
    require => User['opendmarc'],
  }

  file {'/etc/opendmarc':
    ensure  => directory,
    group   => 'opendmarc',
    seltype => 'etc_t',
    mode    => '0755',
    purge   => true,
    force   => true,
  }
  file {'/etc/opendmarc.conf':
    ensure  => file,
    group   => 'opendmarc',
    seltype => 'etc_t',
    source  => 'puppet:///modules/base/opendmarc/opendmarc.conf',
  }
  file {'/etc/opendmarc/ignore.hosts':
    ensure  => file,
    group   => 'opendmarc',
    seltype => 'etc_t',
    source  => 'puppet:///modules/base/opendmarc/ignore.hosts',
    require => File['/etc/opendmarc'],
  }

  file {'/var/log/opendmarc':
    ensure  => directory,
    owner   => 'opendmarc',
    group   => 'opendmarc',
    seltype => 'var_log_t',
    mode    => '0644',
    recurse => true,
  }

  file {'/var/spool/opendmarc':
    ensure  => directory,
    owner   => 'opendmarc',
    group   => 'opendmarc',
    seltype => 'dkim_milter_data_t',
    mode    => '0644',
    recurse => true,
  }

  file {'/var/run/opendmarc':
    ensure  => directory,
    owner   => 'opendmarc',
    group   => 'opendmarc',
    seltype => 'dkim_milter_data_t',
    mode    => '0750',
  }

  file {'/etc/systemd/system/opendmarc.service.d':
    ensure  => directory,
    seltype => 'systemd_unit_file_t',
    mode    => '0755',
    purge   => true,
    force   => true,
  }
  file {'/etc/systemd/system/opendmarc.service.d/override.conf':
    ensure  => present,
    seltype => 'systemd_unit_file_t',
    source  => 'puppet:///modules/base/opendmarc/service-override.conf',
    require => File['/etc/systemd/system/opendmarc.service.d'],
  }

  service {'opendmarc':
    ensure => running,
    enable => true,
  }
}
