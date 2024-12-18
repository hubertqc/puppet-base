#
class base::core::config () {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  File {
    ensure   => file,
    owner    => 'root',
    group    => 'root',
    seluser  => 'system_u',
    selrole  => 'object_r',
    selrange => 's0',
  }

  Sysctl {
    ensure  => present,
    comment => 'Managed by Puppet',
  }

  #
  ## Resources
  #

  case $::facts['os']['family'] {
    'Debian': { $sshd = 'ssh' }
    default:  { $sshd = 'sshd' }
  }

  file {'/etc/ssh/sshd_config':
    mode    => '0400',
    content => template('base/core/config/sshd_config.erb'),
    notify  => Service[$sshd],
  }

  file { ['/etc/logwatch/conf/override.conf', '/etc/logwatch/conf/logwatch.conf']:
    mode    => '0444',
    source  => 'puppet:///modules/base/core/config/logwatch-override.conf',
    require => Package['logwatch'],
  }

  file { '/var/log/journal':
    ensure  => directory,
    group   => 'systemd-journal',
    mode    => '2755',
    seltype => 'var_log_t',
    purge   => 'false',
  }

  if ( has_key($::facts['networking']['interfaces'], 'br0') ) {
    if ( $::facts['networking']['interfaces']['br0']['network'] == '10.255.0.0' ) {
      sysctl{ 'net.ipv4.conf.br0.shared_media':
        value => '1',
      }
      sysctl{ 'net.ipv4.conf.br0.forwarding':
        value => '1',
      }
      sysctl{ 'net.ipv6.conf.br0.forwarding':
        value => '1',
      }
    }
  }
}
