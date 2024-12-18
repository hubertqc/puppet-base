#
class base::saslauth {
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
    notify  => Service['saslauthd'],
    require => Package['cyrus-sasl'],
  }

  #
  ## Resources
  #

  package { 'cyrus-sasl': }

  service { 'saslauthd':
    ensure  => running,
    enable  => true,
    require => Package['cyrus-sasl'],
  }

  file { '/etc/sysconfig/saslauthd':
    content => template('base/saslauth/saslauthd.erb');
  }

  file { '/etc/saslauthd.conf':
    content => template('base/saslauth/saslauthd.conf.erb');
  }
}
