#
class base::fail2ban {
  #
  ## Defaults
  #

  Package {
    ensure => installed,
  }

  File {
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    seluser => 'system_u',
    selrole => 'object_r',
    seltype => 'etc_t',
    mode    => '0644',
    notify  => Service['fail2ban'],
    require => Package['fail2ban-server', 'fail2ban-systemd', 'fail2ban'],
  }

  #
  ## Resources
  #

  package { ['fail2ban', 'fail2ban-firewalld', 'fail2ban-selinux', 'fail2ban-sendmail', 'fail2ban-server', 'fail2ban-systemd']: }

  service { 'fail2ban':
    ensure  => running,
    enable  => true,
    require => Package['fail2ban-systemd'],
  }

  file { '/etc/fail2ban/fail2ban.conf':
    content => template('base/fail2ban/fail2ban.conf.erb');
  }
  
  file { '/etc/fail2ban/jail.conf':
    content => template('base/fail2ban/jail.conf.erb');
  }
}
