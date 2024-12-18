#
class base::policyd_spf {
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
    require => Package['pypolicyd-spf'],
  }

  #
  ## Resources
  #

  package { 'pypolicyd-spf': }

  file { '/etc/python-policyd-spf/policyd-spf.conf':
    content => template('base/policyd_spf/policyd-spf.conf.erb');
  }
}
