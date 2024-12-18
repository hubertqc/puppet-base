#
class base::services (
) {
  #
  ## Make this class private
  #

  assert_private()

  #
  ## Defaults
  #

  File {
    owner    => 'root',
    group    => 'root',
    mode     => '0644',
    seluser  => 'system_u',
    selrole  => 'object_r',
    selrange => 's0',
    notify   => Exec['Refresh systemd'],
  }

  Service {
    ensure  => 'running',
    enable  => true,
    require => Exec['Refresh systemd'],
  }

  #
  ##
  #

  service { 'slapd': }

  service { 'fail2ban-to-PgSQL': }

  service { 'postgresql': }

  file { '/etc/systemd/system/postgresql.service.d':
    ensure  => directory,
    seltype => 'postgresql_unit_file_t',
    recurse => true,
    purge   => true,
  }

  file { '/etc/systemd/system/postgresql.service.d/override.conf':
    ensure  => file,
    seltype => 'postgresql_unit_file_t',
    source  => 'puppet:///modules/base/services/systemd-postgresql.conf',
    require => File['/etc/systemd/system/postgresql.service.d'],
    notify  => [ Service['postgresql'], Exec['Refresh systemd'] ],
  }

  file {'/etc/systemd/system/fail2ban-to-PgSQL.socket':
    ensure => absent,
    notify => [ Service['fail2ban-to-PgSQL'], Exec['Refresh systemd'] ],
  }

  file {'/etc/systemd/system/fail2ban-to-PgSQL.service':
    ensure  => file,
    seltype => 'systemd_unit_file_t',
    source  => 'puppet:///modules/base/services/systemd-fail2ban-to-PgSQL.service',
    notify  => [ Service['fail2ban-to-PgSQL'], Exec['Refresh systemd'] ],
  }
}
