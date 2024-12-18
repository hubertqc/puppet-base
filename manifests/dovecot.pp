#
class base::dovecot (
  Boolean            $active_service       = false,

  Optional[String]   $replication_host     = undef,
  Boolean            $replication_ssl      = false,
  Integer            $replication_port     = 3905,
  Optional[String]   $replication_password = undef,

  Optional[String]   $pg_host              = undef,
  Optional[String]   $pg_dbname            = undef,
  Optional[String]   $pg_user              = undef,
  Optional[String]   $pg_passwd            = undef,
) {
  #
  ## Defaults
  #
  #
  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    seluser  => 'system_u',
    selrole  => 'object_r',
    seltype  => 'dovecot_etc_t',
    selrange => 's0',
    require  => Package['dovecot'],
    notify   => Service['dovecot'],
  }

  #
  ## Resources
  #
  
  package {['dovecot','dovecot-pgsql']:
    ensure => installed,
  }

  file {'/etc/systemd/system/dovecot.service.d':
    ensure  => directory,
    mode    => '0644',
    seltype => 'systemd_unit_file_t',
    recurse => true,
    purge   => true,
    source  => 'puppet:///modules/base/dovecot/systemd',
    notify  => [Exec['Refresh systemd'], Service['dovecot']],
  }

  file {'/etc/dovecot/conf.d':
    ensure  => directory,
    source  => 'puppet:///modules/base/dovecot/conf.d',
    recurse => true,
    purge   => false,
  }

  file {'/etc/dovecot/conf.d/15-lda.conf':
    mode    => '0600',
    content => template('base/dovecot/conf.d/15-lda.conf.erb'),
  }

  if $replication_host =~ String
  {
    file {'/etc/dovecot/conf.d/10-replication.conf':
      mode    => '0600',
      content => template('base/dovecot/conf.d/10-replication.conf.erb'),
    }
  }

  file {'/etc/dovecot/dovecot-dict-pgsql_last_login.conf.ext':
    owner   => 'dovecot',
    mode    => '0400',
    content => template('base/dovecot/dovecot-dict-pgsql_last_login.conf.ext.erb'),
  }

  file {'/etc/dovecot/dovecot-dict-pgsql_mailbox_status.conf.ext':
    owner   => 'dovecot',
    mode    => '0400',
    content => template('base/dovecot/dovecot-dict-pgsql_mailbox_status.conf.ext.erb'),
  }

  if $active_service {
    service {'dovecot':
      ensure => running,
      enable => true,
    }
  } else {
    service {'dovecot':
      ensure => stopped,
      enable => false,
    }
  }

}
