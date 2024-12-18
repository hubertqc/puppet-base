#
class base::ipsec () {
  #
  ## Defaults
  #

  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    seluser => 'system_u',
    selrole => 'object_r',
    mode    => '0400',
    require => Package['libreswan'],
    notify  => Service['ipsec'],
  }

  #
  ## Resources
  #
  
  package {'libreswan':
    ensure => installed,
  }

  service {'ipsec':
    ensure => running,
    enable => true,
  }

  file {'/etc/ipsec.conf':
    source => 'puppet:///modules/base/ipsec/ipsec.conf',
  }

  file {'/etc/crypto-policies/back-ends/libreswan.config':
    source => 'puppet:///modules/base/ipsec/libreswan.config',
  }

  file {'/etc/systemd/system/ipsec.service.d':
    ensure  => directory,
    seltype => 'ipsec_mgmt_unit_file_t',
    mode    => '0644',
    recurse => true,
    force   => true,
    source  => 'puppet:///modules/base/ipsec/ipsec.service.d',
    notify  => Exec['Refresh systemd'],
    before  => Service['ipsec'],
  }

  file {'/etc/ipsec.d':
    ensure  => directory,
    mode    => '0600',
    recurse => true,
    force   => true,
    purge   => false,
    source  => 'puppet:///modules/base/ipsec/ipsec.d',
  }
  file {'/etc/ipsec.d/local-backbone-ipv6.conf':
    ensure  => link,
    target  => "/etc/ipsec.d/backbone-${::hostname}.ipv6",
    force   => true,
    require => File['/etc/ipsec.d'],
  }
}
